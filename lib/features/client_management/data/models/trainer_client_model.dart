import '../../domain/entities/trainer_client.dart';

class TrainerClientModel extends TrainerClient {
  const TrainerClientModel({
    required super.id,
    required super.name,
    required super.initials,
    required super.email,
    super.age,
    super.heightCm,
    super.weightKg,
    required super.goal,
    required super.trainingPlan,
    super.sessionsCount = 0,
    super.progressPercentage = 0,
    super.streakDays = 0,
    super.nextSession,
    super.isActive = true,
    super.avatarUrl,
    super.joinedDate,
    super.phone,
    super.notes,
    super.attendanceRate = 91,
    super.attendanceDelta = '+5%',
    super.avgIntensity = 8.2,
    super.intensityDelta = '+0.4',
    super.weightChange = -3.2,
    super.goalOnTrack = true,
    super.weeklyActivity = const [0.55, 0.75, 0.1, 0.9, 0.72, 0.8, 0.65],
    super.upcomingSessions = const [],
  });

  factory TrainerClientModel.fromJson(Map<String, dynamic> json) {
    return TrainerClientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      initials: json['initials'] as String? ??
          TrainerClient.generateInitials(json['name'] as String? ?? ''),
      email: json['email'] as String? ?? '',
      age: json['age'] as int?,
      heightCm: json['heightCm'] as int?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      goal: json['goal'] as String? ?? 'General Fitness',
      trainingPlan: json['trainingPlan'] as String? ?? 'Custom Plan',
      sessionsCount: json['sessionsCount'] as int? ?? 0,
      progressPercentage: json['progressPercentage'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      nextSession: json['nextSession'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      avatarUrl: json['avatarUrl'] as String?,
      joinedDate: json['joinedDate'] != null
          ? DateTime.tryParse(json['joinedDate'] as String)
          : null,
      phone: json['phone'] as String?,
      notes: json['notes'] as String?,
      attendanceRate: json['attendanceRate'] as int? ?? 91,
      attendanceDelta: json['attendanceDelta'] as String? ?? '+5%',
      avgIntensity: (json['avgIntensity'] as num?)?.toDouble() ?? 8.2,
      intensityDelta: json['intensityDelta'] as String? ?? '+0.4',
      weightChange: (json['weightChange'] as num?)?.toDouble() ?? -3.2,
      goalOnTrack: json['goalOnTrack'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'initials': initials,
      'email': email,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'goal': goal,
      'trainingPlan': trainingPlan,
      'sessionsCount': sessionsCount,
      'progressPercentage': progressPercentage,
      'streakDays': streakDays,
      'nextSession': nextSession,
      'isActive': isActive,
      'avatarUrl': avatarUrl,
      'joinedDate': joinedDate?.toIso8601String(),
      'phone': phone,
      'notes': notes,
      'attendanceRate': attendanceRate,
      'attendanceDelta': attendanceDelta,
      'avgIntensity': avgIntensity,
      'intensityDelta': intensityDelta,
      'weightChange': weightChange,
      'goalOnTrack': goalOnTrack,
    };
  }

  factory TrainerClientModel.fromDomain(TrainerClient entity) {
    return TrainerClientModel(
      id: entity.id,
      name: entity.name,
      initials: entity.initials,
      email: entity.email,
      age: entity.age,
      heightCm: entity.heightCm,
      weightKg: entity.weightKg,
      goal: entity.goal,
      trainingPlan: entity.trainingPlan,
      sessionsCount: entity.sessionsCount,
      progressPercentage: entity.progressPercentage,
      streakDays: entity.streakDays,
      nextSession: entity.nextSession,
      isActive: entity.isActive,
      avatarUrl: entity.avatarUrl,
      joinedDate: entity.joinedDate,
      phone: entity.phone,
      notes: entity.notes,
      attendanceRate: entity.attendanceRate,
      attendanceDelta: entity.attendanceDelta,
      avgIntensity: entity.avgIntensity,
      intensityDelta: entity.intensityDelta,
      weightChange: entity.weightChange,
      goalOnTrack: entity.goalOnTrack,
      weeklyActivity: entity.weeklyActivity,
      upcomingSessions: entity.upcomingSessions,
    );
  }

  TrainerClient toDomain() => this;
}
