import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";

import {
  getFirestore,
  FieldValue,
} from "firebase-admin/firestore";

import { getStorage } from "firebase-admin/storage";

import ExcelJS from "exceljs";
import PDFDocument from "pdfkit";
import nodemailer from "nodemailer";

const db = getFirestore();

type ExportFormat =
  | "pdf"
  | "excel"
  | "csv";

type ExportPeriod =
  | "thisMonth"
  | "lastMonth"
  | "thisQuarter"
  | "thisYear";

type ExportSection =
  | "revenueSummary"
  | "transactionHistory"
  | "expenseBreakdown"
  | "membershipStats";

interface FinanceTransactionRecord {
  id: string;
  title: string;
  amount: number;
  type: string;
  date: Date;
  category?: string;
  description?: string;
  memberId?: string;
  membershipPlanId?: string;
}

interface MemberRecord {
  id: string;
  displayName?: string;
  email?: string;
  membershipPlanId?: string;
  membershipStatus?: string;
}

interface MembershipPlanRecord {
  id: string;
  name: string;
}

interface FinanceReportData {
  transactions: FinanceTransactionRecord[];
  members: MemberRecord[];
  plans: MembershipPlanRecord[];
  revenue: number;
  expenses: number;
  net: number;
}

export const exportFinanceReport = onCall(
  {
    timeoutSeconds: 120,
    memory: "512MiB",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Authentication required.",
      );
    }

    const data = request.data ?? {};

    const gymId =
      String(data.gymId ?? "").trim();

    const format =
      String(data.format ?? "").trim() as ExportFormat;

    const period =
      String(data.period ?? "").trim() as ExportPeriod;

    /*
     * request.data is dynamically typed, so explicitly treat
     * incoming sections as unknown before converting them.
     */
    const rawSections: unknown[] =
      Array.isArray(data.sections)
        ? data.sections
        : [];

    const sections: string[] =
      rawSections
        .map(
          (value: unknown) =>
            String(value),
        )
        .filter(
          (value: string) =>
            value.trim().length > 0,
        );

    const email =
      data.email == null
        ? null
        : String(data.email)
            .trim()
            .toLowerCase();

    validateRequest({
      gymId,
      format,
      period,
      sections,
      email,
    });

    await verifyOwner({
      uid: request.auth.uid,
      gymId,
    });

    const range =
      getPeriodRange(period);

    const reportData =
      await loadFinanceData(
        gymId,
        range.start,
        range.end,
      );

    const generated =
      await generateFile({
        gymId,
        format,
        period,
        sections: sections as ExportSection[],
        reportData,
      });

    const bucket =
      getStorage().bucket();

    const file =
      bucket.file(
        generated.storagePath,
      );

    await file.save(
      generated.buffer,
      {
        contentType:
          generated.contentType,
        metadata: {
          metadata: {
            gymId,
            generatedBy:
              request.auth.uid,
            format,
            createdAt:
              new Date().toISOString(),
          },
        },
        resumable: false,
      },
    );

    const [downloadUrl] =
      await file.getSignedUrl({
        version: "v4",
        action: "read",
        expires:
          Date.now() +
          15 * 60 * 1000,
      });

    let emailed = false;

    if (email) {
      await sendExportEmail({
        email,
        fileName:
          generated.fileName,
        downloadUrl,
        format,
        period,
      });

      emailed = true;
    }

    await db
      .collection("gyms")
      .doc(gymId)
      .collection("financeExports")
      .add({
        fileName:
          generated.fileName,
        storagePath:
          generated.storagePath,
        format,
        period,
        sections,
        email,
        emailed,
        generatedBy:
          request.auth.uid,
        createdAt:
          FieldValue.serverTimestamp(),
      });

    return {
      success: true,
      fileName:
        generated.fileName,
      format,
      downloadUrl,
      emailed,
      email,
      message: email
        ? "Finance report generated and emailed successfully."
        : "Finance report generated successfully.",
    };
  },
);

function validateRequest({
  gymId,
  format,
  period,
  sections,
  email,
}: {
  gymId: string;
  format: ExportFormat;
  period: ExportPeriod;
  sections: string[];
  email: string | null;
}) {
  if (!gymId) {
    throw new HttpsError(
      "invalid-argument",
      "Gym ID is required.",
    );
  }

  const validFormats =
    ["pdf", "excel", "csv"];

  if (!validFormats.includes(format)) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid export format.",
    );
  }

  const validPeriods = [
    "thisMonth",
    "lastMonth",
    "thisQuarter",
    "thisYear",
  ];

  if (!validPeriods.includes(period)) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid export period.",
    );
  }

  const validSections: ExportSection[] = [
    "revenueSummary",
    "transactionHistory",
    "expenseBreakdown",
    "membershipStats",
  ];

  const invalidSection =
    sections.some(
      (section: string) =>
        !validSections.includes(
          section as ExportSection,
        ),
    );

  if (
    sections.length === 0 ||
    invalidSection
  ) {
    throw new HttpsError(
      "invalid-argument",
      "At least one valid export section must be selected.",
    );
  }

  if (
    email &&
    !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid email address.",
    );
  }
}

async function verifyOwner({
  uid,
  gymId,
}: {
  uid: string;
  gymId: string;
}) {
  const ownerSnapshot =
    await db
      .collection("users")
      .doc(uid)
      .get();

  if (!ownerSnapshot.exists) {
    throw new HttpsError(
      "permission-denied",
      "Owner profile not found.",
    );
  }

  const owner =
    ownerSnapshot.data();

  if (owner?.role !== "owner") {
    throw new HttpsError(
      "permission-denied",
      "Only gym owners can export finance reports.",
    );
  }

  if (owner?.gymId !== gymId) {
    throw new HttpsError(
      "permission-denied",
      "You do not manage this gym.",
    );
  }
}

function getPeriodRange(
  period: ExportPeriod,
) {
  const now = new Date();

  switch (period) {
    case "thisMonth":
      return {
        start:
          new Date(
            now.getFullYear(),
            now.getMonth(),
            1,
          ),
        end:
          new Date(
            now.getFullYear(),
            now.getMonth() + 1,
            1,
          ),
      };

    case "lastMonth":
      return {
        start:
          new Date(
            now.getFullYear(),
            now.getMonth() - 1,
            1,
          ),
        end:
          new Date(
            now.getFullYear(),
            now.getMonth(),
            1,
          ),
      };

    case "thisQuarter": {
      const quarter =
        Math.floor(
          now.getMonth() / 3,
        );

      return {
        start:
          new Date(
            now.getFullYear(),
            quarter * 3,
            1,
          ),
        end:
          new Date(
            now.getFullYear(),
            quarter * 3 + 3,
            1,
          ),
      };
    }

    case "thisYear":
      return {
        start:
          new Date(
            now.getFullYear(),
            0,
            1,
          ),
        end:
          new Date(
            now.getFullYear() + 1,
            0,
            1,
          ),
      };
  }
}

async function loadFinanceData(
  gymId: string,
  start: Date,
  end: Date,
): Promise<FinanceReportData> {
  const transactionsSnapshot =
    await db
      .collection("gyms")
      .doc(gymId)
      .collection("financeTransactions")
      .where("date", ">=", start)
      .where("date", "<", end)
      .orderBy("date", "desc")
      .get();

  const transactions =
    transactionsSnapshot.docs.map(
      (doc) => {
        const data =
          doc.data();

        const rawDate =
          data.date;

        return {
          id: doc.id,
          title:
            String(
              data.title ?? "",
            ),
          amount:
            Number(
              data.amount ?? 0,
            ),
          type:
            String(
              data.type ?? "income",
            ),
          date:
            rawDate?.toDate
              ? rawDate.toDate()
              : new Date(),
          category:
            data.category
              ? String(
                  data.category,
                )
              : undefined,
          description:
            data.description
              ? String(
                  data.description,
                )
              : undefined,
          memberId:
            data.memberId
              ? String(
                  data.memberId,
                )
              : undefined,
          membershipPlanId:
            data.membershipPlanId
              ? String(
                  data.membershipPlanId,
                )
              : undefined,
        };
      },
    );

  const membersSnapshot =
    await db
      .collection("users")
      .where(
        "gymId",
        "==",
        gymId,
      )
      .get();

  const members =
    membersSnapshot.docs
      .filter(
        (doc) =>
          doc.data().role ===
          "member",
      )
      .map(
        (doc) => {
          const data =
            doc.data();

          return {
            id: doc.id,
            displayName:
              data.displayName
                ? String(
                    data.displayName,
                  )
                : undefined,
            email:
              data.email
                ? String(
                    data.email,
                  )
                : undefined,
            membershipPlanId:
              data.membershipPlanId
                ? String(
                    data.membershipPlanId,
                  )
                : undefined,
            membershipStatus:
              data.membershipStatus
                ? String(
                    data.membershipStatus,
                  )
                : undefined,
          };
        },
      );

  const plansSnapshot =
    await db
      .collection("gyms")
      .doc(gymId)
      .collection("membershipPlans")
      .get();

  const plans =
    plansSnapshot.docs.map(
      (doc) => ({
        id: doc.id,
        name:
          String(
            doc.data().name ?? "",
          ),
      }),
    );

  let revenue = 0;
  let expenses = 0;

  for (
    const transaction
    of transactions
  ) {
    if (
      transaction.type ===
      "expense"
    ) {
      expenses +=
        transaction.amount;
    } else {
      revenue +=
        transaction.amount;
    }
  }

  return {
    transactions,
    members,
    plans,
    revenue,
    expenses,
    net:
      revenue - expenses,
  };
}

async function generateFile({
  gymId,
  format,
  period,
  sections,
  reportData,
}: {
  gymId: string;
  format: ExportFormat;
  period: ExportPeriod;
  sections: ExportSection[];
  reportData: FinanceReportData;
}) {
  const stamp =
    Date.now();

  const baseName =
    `finance-report-${period}-${stamp}`;

  if (format === "csv") {
    const content =
      buildCsv(
        reportData,
        sections,
      );

    return {
      fileName:
        `${baseName}.csv`,
      storagePath:
        `finance-exports/${gymId}/${baseName}.csv`,
      buffer:
        Buffer.from(
          content,
          "utf8",
        ),
      contentType:
        "text/csv; charset=utf-8",
    };
  }

  if (format === "excel") {
    const buffer =
      await buildExcel(
        reportData,
        sections,
      );

    return {
      fileName:
        `${baseName}.xlsx`,
      storagePath:
        `finance-exports/${gymId}/${baseName}.xlsx`,
      buffer,
      contentType:
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    };
  }

  const buffer =
    await buildPdf(
      reportData,
      sections,
    );

  return {
    fileName:
      `${baseName}.pdf`,
    storagePath:
      `finance-exports/${gymId}/${baseName}.pdf`,
    buffer,
    contentType:
      "application/pdf",
  };
}

function buildCsv(
  data: FinanceReportData,
  sections: ExportSection[],
): string {
  const rows: string[][] = [];

  rows.push([
    "Finance Report",
  ]);

  rows.push([
    "Revenue",
    data.revenue.toFixed(2),
  ]);

  rows.push([
    "Expenses",
    data.expenses.toFixed(2),
  ]);

  rows.push([
    "Net",
    data.net.toFixed(2),
  ]);

  rows.push([]);

  if (
    sections.includes(
      "revenueSummary",
    )
  ) {
    rows.push([
      "Revenue Summary",
    ]);

    rows.push([
      "Revenue",
      data.revenue.toFixed(2),
    ]);

    rows.push([
      "Expenses",
      data.expenses.toFixed(2),
    ]);

    rows.push([
      "Net",
      data.net.toFixed(2),
    ]);

    rows.push([]);
  }

  if (
    sections.includes(
      "expenseBreakdown",
    )
  ) {
    rows.push([
      "Expense Breakdown",
    ]);

    rows.push([
      "Category",
      "Amount",
    ]);

    const breakdown =
      new Map<string, number>();

    for (
      const transaction
      of data.transactions
    ) {
      if (
        transaction.type !==
        "expense"
      ) {
        continue;
      }

      const category =
        transaction.category ??
        "Other";

      breakdown.set(
        category,
        (breakdown.get(
          category,
        ) ?? 0) +
          transaction.amount,
      );
    }

    for (
      const [category, amount]
      of breakdown.entries()
    ) {
      rows.push([
        category,
        amount.toFixed(2),
      ]);
    }

    rows.push([]);
  }

  if (
    sections.includes(
      "transactionHistory",
    )
  ) {
    rows.push([
      "Transaction History",
    ]);

    rows.push([
      "Date",
      "Title",
      "Type",
      "Amount",
      "Category",
      "Description",
    ]);

    for (
      const transaction
      of data.transactions
    ) {
      rows.push([
        transaction.date
          .toISOString()
          .split("T")[0],
        transaction.title,
        transaction.type,
        transaction.amount.toFixed(2),
        transaction.category ?? "",
        transaction.description ?? "",
      ]);
    }

    rows.push([]);
  }

  if (
    sections.includes(
      "membershipStats",
    )
  ) {
    rows.push([
      "Membership Stats",
    ]);

    rows.push([
      "Plan",
      "Members",
    ]);

    const planNames =
      new Map(
        data.plans.map(
          (plan) => [
            plan.id,
            plan.name,
          ],
        ),
      );

    const counts =
      new Map<string, number>();

    for (
      const member
      of data.members
    ) {
      if (
        !member.membershipPlanId
      ) {
        continue;
      }

      const name =
        planNames.get(
          member.membershipPlanId,
        ) ??
        "Unknown";

      counts.set(
        name,
        (counts.get(name) ?? 0) +
          1,
      );
    }

    for (
      const [plan, count]
      of counts.entries()
    ) {
      rows.push([
        plan,
        String(count),
      ]);
    }
  }

  return rows
    .map(
      (row) =>
        row
          .map(csvEscape)
          .join(","),
    )
    .join("\n");
}

function csvEscape(
  value: string,
): string {
  if (
    value.includes(",") ||
    value.includes('"') ||
    value.includes("\n")
  ) {
    return `"${value.replaceAll(
      '"',
      '""',
    )}"`;
  }

  return value;
}

async function buildExcel(
  data: FinanceReportData,
  sections: ExportSection[],
): Promise<Buffer> {
  const workbook =
    new ExcelJS.Workbook();

  workbook.creator =
    "SweatSync";

  const summary =
    workbook.addWorksheet(
      "Summary",
    );

  summary.addRow([
    "Finance Report",
  ]);

  summary.addRow([
    "Revenue",
    data.revenue,
  ]);

  summary.addRow([
    "Expenses",
    data.expenses,
  ]);

  summary.addRow([
    "Net",
    data.net,
  ]);

  if (
    sections.includes(
      "transactionHistory",
    )
  ) {
    const sheet =
      workbook.addWorksheet(
        "Transactions",
      );

    sheet.addRow([
      "Date",
      "Title",
      "Type",
      "Amount",
      "Category",
      "Description",
    ]);

    for (
      const transaction
      of data.transactions
    ) {
      sheet.addRow([
        transaction.date,
        transaction.title,
        transaction.type,
        transaction.amount,
        transaction.category ?? "",
        transaction.description ?? "",
      ]);
    }

    sheet.getColumn(1).numFmt =
      "yyyy-mm-dd";

    sheet.getColumn(4).numFmt =
      "#,##0.00";
  }

  if (
    sections.includes(
      "expenseBreakdown",
    )
  ) {
    const sheet =
      workbook.addWorksheet(
        "Expenses",
      );

    sheet.addRow([
      "Category",
      "Amount",
    ]);

    const totals =
      new Map<string, number>();

    for (
      const transaction
      of data.transactions
    ) {
      if (
        transaction.type !==
        "expense"
      ) {
        continue;
      }

      const category =
        transaction.category ??
        "Other";

      totals.set(
        category,
        (totals.get(
          category,
        ) ?? 0) +
          transaction.amount,
      );
    }

    for (
      const [category, amount]
      of totals.entries()
    ) {
      sheet.addRow([
        category,
        amount,
      ]);
    }
  }

  if (
    sections.includes(
      "membershipStats",
    )
  ) {
    const sheet =
      workbook.addWorksheet(
        "Memberships",
      );

    sheet.addRow([
      "Plan",
      "Members",
    ]);

    const names =
      new Map(
        data.plans.map(
          (plan) => [
            plan.id,
            plan.name,
          ],
        ),
      );

    const counts =
      new Map<string, number>();

    for (
      const member
      of data.members
    ) {
      if (
        !member.membershipPlanId
      ) {
        continue;
      }

      const name =
        names.get(
          member.membershipPlanId,
        ) ??
        "Unknown";

      counts.set(
        name,
        (counts.get(name) ?? 0) +
          1,
      );
    }

    for (
      const [name, count]
      of counts.entries()
    ) {
      sheet.addRow([
        name,
        count,
      ]);
    }
  }

  for (
    const sheet
    of workbook.worksheets
  ) {
    sheet.columns.forEach(
      (column) => {
        column.width = 24;
      },
    );
  }

  const buffer =
    await workbook.xlsx.writeBuffer();

  return Buffer.from(buffer);
}

async function buildPdf(
  data: FinanceReportData,
  sections: ExportSection[],
): Promise<Buffer> {
  return new Promise(
    (resolve) => {
      const document =
        new PDFDocument({
          margin: 40,
        });

      const chunks: Buffer[] = [];

      document.on(
        "data",
        (chunk) => {
          chunks.push(
            Buffer.from(chunk),
          );
        },
      );

      document.on(
        "end",
        () => {
          resolve(
            Buffer.concat(chunks),
          );
        },
      );

      document
        .fontSize(20)
        .text(
          "SweatSync Finance Report",
        );

      document.moveDown();

      document
        .fontSize(12)
        .text(
          `Revenue: ${data.revenue.toFixed(2)}`,
        );

      document.text(
        `Expenses: ${data.expenses.toFixed(2)}`,
      );

      document.text(
        `Net: ${data.net.toFixed(2)}`,
      );

      document.moveDown();

      if (
        sections.includes(
          "revenueSummary",
        )
      ) {
        document
          .fontSize(15)
          .text(
            "Revenue Summary",
          );

        document
          .fontSize(11)
          .text(
            `Revenue: ${data.revenue.toFixed(2)}`,
          );

        document.text(
          `Expenses: ${data.expenses.toFixed(2)}`,
        );

        document.text(
          `Net: ${data.net.toFixed(2)}`,
        );

        document.moveDown();
      }

      if (
        sections.includes(
          "expenseBreakdown",
        )
      ) {
        document
          .fontSize(15)
          .text(
            "Expense Breakdown",
          );

        const totals =
          new Map<string, number>();

        for (
          const transaction
          of data.transactions
        ) {
          if (
            transaction.type !==
            "expense"
          ) {
            continue;
          }

          const category =
            transaction.category ??
            "Other";

          totals.set(
            category,
            (totals.get(
              category,
            ) ?? 0) +
              transaction.amount,
          );
        }

        document.fontSize(10);

        for (
          const [
            category,
            amount,
          ] of totals.entries()
        ) {
          document.text(
            `${category}: ${amount.toFixed(2)}`,
          );
        }

        document.moveDown();
      }

      if (
        sections.includes(
          "transactionHistory",
        )
      ) {
        document
          .fontSize(15)
          .text(
            "Transaction History",
          );

        document.fontSize(9);

        for (
          const transaction
          of data.transactions
        ) {
          document.text(
            `${transaction.date.toISOString().split("T")[0]} | ` +
              `${transaction.title} | ` +
              `${transaction.type} | ` +
              `${transaction.amount.toFixed(2)}`,
          );
        }

        document.moveDown();
      }

      if (
        sections.includes(
          "membershipStats",
        )
      ) {
        document
          .fontSize(15)
          .text(
            "Membership Stats",
          );

        const names =
          new Map(
            data.plans.map(
              (plan) => [
                plan.id,
                plan.name,
              ],
            ),
          );

        const counts =
          new Map<string, number>();

        for (
          const member
          of data.members
        ) {
          if (
            !member.membershipPlanId
          ) {
            continue;
          }

          const name =
            names.get(
              member.membershipPlanId,
            ) ??
            "Unknown";

          counts.set(
            name,
            (counts.get(
              name,
            ) ?? 0) +
              1,
          );
        }

        document.fontSize(10);

        for (
          const [
            name,
            count,
          ] of counts.entries()
        ) {
          document.text(
            `${name}: ${count}`,
          );
        }
      }

      document.end();
    },
  );
}

async function sendExportEmail({
  email,
  fileName,
  downloadUrl,
  format,
  period,
}: {
  email: string;
  fileName: string;
  downloadUrl: string;
  format: string;
  period: string;
}) {
  const host =
    process.env.FINANCE_EXPORT_SMTP_HOST;

  const port =
    Number(
      process.env.FINANCE_EXPORT_SMTP_PORT ??
        587,
    );

  const user =
    process.env.FINANCE_EXPORT_SMTP_USER;

  const password =
    process.env.FINANCE_EXPORT_SMTP_PASSWORD;

  const from =
    process.env.FINANCE_EXPORT_SMTP_FROM ??
    user;

  if (
    !host ||
    !user ||
    !password ||
    !from
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Finance export email delivery is not configured.",
    );
  }

  const transporter =
    nodemailer.createTransport({
      host,
      port,
      secure: port === 465,
      auth: {
        user,
        pass: password,
      },
    });

  await transporter.sendMail({
    from,
    to: email,
    subject:
      `SweatSync Finance Report - ${period}`,
    text:
      `Your ${format.toUpperCase()} finance report is ready.\n\n` +
      `File: ${fileName}\n\n` +
      `Download: ${downloadUrl}`,
    html:
      `<p>Your <strong>${format.toUpperCase()}</strong> finance report is ready.</p>` +
      `<p><strong>File:</strong> ${fileName}</p>` +
      `<p><a href="${downloadUrl}">Download Finance Report</a></p>`,
  });
}