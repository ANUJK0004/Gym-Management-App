import '../models/trainer_profile_model.dart';

class TrainerProfileRemoteDataSource {
  TrainerProfileRemoteDataSource();

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
    // Simulate brief network delay for realistic experience
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentProfile;
  }

  Future<TrainerProfileModel> updateProfile(TrainerProfileModel updated) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentProfile = updated;
    return _currentProfile;
  }
}
