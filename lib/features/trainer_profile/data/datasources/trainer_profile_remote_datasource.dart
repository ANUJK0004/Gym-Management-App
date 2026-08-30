import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/trainer_profile.dart';
import '../models/trainer_profile_model.dart';

class TrainerProfileRemoteDataSource {
  TrainerProfileRemoteDataSource([
    this._firestore,
    this._auth,
  ]);

  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  static const TrainerProfileModel _defaultProfile = TrainerProfileModel(
    id: 'trainer_001',
    name: 'Coach Mike Torres',
    title: 'Senior Personal Trainer',
    email: 'mike.torres@gymsync.com',
    initials: 'MT',
    isVerified: true,
    rating: 4.9,
    reviewCount: 128,
    clientCount: 5,
    experienceYears: 3.2,
    sessionCount: 142,
    specializations: [
      'Strength & Conditioning',
      'HIIT',
      'Weight Loss',
      'Athletic Performance',
      'Nutrition Coaching',
    ],
    certifications: [
      TrainerCertificationModel(
        id: 'cert_001',
        title: 'NSCA Certified Personal Trainer',
        obtainedYear: 2019,
        emoji: '🏅',
        isVerified: true,
      ),
      TrainerCertificationModel(
        id: 'cert_002',
        title: 'Precision Nutrition Level 1',
        obtainedYear: 2020,
        emoji: '🥗',
        isVerified: true,
      ),
      TrainerCertificationModel(
        id: 'cert_003',
        title: 'TRX Suspension Training',
        obtainedYear: 2021,
        emoji: '🧬',
        isVerified: true,
      ),
      TrainerCertificationModel(
        id: 'cert_004',
        title: 'First Aid & CPR Certified',
        obtainedYear: 2023,
        emoji: '🩺',
        isVerified: true,
      ),
    ],
    monthlyMetrics: TrainerMonthlyMetricsModel(
      sessionsCompleted: 38,
      clientRetentionPercentage: 96,
      avgSessionRating: 4.9,
      newClientsCount: 2,
    ),
    availability: TrainerAvailabilityModel(
      workingHours: '8AM–6PM',
      daysAvailable: 'Mon–Sat',
      sessionDuration: '45–60 min',
    ),
    accountSettings: TrainerAccountSettingsModel(
      notificationsEnabled: true,
      clientMessagingEnabled: true,
    ),
  );

  static TrainerProfileModel _currentProfile = _defaultProfile;

  static void resetToDefault() {
    _currentProfile = _defaultProfile;
  }

  CollectionReference<Map<String, dynamic>>? get _usersCollection =>
      _firestore?.collection('users');

  String resolveEffectiveTrainerId(String? trainerId) {
    if (trainerId != null && trainerId.isNotEmpty) {
      return trainerId;
    }
    return _auth?.currentUser?.uid ?? 'trainer_001';
  }

  // ===========================================================================
  // REAL-TIME STREAM WATCH PROFILE
  // ===========================================================================

  Stream<TrainerProfileModel> watchProfile({String? trainerId}) {
    final effectiveId = resolveEffectiveTrainerId(trainerId);
    final collection = _usersCollection;

    if (collection == null) {
      return Stream.value(_currentProfile);
    }

    return collection.doc(effectiveId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        // Asynchronously trigger auto-seed if doc doesn't exist
        _seedStarterProfile(effectiveId);
        return _buildDefaultModelForId(effectiveId);
      }
      return TrainerProfileModel.fromFirestore(snapshot);
    });
  }

  // ===========================================================================
  // GET PROFILE (WITH AUTO-SEEDING)
  // ===========================================================================

  Future<TrainerProfileModel> getProfile({String? trainerId}) async {
    final effectiveId = resolveEffectiveTrainerId(trainerId);
    final collection = _usersCollection;

    if (collection == null) {
      await Future.delayed(const Duration(milliseconds: 100));
      return _currentProfile;
    }

    try {
      final doc = await collection.doc(effectiveId).get();
      if (!doc.exists || doc.data() == null) {
        await _seedStarterProfile(effectiveId);
        final freshDoc = await collection.doc(effectiveId).get();
        if (freshDoc.exists && freshDoc.data() != null) {
          return TrainerProfileModel.fromFirestore(freshDoc);
        }
        return _buildDefaultModelForId(effectiveId);
      }

      final data = doc.data()!;
      // If document exists but is missing extended trainer profile fields, seed them
      if (!data.containsKey('certifications') || !data.containsKey('monthlyMetrics')) {
        await _seedStarterProfile(effectiveId, preserveExistingUserFields: true);
        final freshDoc = await collection.doc(effectiveId).get();
        return TrainerProfileModel.fromFirestore(freshDoc);
      }

      return TrainerProfileModel.fromFirestore(doc);
    } catch (_) {
      return _currentProfile;
    }
  }

  // ===========================================================================
  // UPDATE PROFILE
  // ===========================================================================

  Future<TrainerProfileModel> updateProfile(TrainerProfileModel updated) async {
    _currentProfile = updated;
    final collection = _usersCollection;

    if (collection != null) {
      final docRef = collection.doc(updated.id);
      await docRef.set(
        updated.toFirestore(),
        SetOptions(merge: true),
      );

      // Also update auth user displayName if changed and currentUser is active
      try {
        final currentUser = _auth?.currentUser;
        if (currentUser != null && currentUser.uid == updated.id) {
          if (updated.name.isNotEmpty && currentUser.displayName != updated.name) {
            await currentUser.updateDisplayName(updated.name);
          }
        }
      } catch (_) {}
    } else {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return updated;
  }

  // ===========================================================================
  // TARGETED UPDATES
  // ===========================================================================

  Future<void> updateAvailability({
    required String trainerId,
    required TrainerAvailability availability,
  }) async {
    final effectiveId = resolveEffectiveTrainerId(trainerId);
    final collection = _usersCollection;

    final availabilityModel = TrainerAvailabilityModel(
      workingHours: availability.workingHours,
      daysAvailable: availability.daysAvailable,
      sessionDuration: availability.sessionDuration,
    );

    _currentProfile = _currentProfile.copyWith(availability: availability);

    if (collection != null) {
      await collection.doc(effectiveId).set({
        'availability': availabilityModel.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateAccountSettings({
    required String trainerId,
    required TrainerAccountSettings settings,
  }) async {
    final effectiveId = resolveEffectiveTrainerId(trainerId);
    final collection = _usersCollection;

    final settingsModel = TrainerAccountSettingsModel(
      notificationsEnabled: settings.notificationsEnabled,
      clientMessagingEnabled: settings.clientMessagingEnabled,
    );

    _currentProfile = _currentProfile.copyWith(accountSettings: settings);

    if (collection != null) {
      await collection.doc(effectiveId).set({
        'accountSettings': settingsModel.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // ===========================================================================
  // SEEDING HELPERS
  // ===========================================================================

  TrainerProfileModel _buildDefaultModelForId(String trainerId) {
    final authUser = _auth?.currentUser;
    final name = authUser?.displayName?.trim();
    final email = authUser?.email?.trim();

    return _defaultProfile.copyWith(
      id: trainerId,
      name: (name != null && name.isNotEmpty) ? name : _defaultProfile.name,
      email: (email != null && email.isNotEmpty) ? email : _defaultProfile.email,
    );
  }

  Future<void> _seedStarterProfile(
    String trainerId, {
    bool preserveExistingUserFields = false,
  }) async {
    final collection = _usersCollection;
    if (collection == null) return;

    try {
      final docRef = collection.doc(trainerId);
      final existingDoc = await docRef.get();
      final existingData = existingDoc.data() ?? {};

      final authUser = _auth?.currentUser;
      final effectiveName = (existingData['displayName'] as String?) ??
          (existingData['name'] as String?) ??
          authUser?.displayName ??
          'Coach Mike Torres';

      final effectiveEmail = (existingData['email'] as String?) ??
          authUser?.email ??
          'mike.torres@gymsync.com';

      final seedModel = TrainerProfileModel(
        id: trainerId,
        name: effectiveName,
        title: (existingData['title'] as String?) ?? 'Senior Personal Trainer',
        email: effectiveEmail,
        initials: TrainerProfileModel.extractInitials(effectiveName),
        photoUrl: existingData['photoUrl'] as String? ?? authUser?.photoURL,
        isVerified: (existingData['isVerified'] as bool?) ?? true,
        rating: (existingData['rating'] as num?)?.toDouble() ?? 4.9,
        reviewCount: (existingData['reviewCount'] as num?)?.toInt() ?? 128,
        clientCount: (existingData['clientCount'] as num?)?.toInt() ?? 5,
        experienceYears: (existingData['experienceYears'] as num?)?.toDouble() ?? 3.2,
        sessionCount: (existingData['sessionCount'] as num?)?.toInt() ?? 142,
        specializations: TrainerProfileModel.defaultSpecializations,
        certifications: TrainerProfileModel.defaultCertifications,
        monthlyMetrics: const TrainerMonthlyMetricsModel(
          sessionsCompleted: 38,
          clientRetentionPercentage: 96,
          avgSessionRating: 4.9,
          newClientsCount: 2,
        ),
        availability: const TrainerAvailabilityModel(
          workingHours: '8AM–6PM',
          daysAvailable: 'Mon–Sat',
          sessionDuration: '45–60 min',
        ),
        accountSettings: const TrainerAccountSettingsModel(
          notificationsEnabled: true,
          clientMessagingEnabled: true,
        ),
      );

      final payload = seedModel.toFirestore();
      if (!existingDoc.exists) {
        payload['createdAt'] = FieldValue.serverTimestamp();
      }

      await docRef.set(payload, SetOptions(merge: true));
    } catch (_) {}
  }
}
