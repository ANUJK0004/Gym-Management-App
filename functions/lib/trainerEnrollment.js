"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createTrainerEnrollment = void 0;
const https_1 = require("firebase-functions/v2/https");
const firestore_1 = require("firebase-admin/firestore");
const auth_1 = require("firebase-admin/auth");
const db = (0, firestore_1.getFirestore)();
const auth = (0, auth_1.getAuth)();
exports.createTrainerEnrollment = (0, https_1.onCall)(async (request) => {
    // --------------------------------------------------
    // AUTHENTICATION
    // --------------------------------------------------
    if (!request.auth) {
        throw new https_1.HttpsError("unauthenticated", "Authentication required.");
    }
    const data = request.data ?? {};
    const gymId = String(data.gymId ?? "").trim();
    const email = String(data.email ?? "")
        .trim()
        .toLowerCase();
    const displayName = String(data.displayName ?? "")
        .trim();
    const specialization = data.specialization == null
        ? null
        : String(data.specialization).trim();
    const monthlySalary = Number(data.monthlySalary ?? 0);
    const startDateRaw = String(data.startDate ?? "").trim();
    // --------------------------------------------------
    // VALIDATION
    // --------------------------------------------------
    if (!gymId ||
        !email ||
        !displayName ||
        !startDateRaw) {
        throw new https_1.HttpsError("invalid-argument", "Required trainer information is missing.");
    }
    const emailRegex = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;
    if (!emailRegex.test(email)) {
        throw new https_1.HttpsError("invalid-argument", "Invalid email address.");
    }
    if (!Number.isFinite(monthlySalary) ||
        monthlySalary <= 0) {
        throw new https_1.HttpsError("invalid-argument", "Monthly salary must be greater than zero.");
    }
    const startDate = new Date(startDateRaw);
    if (Number.isNaN(startDate.getTime())) {
        throw new https_1.HttpsError("invalid-argument", "Invalid trainer start date.");
    }
    // --------------------------------------------------
    // VERIFY OWNER
    // --------------------------------------------------
    const ownerRef = db.collection("users")
        .doc(request.auth.uid);
    const ownerSnap = await ownerRef.get();
    if (!ownerSnap.exists) {
        throw new https_1.HttpsError("permission-denied", "Owner profile not found.");
    }
    const ownerData = ownerSnap.data();
    if (ownerData?.role !== "owner") {
        throw new https_1.HttpsError("permission-denied", "Only gym owners can add trainers.");
    }
    if (ownerData?.gymId !== gymId) {
        throw new https_1.HttpsError("permission-denied", "You do not manage this gym.");
    }
    // --------------------------------------------------
    // VERIFY GYM EXISTS
    // --------------------------------------------------
    const gymRef = db.collection("gyms")
        .doc(gymId);
    const gymSnap = await gymRef.get();
    if (!gymSnap.exists) {
        throw new https_1.HttpsError("not-found", "Gym not found.");
    }
    const gymData = gymSnap.data();
    if (gymData?.ownerId !==
        request.auth.uid) {
        throw new https_1.HttpsError("permission-denied", "You do not manage this gym.");
    }
    // --------------------------------------------------
    // FIND FIREBASE AUTH ACCOUNT
    // --------------------------------------------------
    let existingUser = null;
    try {
        existingUser =
            await auth.getUserByEmail(email);
    }
    catch (error) {
        if (error?.code !==
            "auth/user-not-found") {
            throw error;
        }
    }
    // --------------------------------------------------
    // EXISTING ACCOUNT VALIDATION
    // --------------------------------------------------
    let existingTrainerData;
    if (existingUser) {
        const trainerRef = db.collection("users")
            .doc(existingUser.uid);
        const trainerSnap = await trainerRef.get();
        if (!trainerSnap.exists) {
            throw new https_1.HttpsError("failed-precondition", "An account exists for this email, but its trainer profile is missing.");
        }
        existingTrainerData =
            trainerSnap.data();
        if (existingTrainerData?.role !==
            "trainer") {
            throw new https_1.HttpsError("failed-precondition", "This email belongs to an account that is not a trainer.");
        }
        const existingGymId = existingTrainerData?.gymId;
        if (existingGymId &&
            existingGymId !== gymId) {
            throw new https_1.HttpsError("failed-precondition", "This trainer belongs to another gym.");
        }
        if (existingGymId === gymId) {
            throw new https_1.HttpsError("already-exists", "This trainer is already assigned to your gym.");
        }
    }
    // --------------------------------------------------
    // CREATE ENROLLMENT
    // --------------------------------------------------
    const enrollmentRef = db.collection("trainerEnrollments").doc();
    const now = firestore_1.FieldValue.serverTimestamp();
    const startTimestamp = firestore_1.Timestamp.fromDate(startDate);
    const enrollmentData = {
        gymId,
        email,
        displayName,
        specialization,
        monthlySalary,
        startDate: startTimestamp,
        status: "pending",
        accountStatus: existingUser
            ? "existing"
            : "invitationRequired",
        trainerId: existingUser?.uid ?? null,
        createdAt: now,
    };
    // --------------------------------------------------
    // EXISTING ACCOUNT
    // --------------------------------------------------
    if (existingUser) {
        const trainerRef = db.collection("users")
            .doc(existingUser.uid);
        const batch = db.batch();
        batch.update(trainerRef, {
            gymId,
            role: "trainer",
            displayName,
            specialization,
            monthlySalary,
            joinedAt: startTimestamp,
            status: "active",
            updatedAt: now,
        });
        batch.set(enrollmentRef, enrollmentData);
        batch.update(enrollmentRef, {
            status: "completed",
            completedAt: now,
        });
        await batch.commit();
        return {
            enrollmentId: enrollmentRef.id,
            trainerId: existingUser.uid,
            accountStatus: "existing",
            status: "completed",
        };
    }
    // --------------------------------------------------
    // NEW ACCOUNT
    // --------------------------------------------------
    await enrollmentRef.set(enrollmentData);
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
        enrollmentId: enrollmentRef.id,
        trainerId: null,
        accountStatus: "invitationRequired",
        status: "pending",
    };
});
//# sourceMappingURL=trainerEnrollment.js.map