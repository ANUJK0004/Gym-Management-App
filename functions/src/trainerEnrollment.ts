import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";

import {
  getFirestore,
  FieldValue,
  Timestamp,
} from "firebase-admin/firestore";

import {
  getAuth,
} from "firebase-admin/auth";

const db = getFirestore();
const auth = getAuth();

export const createTrainerEnrollment =
  onCall(async (request) => {
    // --------------------------------------------------
    // AUTHENTICATION
    // --------------------------------------------------

    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Authentication required."
      );
    }

    const data =
      request.data ?? {};

    const gymId =
      String(data.gymId ?? "").trim();

    const email =
      String(data.email ?? "")
        .trim()
        .toLowerCase();

    const displayName =
      String(data.displayName ?? "")
        .trim();

    const specialization =
      data.specialization == null
        ? null
        : String(
            data.specialization
          ).trim();

    const monthlySalary =
      Number(
        data.monthlySalary ?? 0
      );

    const startDateRaw =
      String(
        data.startDate ?? ""
      ).trim();

    // --------------------------------------------------
    // VALIDATION
    // --------------------------------------------------

    if (
      !gymId ||
      !email ||
      !displayName ||
      !startDateRaw
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Required trainer information is missing."
      );
    }

    const emailRegex =
      /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

    if (!emailRegex.test(email)) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid email address."
      );
    }

    if (
      !Number.isFinite(
        monthlySalary
      ) ||
      monthlySalary <= 0
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Monthly salary must be greater than zero."
      );
    }

    const startDate =
      new Date(startDateRaw);

    if (
      Number.isNaN(
        startDate.getTime()
      )
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Invalid trainer start date."
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

    if (
      ownerData?.role !== "owner"
    ) {
      throw new HttpsError(
        "permission-denied",
        "Only gym owners can add trainers."
      );
    }

    if (
      ownerData?.gymId !== gymId
    ) {
      throw new HttpsError(
        "permission-denied",
        "You do not manage this gym."
      );
    }

    // --------------------------------------------------
    // VERIFY GYM EXISTS
    // --------------------------------------------------

    const gymRef =
      db.collection("gyms")
        .doc(gymId);

    const gymSnap =
      await gymRef.get();

    if (!gymSnap.exists) {
      throw new HttpsError(
        "not-found",
        "Gym not found."
      );
    }

    const gymData =
      gymSnap.data();

    if (
      gymData?.ownerId !==
      request.auth.uid
    ) {
      throw new HttpsError(
        "permission-denied",
        "You do not manage this gym."
      );
    }

    // --------------------------------------------------
    // FIND FIREBASE AUTH ACCOUNT
    // --------------------------------------------------

    let existingUser:
      Awaited<
        ReturnType<
          typeof auth.getUserByEmail
        >
      > | null = null;

    try {
      existingUser =
        await auth.getUserByEmail(
          email
        );
    } catch (error: any) {
      if (
        error?.code !==
        "auth/user-not-found"
      ) {
        throw error;
      }
    }

    // --------------------------------------------------
    // EXISTING ACCOUNT VALIDATION
    // --------------------------------------------------

    let existingTrainerData:
      FirebaseFirestore.DocumentData |
      undefined;

    if (existingUser) {
      const trainerRef =
        db.collection("users")
          .doc(existingUser.uid);

      const trainerSnap =
        await trainerRef.get();

      if (!trainerSnap.exists) {
        throw new HttpsError(
          "failed-precondition",
          "An account exists for this email, but its trainer profile is missing."
        );
      }

      existingTrainerData =
        trainerSnap.data();

      if (
        existingTrainerData?.role !==
        "trainer"
      ) {
        throw new HttpsError(
          "failed-precondition",
          "This email belongs to an account that is not a trainer."
        );
      }

      const existingGymId =
        existingTrainerData?.gymId;

      if (
        existingGymId &&
        existingGymId !== gymId
      ) {
        throw new HttpsError(
          "failed-precondition",
          "This trainer belongs to another gym."
        );
      }

      if (
        existingGymId === gymId
      ) {
        throw new HttpsError(
          "already-exists",
          "This trainer is already assigned to your gym."
        );
      }
    }

    // --------------------------------------------------
    // CREATE ENROLLMENT
    // --------------------------------------------------

    const enrollmentRef =
      db.collection(
        "trainerEnrollments"
      ).doc();

    const now =
      FieldValue.serverTimestamp();

    const startTimestamp =
      Timestamp.fromDate(
        startDate
      );

    const enrollmentData = {
      gymId,
      email,
      displayName,
      specialization,
      monthlySalary,
      startDate: startTimestamp,

      status:
        "pending",

      accountStatus:
        existingUser
          ? "existing"
          : "invitationRequired",

      trainerId:
        existingUser?.uid ?? null,

      createdAt: now,
    };

    // --------------------------------------------------
    // EXISTING ACCOUNT
    // --------------------------------------------------

    if (existingUser) {
      const trainerRef =
        db.collection("users")
          .doc(existingUser.uid);

      const batch =
        db.batch();

      batch.update(
        trainerRef,
        {
          gymId,
          role: "trainer",
          displayName,
          specialization,
          monthlySalary,
          joinedAt: startTimestamp,
          status: "active",
          updatedAt: now,
        }
      );

      batch.set(
        enrollmentRef,
        enrollmentData,
      );

      batch.update(
        enrollmentRef,
        {
          status:
            "completed",
          completedAt: now,
        }
      );

      await batch.commit();

      return {
        enrollmentId:
          enrollmentRef.id,

        trainerId:
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

    await enrollmentRef.set(
      enrollmentData
    );

    // --------------------------------------------------
    // INVITATION
    // --------------------------------------------------
    //
    // We do NOT create a password here.
    //
    // The future invitation flow can:
    // 1. send an email
    // 2. provide an account setup link
    // 3. connect the created account to
    //    this enrollment document.
    //
    // For now the enrollment remains pending.
    // --------------------------------------------------

    return {
      enrollmentId:
        enrollmentRef.id,

      trainerId:
        null,

      accountStatus:
        "invitationRequired",

      status:
        "pending",
    };
  });