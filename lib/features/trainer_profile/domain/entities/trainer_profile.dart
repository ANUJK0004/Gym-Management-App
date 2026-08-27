class TrainerCertification {
  const TrainerCertification({
    required this.id,
    required this.title,
    required this.obtainedYear,
    required this.emoji,
    this.isVerified = true,
  });

  final String id;
  final String title;
  final int obtainedYear;
  final String emoji;
  final bool isVerified;

  TrainerCertification copyWith({
    String? id,
    String? title,
    int? obtainedYear,
    String? emoji,
    bool? isVerified,
  }) {
    return TrainerCertification(
      id: id ?? this.id,
      title: title ?? this.title,
      obtainedYear: obtainedYear ?? this.obtainedYear,
      emoji: emoji ?? this.emoji,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class TrainerMonthlyMetrics {
  const TrainerMonthlyMetrics({
    required this.sessionsCompleted,
    required this.clientRetentionPercentage,
    required this.avgSessionRating,
    required this.newClientsCount,
  });

  final int sessionsCompleted;
  final int clientRetentionPercentage;
  final double avgSessionRating;
  final int newClientsCount;

  TrainerMonthlyMetrics copyWith({
    int? sessionsCompleted,
    int? clientRetentionPercentage,
    double? avgSessionRating,
    int? newClientsCount,
  }) {
    return TrainerMonthlyMetrics(
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      clientRetentionPercentage:
          clientRetentionPercentage ?? this.clientRetentionPercentage,
      avgSessionRating: avgSessionRating ?? this.avgSessionRating,
      newClientsCount: newClientsCount ?? this.newClientsCount,
    );
  }
}

class TrainerAvailability {
  const TrainerAvailability({
    required this.workingHours,
    required this.daysAvailable,
    required this.sessionDuration,
  });

  final String workingHours;
  final String daysAvailable;
  final String sessionDuration;

  TrainerAvailability copyWith({
    String? workingHours,
    String? daysAvailable,
    String? sessionDuration,
  }) {
    return TrainerAvailability(
      workingHours: workingHours ?? this.workingHours,
      daysAvailable: daysAvailable ?? this.daysAvailable,
      sessionDuration: sessionDuration ?? this.sessionDuration,
    );
  }
}

class TrainerAccountSettings {
  const TrainerAccountSettings({
    this.notificationsEnabled = true,
    this.clientMessagingEnabled = true,
  });

  final bool notificationsEnabled;
  final bool clientMessagingEnabled;

  TrainerAccountSettings copyWith({
    bool? notificationsEnabled,
    bool? clientMessagingEnabled,
  }) {
    return TrainerAccountSettings(
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      clientMessagingEnabled:
          clientMessagingEnabled ?? this.clientMessagingEnabled,
    );
  }
}

class TrainerProfile {
  const TrainerProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.email,
    required this.initials,
    this.photoUrl,
    this.isVerified = true,
    this.rating = 4.9,
    this.reviewCount = 128,
    this.clientCount = 5,
    this.experienceYears = 3.2,
    this.sessionCount = 142,
    this.specializations = const [],
    this.certifications = const [],
    required this.monthlyMetrics,
    required this.availability,
    required this.accountSettings,
  });

  final String id;
  final String name;
  final String title;
  final String email;
  final String initials;
  final String? photoUrl;
  final bool isVerified;
  final double rating;
  final int reviewCount;
  final int clientCount;
  final double experienceYears;
  final int sessionCount;
  final List<String> specializations;
  final List<TrainerCertification> certifications;
  final TrainerMonthlyMetrics monthlyMetrics;
  final TrainerAvailability availability;
  final TrainerAccountSettings accountSettings;

  TrainerProfile copyWith({
    String? id,
    String? name,
    String? title,
    String? email,
    String? initials,
    String? photoUrl,
    bool? isVerified,
    double? rating,
    int? reviewCount,
    int? clientCount,
    double? experienceYears,
    int? sessionCount,
    List<String>? specializations,
    List<TrainerCertification>? certifications,
    TrainerMonthlyMetrics? monthlyMetrics,
    TrainerAvailability? availability,
    TrainerAccountSettings? accountSettings,
  }) {
    return TrainerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      email: email ?? this.email,
      initials: initials ?? this.initials,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      clientCount: clientCount ?? this.clientCount,
      experienceYears: experienceYears ?? this.experienceYears,
      sessionCount: sessionCount ?? this.sessionCount,
      specializations: specializations ?? this.specializations,
      certifications: certifications ?? this.certifications,
      monthlyMetrics: monthlyMetrics ?? this.monthlyMetrics,
      availability: availability ?? this.availability,
      accountSettings: accountSettings ?? this.accountSettings,
    );
  }
}
