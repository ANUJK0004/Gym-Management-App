import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trainer_profile.dart';

class TrainerCertificationModel extends TrainerCertification {
  const TrainerCertificationModel({
    required super.id,
    required super.title,
    required super.obtainedYear,
    required super.emoji,
    super.isVerified = true,
  });

  factory TrainerCertificationModel.fromMap(Map<String, dynamic> map) {
    return TrainerCertificationModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      obtainedYear: (map['obtainedYear'] as num?)?.toInt() ?? DateTime.now().year,
      emoji: map['emoji'] as String? ?? '🏅',
      isVerified: map['isVerified'] as bool? ?? true,
    );
  }

  factory TrainerCertificationModel.fromJson(Map<String, dynamic> json) =>
      TrainerCertificationModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'obtainedYear': obtainedYear,
      'emoji': emoji,
      'isVerified': isVerified,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

class TrainerMonthlyMetricsModel extends TrainerMonthlyMetrics {
  const TrainerMonthlyMetricsModel({
    required super.sessionsCompleted,
    required super.clientRetentionPercentage,
    required super.avgSessionRating,
    required super.newClientsCount,
  });

  factory TrainerMonthlyMetricsModel.fromMap(Map<String, dynamic> map) {
    return TrainerMonthlyMetricsModel(
      sessionsCompleted: (map['sessionsCompleted'] as num?)?.toInt() ?? 38,
      clientRetentionPercentage:
          (map['clientRetentionPercentage'] as num?)?.toInt() ?? 96,
      avgSessionRating:
          (map['avgSessionRating'] as num?)?.toDouble() ?? 4.9,
      newClientsCount: (map['newClientsCount'] as num?)?.toInt() ?? 2,
    );
  }

  factory TrainerMonthlyMetricsModel.fromJson(Map<String, dynamic> json) =>
      TrainerMonthlyMetricsModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'sessionsCompleted': sessionsCompleted,
      'clientRetentionPercentage': clientRetentionPercentage,
      'avgSessionRating': avgSessionRating,
      'newClientsCount': newClientsCount,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

class TrainerAvailabilityModel extends TrainerAvailability {
  const TrainerAvailabilityModel({
    required super.workingHours,
    required super.daysAvailable,
    required super.sessionDuration,
  });

  factory TrainerAvailabilityModel.fromMap(Map<String, dynamic> map) {
    return TrainerAvailabilityModel(
      workingHours: map['workingHours'] as String? ?? '8AM–6PM',
      daysAvailable: map['daysAvailable'] as String? ?? 'Mon–Sat',
      sessionDuration: map['sessionDuration'] as String? ?? '45–60 min',
    );
  }

  factory TrainerAvailabilityModel.fromJson(Map<String, dynamic> json) =>
      TrainerAvailabilityModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'workingHours': workingHours,
      'daysAvailable': daysAvailable,
      'sessionDuration': sessionDuration,
    };
  }

  Map<String, dynamic> toJson() => toMap();
}

class TrainerAccountSettingsModel extends TrainerAccountSettings {
  const TrainerAccountSettingsModel({
    super.notificationsEnabled = true,
    super.clientMessagingEnabled = true,
  });

  factory TrainerAccountSettingsModel.fromMap(Map<String, dynamic> map) {
    return TrainerAccountSettingsModel(
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      clientMessagingEnabled: map['clientMessagingEnabled'] as bool? ?? true,
    );
  }

  factory TrainerAccountSettingsModel.fromJson(Map<String, dynamic> json) =>
      TrainerAccountSettingsModel.fromMap(json);

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'clientMessagingEnabled': clientMessagingEnabled,
    };
  }

  Map<String, dynamic> toJson() => toMap();
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

  static const List<String> defaultSpecializations = [
    'Strength & Conditioning',
    'HIIT',
    'Weight Loss',
    'Athletic Performance',
    'Nutrition Coaching',
  ];

  static const List<TrainerCertificationModel> defaultCertifications = [
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
  ];

  factory TrainerProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return TrainerProfileModel.fromMap(data, id: doc.id);
  }

  factory TrainerProfileModel.fromMap(
    Map<String, dynamic> data, {
    String? id,
  }) {
    final effectiveId = id ?? (data['uid'] as String?) ?? (data['id'] as String?) ?? 'trainer_001';
    final rawName = (data['displayName'] as String?) ?? (data['name'] as String?);
    final effectiveName = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : 'Coach Mike Torres';

    final effectiveInitials = extractInitials(effectiveName);

    // Parse Specializations
    List<String> specList = [];
    if (data['specializations'] is List) {
      specList = (data['specializations'] as List)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (data['specialization'] is String && (data['specialization'] as String).isNotEmpty) {
      specList = (data['specialization'] as String)
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (specList.isEmpty) {
      specList = List.from(defaultSpecializations);
    }

    // Parse Certifications
    List<TrainerCertificationModel> certList = [];
    if (data['certifications'] is List) {
      certList = (data['certifications'] as List)
          .whereType<Map<String, dynamic>>()
          .map(TrainerCertificationModel.fromMap)
          .toList();
    }
    if (certList.isEmpty) {
      certList = List.from(defaultCertifications);
    }

    // Parse Monthly Metrics
    final monthlyMetrics = data['monthlyMetrics'] is Map<String, dynamic>
        ? TrainerMonthlyMetricsModel.fromMap(data['monthlyMetrics'] as Map<String, dynamic>)
        : const TrainerMonthlyMetricsModel(
            sessionsCompleted: 38,
            clientRetentionPercentage: 96,
            avgSessionRating: 4.9,
            newClientsCount: 2,
          );

    // Parse Availability
    final availability = data['availability'] is Map<String, dynamic>
        ? TrainerAvailabilityModel.fromMap(data['availability'] as Map<String, dynamic>)
        : const TrainerAvailabilityModel(
            workingHours: '8AM–6PM',
            daysAvailable: 'Mon–Sat',
            sessionDuration: '45–60 min',
          );

    // Parse Account Settings
    final accountSettings = data['accountSettings'] is Map<String, dynamic>
        ? TrainerAccountSettingsModel.fromMap(data['accountSettings'] as Map<String, dynamic>)
        : const TrainerAccountSettingsModel();

    return TrainerProfileModel(
      id: effectiveId,
      name: effectiveName,
      title: data['title'] as String? ?? 'Senior Personal Trainer',
      email: data['email'] as String? ?? 'mike.torres@gymsync.com',
      initials: effectiveInitials,
      photoUrl: data['photoUrl'] as String?,
      isVerified: data['isVerified'] as bool? ?? true,
      rating: (data['rating'] as num?)?.toDouble() ?? 4.9,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 128,
      clientCount: (data['clientCount'] as num?)?.toInt() ?? 5,
      experienceYears: (data['experienceYears'] as num?)?.toDouble() ?? 3.2,
      sessionCount: (data['sessionCount'] as num?)?.toInt() ?? 142,
      specializations: specList,
      certifications: certList,
      monthlyMetrics: monthlyMetrics,
      availability: availability,
      accountSettings: accountSettings,
    );
  }

  factory TrainerProfileModel.fromJson(Map<String, dynamic> json) =>
      TrainerProfileModel.fromMap(json);

  Map<String, dynamic> toFirestore() {
    return {
      'uid': id,
      'displayName': name,
      'name': name,
      'title': title,
      'email': email,
      'initials': initials,
      'photoUrl': photoUrl,
      'role': 'trainer',
      'isVerified': isVerified,
      'rating': rating,
      'reviewCount': reviewCount,
      'clientCount': clientCount,
      'experienceYears': experienceYears,
      'sessionCount': sessionCount,
      'specializations': specializations,
      'specialization': specializations.isNotEmpty ? specializations.first : 'Personal Trainer',
      'certifications': certifications
          .map((c) => TrainerCertificationModel(
                id: c.id,
                title: c.title,
                obtainedYear: c.obtainedYear,
                emoji: c.emoji,
                isVerified: c.isVerified,
              ).toMap())
          .toList(),
      'monthlyMetrics': TrainerMonthlyMetricsModel(
        sessionsCompleted: monthlyMetrics.sessionsCompleted,
        clientRetentionPercentage: monthlyMetrics.clientRetentionPercentage,
        avgSessionRating: monthlyMetrics.avgSessionRating,
        newClientsCount: monthlyMetrics.newClientsCount,
      ).toMap(),
      'availability': TrainerAvailabilityModel(
        workingHours: availability.workingHours,
        daysAvailable: availability.daysAvailable,
        sessionDuration: availability.sessionDuration,
      ).toMap(),
      'accountSettings': TrainerAccountSettingsModel(
        notificationsEnabled: accountSettings.notificationsEnabled,
        clientMessagingEnabled: accountSettings.clientMessagingEnabled,
      ).toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
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
              ).toMap())
          .toList(),
      'monthlyMetrics': TrainerMonthlyMetricsModel(
        sessionsCompleted: monthlyMetrics.sessionsCompleted,
        clientRetentionPercentage: monthlyMetrics.clientRetentionPercentage,
        avgSessionRating: monthlyMetrics.avgSessionRating,
        newClientsCount: monthlyMetrics.newClientsCount,
      ).toMap(),
      'availability': TrainerAvailabilityModel(
        workingHours: availability.workingHours,
        daysAvailable: availability.daysAvailable,
        sessionDuration: availability.sessionDuration,
      ).toMap(),
      'accountSettings': TrainerAccountSettingsModel(
        notificationsEnabled: accountSettings.notificationsEnabled,
        clientMessagingEnabled: accountSettings.clientMessagingEnabled,
      ).toMap(),
    };
  }

  @override
  TrainerProfileModel copyWith({
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
    return TrainerProfileModel(
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

  static String extractInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'MT';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
