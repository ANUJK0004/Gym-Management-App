import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";

const db = getFirestore();
const auth = getAuth();

export const createMemberEnrollment = onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Authentication required."
      );
    }

    const data = request.data;

    const gymId = String(data.gymId ?? "");
    const email = String(data.email ?? "")
      .trim()
      .toLowerCase();

    const firstName = String(
      data.firstName ?? ""
    ).trim();

    const lastName = String(
      data.lastName ?? ""
    ).trim();

    if (!gymId ||
        !email ||
        !firstName ||
        !lastName) {
      throw new HttpsError(
        "invalid-argument",
        "Required enrollment information is missing."
      );
    }

    // --------------------------------------------------
    // VERIFY OWNER
    // --------------------------------------------------

    const ownerRef =
      db.collection("users")
        .doc(request.auth.uid);

    const ownerSnap =
      await ownerRef.get();

    if (!ownerSnap.exists) {
      throw new HttpsError(
        "permission-denied",
        "Owner profile not found."
      );
    }

    const ownerData =
      ownerSnap.data();

    if (ownerData?.role !== "owner") {
      throw new HttpsError(
        "permission-denied",
        "Only gym owners can enroll members."
      );
    }

    if (ownerData?.gymId !== gymId) {
      throw new HttpsError(
        "permission-denied",
        "You do not manage this gym."
      );
    }

    // --------------------------------------------------
    // FIND ACCOUNT
    // --------------------------------------------------

    let existingUser = null;

    try {
      existingUser =
        await auth.getUserByEmail(email);
    } catch (error: any) {
      if (error.code !== "auth/user-not-found") {
        throw error;
      }
    }

    // --------------------------------------------------
    // CREATE ENROLLMENT
    // --------------------------------------------------

    const enrollmentRef =
      db.collection("memberEnrollments")
        .doc();

    const now =
      FieldValue.serverTimestamp();

    const enrollmentData = {
      gymId,

      email,

      firstName,

      lastName,

      phone:
        data.phone ?? null,

      dateOfBirth:
        data.dateOfBirth ?? null,

      gender:
        data.gender ?? null,

      fitnessGoal:
        data.fitnessGoal ?? null,

      membershipPlanId:
        String(
          data.membershipPlanId ?? ""
        ),

      membershipPlanName:
        String(
          data.membershipPlanName ?? ""
        ),

      amount:
        Number(data.amount ?? 0),

      paymentMethod:
        String(
          data.paymentMethod ?? ""
        ),

      startDate:
        data.startDate ?? null,

      status:
        "pending",

      accountStatus:
        existingUser
          ? "existing"
          : "invitationRequired",

      memberId:
        existingUser?.uid ?? null,

      createdAt:
        now,
    };

    await enrollmentRef.set(
      enrollmentData
    );

    // --------------------------------------------------
    // EXISTING ACCOUNT
    // --------------------------------------------------

    if (existingUser) {
      const memberRef =
        db.collection("users")
          .doc(existingUser.uid);

      const memberSnap =
        await memberRef.get();

      if (!memberSnap.exists) {
        throw new HttpsError(
          "not-found",
          "Member profile not found."
        );
      }

      const memberData =
        memberSnap.data();

      if (memberData?.role !== "member") {
        throw new HttpsError(
          "failed-precondition",
          "This account is not a member account."
        );
      }

      const existingGymId =
        memberData?.gymId;

      if (existingGymId &&
          existingGymId !== gymId) {
        throw new HttpsError(
          "failed-precondition",
          "This member belongs to another gym."
        );
      }

      if (existingGymId === gymId) {
        throw new HttpsError(
          "already-exists",
          "This member is already enrolled."
        );
      }

      // ----------------------------------------------
      // ATOMIC MEMBER UPDATE
      // ----------------------------------------------

      const batch =
        db.batch();

      batch.update(
        memberRef,
        {
          gymId,
          joinedAt: now,
          membershipPlanId:
            enrollmentData.membershipPlanId,
          membershipStatus:
            "active",
        }
      );

      batch.update(
        enrollmentRef,
        {
          status: "completed",
          completedAt: now,
        }
      );

      // ----------------------------------------------
      // FINANCE
      // ----------------------------------------------

      const transactionRef =
        db.collection("gyms")
          .doc(gymId)
          .collection("financeTransactions")
          .doc();

      batch.set(
        transactionRef,
        {
          gymId,
          title:
            `${firstName} ${lastName} - ` +
            `${enrollmentData.membershipPlanName}`,

          amount:
            enrollmentData.amount,

          type: "income",

          category:
            "Membership",

          description:
            "Membership enrollment payment",

          memberId:
            existingUser.uid,

          membershipPlanId:
            enrollmentData.membershipPlanId,

          date:
            now,
        }
      );

      await batch.commit();

      return {
        enrollmentId:
          enrollmentRef.id,

        memberId:
          existingUser.uid,

        accountStatus:
          "existing",

        status:
          "completed",
      };
    }

    // --------------------------------------------------
    // NEW ACCOUNT
    // --------------------------------------------------

    // IMPORTANT:
    // Do NOT create a password for the member here.
    //
    // An invitation should be sent through your
    // email provider / invitation system.

    return {
      enrollmentId:
        enrollmentRef.id,

      memberId:
        null,

      accountStatus:
        "invitationRequired",

      status:
        "pending",
    };
  }
);