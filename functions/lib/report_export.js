"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.exportReport = void 0;
const https_1 = require("firebase-functions/v2/https");
const params_1 = require("firebase-functions/params");
const firestore_1 = require("firebase-admin/firestore");
const storage_1 = require("firebase-admin/storage");
const exceljs_1 = require("exceljs");
const pdfkit_1 = __importDefault(require("pdfkit"));
const stream_1 = require("stream");
const nodemailer_1 = __importDefault(require("nodemailer"));
const db = (0, firestore_1.getFirestore)();
const bucket = (0, storage_1.getStorage)().bucket();
const SMTP_HOST = (0, params_1.defineSecret)("SMTP_HOST");
const SMTP_PORT = (0, params_1.defineSecret)("SMTP_PORT");
const SMTP_USER = (0, params_1.defineSecret)("SMTP_USER");
const SMTP_PASSWORD = (0, params_1.defineSecret)("SMTP_PASSWORD");
const REPORT_FROM_EMAIL = (0, params_1.defineSecret)("REPORT_FROM_EMAIL");
exports.exportReport = (0, https_1.onCall)({
    secrets: [
        SMTP_HOST,
        SMTP_PORT,
        SMTP_USER,
        SMTP_PASSWORD,
        REPORT_FROM_EMAIL,
    ],
}, async (request) => {
    // --------------------------------------------------------
    // AUTH
    // --------------------------------------------------------
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Authentication required.");
    }
    const data = request.data;
    const reportType = parseReportType(data.reportType);
    const format = parseFormat(data.format);
    const period = parsePeriod(data.period);
    const sections = Array.isArray(data.sections)
        ? data.sections
            .map(String)
            .filter((value) => value.trim().length > 0)
        : [];
    const email = data.email == null
        ? null
        : String(data.email)
            .trim()
            .toLowerCase();
    if (email != null &&
        !isValidEmail(email)) {
        throw new https_1.HttpsError("invalid-argument", "Please enter a valid email address.");
    }
    // --------------------------------------------------------
    // OWNER
    // --------------------------------------------------------
    const ownerRef = db.collection("users")
        .doc(request.auth.uid);
    const ownerSnap = await ownerRef.get();
    if (!ownerSnap.exists) {
        throw new https_1.HttpsError("permission-denied", "Owner profile not found.");
    }
    const ownerData = ownerSnap.data();
    if (ownerData?.role !== "owner") {
        throw new https_1.HttpsError("permission-denied", "Only gym owners can export reports.");
    }
    const gymId = String(ownerData.gymId ?? "")
        .trim();
    if (!gymId) {
        throw new https_1.HttpsError("failed-precondition", "The owner is not associated with a gym.");
    }
    // --------------------------------------------------------
    // PERIOD
    // --------------------------------------------------------
    const range = calculatePeriod(period);
    // --------------------------------------------------------
    // DATA
    // --------------------------------------------------------
    const [members, trainers, transactions, attendance, plans, npsResponses,] = await Promise.all([
        getMembers(gymId),
        getTrainers(gymId),
        getTransactions(gymId),
        getAttendance(gymId),
        getMembershipPlans(gymId),
        getNpsResponses(gymId),
    ]);
    // --------------------------------------------------------
    // REPORT DATA
    // --------------------------------------------------------
    const reportData = buildReportData({
        reportType,
        sections,
        range,
        members,
        trainers,
        transactions,
        attendance,
        plans,
        npsResponses,
    });
    // --------------------------------------------------------
    // FILE
    // --------------------------------------------------------
    const timestamp = Date.now();
    const extension = format === "pdf"
        ? "pdf"
        : format === "excel"
            ? "xlsx"
            : "csv";
    const safeType = reportType.replace(/[^a-zA-Z0-9_-]/g, "");
    const fileName = `${safeType}_${timestamp}.${extension}`;
    const storagePath = `reports/${gymId}/${fileName}`;
    let fileBuffer;
    let contentType;
    if (format === "pdf") {
        fileBuffer =
            await generatePdf(reportType, range.label, reportData);
        contentType =
            "application/pdf";
    }
    else if (format === "excel") {
        fileBuffer =
            await generateExcel(reportType, range.label, reportData);
        contentType =
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
    }
    else {
        fileBuffer =
            Buffer.from(generateCsv(reportType, range.label, reportData), "utf8");
        contentType =
            "text/csv";
    }
    // --------------------------------------------------------
    // CLOUD STORAGE
    // --------------------------------------------------------
    const file = bucket.file(storagePath);
    await file.save(fileBuffer, {
        resumable: false,
        metadata: {
            contentType,
            contentDisposition: `attachment; filename="${fileName}"`,
            metadata: {
                reportType,
                period: range.label,
                generatedBy: request.auth.uid,
            },
        },
    });
    // --------------------------------------------------------
    // SIGNED URL
    // --------------------------------------------------------
    const expiresAt = new Date(Date.now() +
        30 * 60 * 1000);
    const signedUrlResult = await file.getSignedUrl({
        version: "v4",
        action: "read",
        expires: expiresAt,
    });
    const downloadUrl = signedUrlResult[0];
    // --------------------------------------------------------
    // OPTIONAL EMAIL
    // --------------------------------------------------------
    let emailSent = false;
    if (email) {
        await sendReportEmail({
            email,
            downloadUrl,
            reportType,
            periodLabel: range.label,
            fileName,
        });
        emailSent = true;
    }
    // --------------------------------------------------------
    // AUDIT RECORD
    // --------------------------------------------------------
    const exportRef = db.collection("reportExports").doc();
    await exportRef.set({
        gymId,
        ownerId: request.auth.uid,
        reportType,
        format,
        sections,
        period: period,
        periodLabel: range.label,
        fileName,
        storagePath,
        email,
        emailSent,
        createdAt: firestore_1.FieldValue.serverTimestamp(),
        expiresAt: firestore_1.Timestamp.fromDate(expiresAt),
    });
    return {
        downloadUrl,
        fileName,
        format,
        reportType,
        periodLabel: range.label,
        expiresAt: expiresAt.toISOString(),
        email,
        emailSent,
    };
});
// ============================================================
// DATA FETCHERS
// ============================================================
async function getMembers(gymId) {
    const snapshot = await db.collection("users")
        .where("gymId", "==", gymId)
        .get();
    return snapshot.docs
        .filter((doc) => doc.data().role === "member")
        .map((doc) => ({
        _id: doc.id,
        ...doc.data(),
    }));
}
async function getTrainers(gymId) {
    const snapshot = await db.collection("users")
        .where("gymId", "==", gymId)
        .get();
    return snapshot.docs
        .filter((doc) => doc.data().role === "trainer")
        .map((doc) => ({
        _id: doc.id,
        ...doc.data(),
    }));
}
async function getTransactions(gymId) {
    const snapshot = await db.collection("gyms")
        .doc(gymId)
        .collection("financeTransactions")
        .get();
    return snapshot.docs.map((doc) => ({
        _id: doc.id,
        ...doc.data(),
    }));
}
async function getMembershipPlans(gymId) {
    const snapshot = await db.collection("gyms")
        .doc(gymId)
        .collection("membershipPlans")
        .get();
    return snapshot.docs.map((doc) => ({
        _id: doc.id,
        ...doc.data(),
    }));
}
async function getAttendance(gymId) {
    const records = [];
    try {
        const root = await db.collection("attendance")
            .where("gymId", "==", gymId)
            .get();
        records.push(...root.docs.map((doc) => ({
            _id: doc.id,
            ...doc.data(),
        })));
    }
    catch (_) { }
    try {
        const nested = await db.collection("gyms")
            .doc(gymId)
            .collection("attendance")
            .get();
        records.push(...nested.docs.map((doc) => ({
            _id: doc.id,
            ...doc.data(),
        })));
    }
    catch (_) { }
    return records;
}
async function getNpsResponses(gymId) {
    try {
        const snapshot = await db.collection("npsResponses")
            .where("gymId", "==", gymId)
            .get();
        return snapshot.docs.map((doc) => ({
            _id: doc.id,
            ...doc.data(),
        }));
    }
    catch (_) {
        return [];
    }
}
// ============================================================
// PERIOD
// ============================================================
function calculatePeriod(period) {
    const now = new Date();
    switch (period) {
        case "thisWeek": {
            const day = now.getDay();
            const distance = day === 0
                ? 6
                : day - 1;
            const start = new Date(now.getFullYear(), now.getMonth(), now.getDate() -
                distance);
            const end = new Date(start);
            end.setDate(start.getDate() + 7);
            return {
                start,
                end,
                label: "This Week",
            };
        }
        case "thisMonth": {
            const start = new Date(now.getFullYear(), now.getMonth(), 1);
            const end = new Date(now.getFullYear(), now.getMonth() + 1, 1);
            return {
                start,
                end,
                label: `${monthName(now.getMonth())} ${now.getFullYear()}`,
            };
        }
        case "lastMonth": {
            const start = new Date(now.getFullYear(), now.getMonth() - 1, 1);
            const end = new Date(now.getFullYear(), now.getMonth(), 1);
            return {
                start,
                end,
                label: `Last Month · ${monthName(start.getMonth())} ${start.getFullYear()}`,
            };
        }
        case "thisQuarter": {
            const quarter = Math.floor(now.getMonth() / 3);
            const start = new Date(now.getFullYear(), quarter * 3, 1);
            const end = new Date(now.getFullYear(), quarter * 3 + 3, 1);
            return {
                start,
                end,
                label: `Q${quarter + 1} ${now.getFullYear()}`,
            };
        }
        case "lastQuarter": {
            const currentQuarter = Math.floor(now.getMonth() / 3);
            const start = new Date(now.getFullYear(), (currentQuarter - 1) * 3, 1);
            const end = new Date(now.getFullYear(), currentQuarter * 3, 1);
            return {
                start,
                end,
                label: `Q${currentQuarter === 0 ? 4 : currentQuarter} ${start.getFullYear()}`,
            };
        }
        case "thisYear": {
            const start = new Date(now.getFullYear(), 0, 1);
            const end = new Date(now.getFullYear() + 1, 0, 1);
            return {
                start,
                end,
                label: `${now.getFullYear()}`,
            };
        }
    }
}
// ============================================================
// REPORT DATA
// ============================================================
function buildReportData({ reportType, sections, range, members, trainers, transactions, attendance, plans, npsResponses, }) {
    const sectionSet = new Set(sections);
    const includeAll = sections.length === 0 ||
        reportType === "full";
    const result = {};
    if (includeAll ||
        reportType === "finance" ||
        sectionSet.has("revenue") ||
        sectionSet.has("expenses")) {
        result.finance =
            buildFinanceRows(transactions, range);
    }
    if (includeAll ||
        reportType === "members" ||
        sectionSet.has("members") ||
        sectionSet.has("retention") ||
        sectionSet.has("churn")) {
        result.members =
            buildMemberRows(members, range, plans);
    }
    if (includeAll ||
        reportType === "staff" ||
        sectionSet.has("trainerSessions") ||
        sectionSet.has("clientRatings") ||
        sectionSet.has("performanceScores")) {
        result.trainers =
            buildTrainerRows(trainers);
    }
    if (includeAll ||
        reportType === "operations" ||
        sectionSet.has("attendanceRate") ||
        sectionSet.has("peakHours")) {
        result.attendance =
            buildAttendanceRows(attendance, range);
    }
    if (includeAll ||
        sectionSet.has("nps") ||
        sectionSet.has("clientRatings")) {
        result.nps =
            buildNpsRows(npsResponses, range);
    }
    return result;
}
function buildFinanceRows(transactions, range) {
    return transactions
        .filter((transaction) => {
        const date = toDate(transaction.date);
        return (date != null &&
            date >= range.start &&
            date < range.end);
    })
        .map((transaction) => ({
        Date: toDate(transaction.date)
            ?.toISOString() ?? "",
        Title: String(transaction.title ?? ""),
        Amount: Number(transaction.amount ?? 0),
        Type: String(transaction.type ?? ""),
        Category: String(transaction.category ?? ""),
        MemberID: String(transaction.memberId ?? ""),
    }));
}
function buildMemberRows(members, range, plans) {
    const planNames = new Map();
    for (const plan of plans) {
        planNames.set(String(plan._id ?? ""), String(plan.name ?? "Other"));
    }
    return members
        .filter((member) => {
        const joined = toDate(member.joinedAt);
        return (joined != null &&
            joined >= range.start &&
            joined < range.end);
    })
        .map((member) => ({
        MemberID: String(member._id ?? ""),
        Name: String(member.displayName ?? ""),
        Email: String(member.email ?? ""),
        Plan: planNames.get(String(member.membershipPlanId ?? "")) ?? "None",
        Status: String(member.membershipStatus ?? ""),
        JoinedAt: toDate(member.joinedAt)?.toISOString() ?? "",
    }));
}
function buildTrainerRows(trainers) {
    return trainers.map((trainer) => ({
        TrainerID: String(trainer._id ?? ""),
        Name: String(trainer.displayName ?? ""),
        Email: String(trainer.email ?? ""),
        Specialization: String(trainer.specialization ?? ""),
        Clients: Number(trainer.clientCount ?? 0),
        Sessions: Number(trainer.sessionCount ?? 0),
        Rating: Number(trainer.rating ?? 0),
        MonthlySalary: Number(trainer.monthlySalary ?? 0),
        Status: String(trainer.status ?? ""),
    }));
}
function buildAttendanceRows(attendance, range) {
    return attendance
        .map((record) => {
        const date = attendanceDate(record);
        return {
            record,
            date,
        };
    })
        .filter(({ date }) => date != null &&
        date >= range.start &&
        date < range.end)
        .map(({ record, date }) => ({
        AttendanceID: String(record._id ?? ""),
        MemberID: String(record.memberId ?? ""),
        Timestamp: date.toISOString(),
    }));
}
function buildNpsRows(responses, range) {
    return responses
        .map((response) => {
        const date = toDate(response.createdAt) ??
            toDate(response.date);
        return {
            response,
            date,
        };
    })
        .filter(({ date }) => date != null &&
        date >= range.start &&
        date < range.end)
        .map(({ response, date }) => ({
        Date: date.toISOString(),
        Score: Number(response.score ??
            response.rating ??
            0),
        MemberID: String(response.memberId ?? ""),
    }));
}
// ============================================================
// CSV
// ============================================================
function generateCsv(reportType, periodLabel, data) {
    const rows = [];
    rows.push([
        "SweepSync Report",
    ]);
    rows.push([
        `Type: ${reportType}`,
    ]);
    rows.push([
        `Period: ${periodLabel}`,
    ]);
    rows.push([]);
    for (const [section, sectionRows,] of Object.entries(data)) {
        rows.push([
            section.toUpperCase(),
        ]);
        if (sectionRows.length === 0) {
            rows.push([
                "No data",
            ]);
            rows.push([]);
            continue;
        }
        const headers = Object.keys(sectionRows[0]);
        rows.push(headers);
        for (const row of sectionRows) {
            rows.push(headers.map((header) => String(row[header] ?? "")));
        }
        rows.push([]);
    }
    return rows
        .map((row) => row
        .map(escapeCsv)
        .join(","))
        .join("\n");
}
function escapeCsv(value) {
    if (value.includes(",") ||
        value.includes('"') ||
        value.includes("\n")) {
        return `"${value.replaceAll('"', '""')}"`;
    }
    return value;
}
// ============================================================
// EXCEL
// ============================================================
async function generateExcel(reportType, periodLabel, data) {
    const workbook = new exceljs_1.Workbook();
    workbook.creator =
        "SweatSync";
    workbook.created =
        new Date();
    for (const [section, rows,] of Object.entries(data)) {
        const sheet = workbook.addWorksheet(normalizeSheetName(section));
        sheet.addRow([
            `SweatSync ${reportType} Report`,
        ]);
        sheet.addRow([
            `Period: ${periodLabel}`,
        ]);
        sheet.addRow([]);
        if (rows.length === 0) {
            sheet.addRow([
                "No data",
            ]);
            continue;
        }
        const headers = Object.keys(rows[0]);
        sheet.addRow(headers);
        for (const row of rows) {
            sheet.addRow(headers.map((header) => row[header] ?? ""));
        }
        sheet.getRow(4).font = {
            bold: true,
        };
        sheet.columns =
            headers.map((header) => ({
                header,
                key: header,
                width: 20,
            }));
    }
    const buffer = await workbook.xlsx
        .writeBuffer();
    return Buffer.from(buffer);
}
function normalizeSheetName(value) {
    const normalized = value
        .replace(/[*?:/\\[\]]/g, "")
        .substring(0, 31);
    return normalized || "Report";
}
// ============================================================
// PDF
// ============================================================
async function generatePdf(reportType, periodLabel, data) {
    const document = new pdfkit_1.default({
        margin: 40,
    });
    const stream = new stream_1.PassThrough();
    const chunks = [];
    stream.on("data", (chunk) => chunks.push(Buffer.from(chunk)));
    document.pipe(stream);
    document
        .fontSize(20)
        .text("SweatSync Report");
    document
        .moveDown(0.5)
        .fontSize(11)
        .text(`Report: ${reportType}`);
    document
        .fontSize(11)
        .text(`Period: ${periodLabel}`);
    document.moveDown();
    for (const [section, rows,] of Object.entries(data)) {
        document
            .fontSize(15)
            .text(section.toUpperCase());
        document.moveDown(0.3);
        if (rows.length === 0) {
            document
                .fontSize(10)
                .text("No data available.");
            document.moveDown();
            continue;
        }
        const headers = Object.keys(rows[0]);
        for (const row of rows) {
            const line = headers
                .map((header) => `${header}: ${row[header] ?? ""}`)
                .join(" | ");
            document
                .fontSize(8)
                .text(line);
            if (document.y >
                740) {
                document.addPage();
            }
        }
        document.moveDown();
    }
    document.end();
    await new Promise((resolve, reject) => {
        stream.on("finish", () => resolve());
        stream.on("error", reject);
    });
    return Buffer.concat(chunks);
}
// ============================================================
// EMAIL
// ============================================================
async function sendReportEmail({ email, downloadUrl, reportType, periodLabel, fileName, }) {
    const host = SMTP_HOST.value();
    const port = Number(SMTP_PORT.value());
    const user = SMTP_USER.value();
    const password = SMTP_PASSWORD.value();
    const from = REPORT_FROM_EMAIL.value() ||
        user;
    if (!host ||
        !port ||
        !user ||
        !password ||
        !from) {
        throw new https_1.HttpsError("failed-precondition", "Email delivery is not configured.");
    }
    const transporter = nodemailer_1.default.createTransport({
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
        subject: `SweatSync ${reportType} report · ${periodLabel}`,
        text: `Your SweatSync report is ready.\n\n` +
            `Report: ${reportType}\n` +
            `Period: ${periodLabel}\n` +
            `File: ${fileName}\n\n` +
            `Download it here:\n${downloadUrl}\n\n` +
            `This download link expires in 30 minutes.`,
        html: `<h2>SweatSync Report Ready</h2>` +
            `<p><strong>Report:</strong> ${reportType}</p>` +
            `<p><strong>Period:</strong> ${periodLabel}</p>` +
            `<p><strong>File:</strong> ${fileName}</p>` +
            `<p>` +
            `<a href="${downloadUrl}">Download Report</a>` +
            `</p>` +
            `<p>This download link expires in 30 minutes.</p>`,
    });
}
// ============================================================
// VALIDATION / HELPERS
// ============================================================
function parseReportType(value) {
    const valid = [
        "finance",
        "members",
        "staff",
        "operations",
        "full",
    ];
    const parsed = String(value ?? "");
    if (!valid.includes(parsed)) {
        throw new https_1.HttpsError("invalid-argument", "Invalid report type.");
    }
    return parsed;
}
function parseFormat(value) {
    const valid = [
        "pdf",
        "excel",
        "csv",
    ];
    const parsed = String(value ?? "");
    if (!valid.includes(parsed)) {
        throw new https_1.HttpsError("invalid-argument", "Invalid export format.");
    }
    return parsed;
}
function parsePeriod(value) {
    const valid = [
        "thisWeek",
        "thisMonth",
        "lastMonth",
        "thisQuarter",
        "lastQuarter",
        "thisYear",
    ];
    const parsed = String(value ?? "");
    if (!valid.includes(parsed)) {
        throw new https_1.HttpsError("invalid-argument", "Invalid report period.");
    }
    return parsed;
}
function isValidEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/
        .test(email);
}
function toDate(value) {
    if (!value) {
        return null;
    }
    if (value instanceof firestore_1.Timestamp) {
        return value.toDate();
    }
    if (value?.toDate instanceof Function) {
        return value.toDate();
    }
    if (value instanceof Date) {
        return value;
    }
    if (typeof value === "string") {
        const date = new Date(value);
        return Number.isNaN(date.getTime())
            ? null
            : date;
    }
    return null;
}
function attendanceDate(record) {
    const fields = [
        "checkInAt",
        "checkedInAt",
        "checkInTime",
        "timestamp",
        "date",
    ];
    for (const field of fields) {
        const date = toDate(record[field]);
        if (date) {
            return date;
        }
    }
    return null;
}
function monthName(month) {
    return [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
    ][month];
}
//# sourceMappingURL=report_export.js.map