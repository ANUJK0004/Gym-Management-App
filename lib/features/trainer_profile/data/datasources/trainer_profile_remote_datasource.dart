import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trainer_profile_model.dart';

class TrainerProfileRemoteDataSource {
  TrainerProfileRemoteDataSource([this._firestore]);

  final FirebaseFirestore? _firestore;

  CollectionReference<Map<String, dynamic>>? get _trainerProfilesCollection =>
      _firestore?.collection('trainer_profiles');

  CollectionReference<Map<String, dynamic>>? get _usersCollection =>
      _firestore?.collection('users');

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

  Future<TrainerProfileModel> getProfile({required String trainerId}) async {
    if (_firestore == null) {
      await Future.delayed(const Duration(milliseconds: 50));
      return _currentProfile;
    }

    try {
      final doc = await _trainerProfilesCollection?.doc(trainerId).get();
      if (doc != null && doc.exists && doc.data() != null) {
        _currentProfile = TrainerProfileModel.fromJson(doc.data()!);
        return _currentProfile;
      }

      // Check users collection for trainer details
      final userDoc = await _usersCollection?.doc(trainerId).get();
      if (userDoc != null && userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        final name = (userData['displayName'] as String?) ?? 'Coach Mike';
        final email =
            (userData['email'] as String?) ?? 'coach.mike@sweatsync.com';
        final photoUrl = userData['photoUrl'] as String?;

        final profile = TrainerProfileModel(
          id: trainerId,
          name: name,
          title:
              (userData['specialization'] as String?) ?? 'Senior Personal Trainer',
          email: email,
          initials: _getInitials(name),
          photoUrl: photoUrl,
          isVerified: true,
          rating: 4.9,
          reviewCount: 128,
          clientCount: 5,
          experienceYears: 3.2,
          sessionCount: 142,
          specializations: _defaultProfile.specializations,
          certifications: _defaultProfile.certifications,
          monthlyMetrics: _defaultProfile.monthlyMetrics,
          availability: _defaultProfile.availability,
          accountSettings: _defaultProfile.accountSettings,
        );

        // Seed to trainer_profiles collection
        await _trainerProfilesCollection?.doc(trainerId).set(profile.toJson());
        _currentProfile = profile;
        return profile;
      }

      // If no doc in users, seed default
      final seededProfile = _defaultProfile;
      await _trainerProfilesCollection
          ?.doc(trainerId)
          .set(seededProfile.toJson());
      _currentProfile = seededProfile;
      return seededProfile;
    } catch (_) {
      return _currentProfile;
    }
  }

  Future<TrainerProfileModel> updateProfile(TrainerProfileModel updated) async {
    _currentProfile = updated;

    if (_firestore != null) {
      try {
        await _trainerProfilesCollection
            ?.doc(updated.id)
            .set(updated.toJson(), SetOptions(merge: true));

        await _usersCollection?.doc(updated.id).set({
          'displayName': updated.name,
          'specialization': updated.title,
          'photoUrl': updated.photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }

    return _currentProfile;
  }

  static String _getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'MT';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
