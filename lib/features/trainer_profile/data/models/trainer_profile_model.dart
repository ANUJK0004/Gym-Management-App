import '../../domain/entities/trainer_profile.dart';

class TrainerCertificationModel extends TrainerCertification {
  const TrainerCertificationModel({
    required super.id,
    required super.title,
    required super.obtainedYear,
    required super.emoji,
    super.isVerified = true,
  });

  factory TrainerCertificationModel.fromJson(Map<String, dynamic> json) {
    return TrainerCertificationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      obtainedYear: (json['obtainedYear'] as num?)?.toInt() ?? DateTime.now().year,
      emoji: json['emoji'] as String? ?? '🏅',
      isVerified: json['isVerified'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'obtainedYear': obtainedYear,
      'emoji': emoji,
      'isVerified': isVerified,
    };
  }
}

class TrainerMonthlyMetricsModel extends TrainerMonthlyMetrics {
  const TrainerMonthlyMetricsModel({
    required super.sessionsCompleted,
    required super.clientRetentionPercentage,
    required super.avgSessionRating,
    required super.newClientsCount,
  });

  factory TrainerMonthlyMetricsModel.fromJson(Map<String, dynamic> json) {
    return TrainerMonthlyMetricsModel(
      sessionsCompleted: (json['sessionsCompleted'] as num?)?.toInt() ?? 0,
      clientRetentionPercentage:
          (json['clientRetentionPercentage'] as num?)?.toInt() ?? 0,
      avgSessionRating:
          (json['avgSessionRating'] as num?)?.toDouble() ?? 0.0,
      newClientsCount: (json['newClientsCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionsCompleted': sessionsCompleted,
      'clientRetentionPercentage': clientRetentionPercentage,
      'avgSessionRating': avgSessionRating,
      'newClientsCount': newClientsCount,
    };
  }
}

class TrainerAvailabilityModel extends TrainerAvailability {
  const TrainerAvailabilityModel({
    required super.workingHours,
    required super.daysAvailable,
    required super.sessionDuration,
  });

  factory TrainerAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return TrainerAvailabilityModel(
      workingHours: json['workingHours'] as String? ?? '8AM–6PM',
      daysAvailable: json['daysAvailable'] as String? ?? 'Mon–Sat',
      sessionDuration: json['sessionDuration'] as String? ?? '45–60 min',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workingHours': workingHours,
      'daysAvailable': daysAvailable,
      'sessionDuration': sessionDuration,
    };
  }
}

class TrainerAccountSettingsModel extends TrainerAccountSettings {
  const TrainerAccountSettingsModel({
    super.notificationsEnabled = true,
    super.clientMessagingEnabled = true,
  });

  factory TrainerAccountSettingsModel.fromJson(Map<String, dynamic> json) {
    return TrainerAccountSettingsModel(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      clientMessagingEnabled: json['clientMessagingEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'clientMessagingEnabled': clientMessagingEnabled,
    };
  }
}

class TrainerProfileModel extends TrainerProfile {
  const TrainerProfileModel({
    required super.id,
    required super.name,
    required super.title,
    required super.email,
    required super.initials,
    super.photoUrl,
    super.isVerified = true,
    super.rating = 4.9,
    super.reviewCount = 128,
    super.clientCount = 5,
    super.experienceYears = 3.2,
    super.sessionCount = 142,
    super.specializations = const [],
    super.certifications = const [],
    required super.monthlyMetrics,
    required super.availability,
    required super.accountSettings,
  });

  factory TrainerProfileModel.fromJson(Map<String, dynamic> json) {
    final certList = (json['certifications'] as List<dynamic>?)
            ?.map((e) =>
                TrainerCertificationModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final specList = (json['specializations'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return TrainerProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Coach Mike Torres',
      title: json['title'] as String? ?? 'Senior Personal Trainer',
      email: json['email'] as String? ?? 'mike.torres@gymsync.com',
      initials: json['initials'] as String? ?? 'MT',
      photoUrl: json['photoUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 128,
      clientCount: (json['clientCount'] as num?)?.toInt() ?? 5,
      experienceYears: (json['experienceYears'] as num?)?.toDouble() ?? 3.2,
      sessionCount: (json['sessionCount'] as num?)?.toInt() ?? 142,
      specializations: specList,
      certifications: certList,
      monthlyMetrics: json['monthlyMetrics'] != null
          ? TrainerMonthlyMetricsModel.fromJson(
              json['monthlyMetrics'] as Map<String, dynamic>)
          : const TrainerMonthlyMetricsModel(
              sessionsCompleted: 38,
              clientRetentionPercentage: 96,
              avgSessionRating: 4.9,
              newClientsCount: 2,
            ),
      availability: json['availability'] != null
          ? TrainerAvailabilityModel.fromJson(
              json['availability'] as Map<String, dynamic>)
          : const TrainerAvailabilityModel(
              workingHours: '8AM–6PM',
              daysAvailable: 'Mon–Sat',
              sessionDuration: '45–60 min',
            ),
      accountSettings: json['accountSettings'] != null
          ? TrainerAccountSettingsModel.fromJson(
              json['accountSettings'] as Map<String, dynamic>)
          : const TrainerAccountSettingsModel(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'email': email,
      'initials': initials,
      'photoUrl': photoUrl,
      'isVerified': isVerified,
      'rating': rating,
      'reviewCount': reviewCount,
      'clientCount': clientCount,
      'experienceYears': experienceYears,
      'sessionCount': sessionCount,
      'specializations': specializations,
      'certifications': certifications
          .map((c) => TrainerCertificationModel(
                id: c.id,
                title: c.title,
                obtainedYear: c.obtainedYear,
                emoji: c.emoji,
                isVerified: c.isVerified,
              ).toJson())
          .toList(),
      'monthlyMetrics': TrainerMonthlyMetricsModel(
        sessionsCompleted: monthlyMetrics.sessionsCompleted,
        clientRetentionPercentage: monthlyMetrics.clientRetentionPercentage,
        avgSessionRating: monthlyMetrics.avgSessionRating,
        newClientsCount: monthlyMetrics.newClientsCount,
      ).toJson(),
      'availability': TrainerAvailabilityModel(
        workingHours: availability.workingHours,
        daysAvailable: availability.daysAvailable,
        sessionDuration: availability.sessionDuration,
      ).toJson(),
      'accountSettings': TrainerAccountSettingsModel(
        notificationsEnabled: accountSettings.notificationsEnabled,
        clientMessagingEnabled: accountSettings.clientMessagingEnabled,
      ).toJson(),
    };
  }
}
