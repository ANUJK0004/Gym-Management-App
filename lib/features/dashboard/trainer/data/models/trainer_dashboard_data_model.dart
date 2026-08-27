import '../../domain/entities/trainer_dashboard_data.dart';

class TrainerSessionModel extends TrainerSession {
  const TrainerSessionModel({
    required super.id,
    required super.clientName,
    super.clientAvatar,
    required super.clientInitials,
    required super.workoutType,
    required super.durationMinutes,
    required super.startTime,
    required super.startsIn,
    super.iconEmoji = '💪',
    super.isCompleted = false,
  });

  factory TrainerSessionModel.fromJson(Map<String, dynamic> json) {
    return TrainerSessionModel(
      id: json['id'] as String? ?? '',
      clientName: json['clientName'] as String? ?? '',
      clientAvatar: json['clientAvatar'] as String?,
      clientInitials: json['clientInitials'] as String? ?? '',
      workoutType: json['workoutType'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      startTime: json['startTime'] as String? ?? '',
      startsIn: json['startsIn'] as String? ?? '',
      iconEmoji: json['iconEmoji'] as String? ?? '💪',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientName': clientName,
      'clientAvatar': clientAvatar,
      'clientInitials': clientInitials,
      'workoutType': workoutType,
      'durationMinutes': durationMinutes,
      'startTime': startTime,
      'startsIn': startsIn,
      'iconEmoji': iconEmoji,
      'isCompleted': isCompleted,
    };
  }
}

class TrainerClientProgressModel extends TrainerClientProgress {
  const TrainerClientProgressModel({
    required super.id,
    required super.name,
    required super.initials,
    required super.goal,
    required super.sessionsCount,
    required super.progressPercentage,
    super.isOnline = true,
    super.avatarUrl,
  });

  factory TrainerClientProgressModel.fromJson(Map<String, dynamic> json) {
    return TrainerClientProgressModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      goal: json['goal'] as String? ?? '',
      sessionsCount: json['sessionsCount'] as int? ?? 0,
      progressPercentage: json['progressPercentage'] as int? ?? 0,
      isOnline: json['isOnline'] as bool? ?? true,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'initials': initials,
      'goal': goal,
      'sessionsCount': sessionsCount,
      'progressPercentage': progressPercentage,
      'isOnline': isOnline,
      'avatarUrl': avatarUrl,
    };
  }
}

class TrainerDashboardDataModel extends TrainerDashboardData {
  const TrainerDashboardDataModel({
    required super.trainerId,
    required super.trainerName,
    required super.trainerEmail,
    super.trainerPhotoUrl,
    required super.initials,
    required super.todaySessionsCount,
    required super.todayClientsCount,
    required super.todayActiveHours,
    super.nextSession,
    super.clients = const [],
    super.todaySchedule = const [],
  });

  factory TrainerDashboardDataModel.fromJson(Map<String, dynamic> json) {
    final nextSessionMap = json['nextSession'] as Map<String, dynamic>?;
    final clientsList = json['clients'] as List<dynamic>? ?? [];
    final scheduleList = json['todaySchedule'] as List<dynamic>? ?? [];

    return TrainerDashboardDataModel(
      trainerId: json['trainerId'] as String? ?? '',
      trainerName: json['trainerName'] as String? ?? '',
      trainerEmail: json['trainerEmail'] as String? ?? '',
      trainerPhotoUrl: json['trainerPhotoUrl'] as String?,
      initials: json['initials'] as String? ?? 'MT',
      todaySessionsCount: json['todaySessionsCount'] as int? ?? 0,
      todayClientsCount: json['todayClientsCount'] as int? ?? 0,
      todayActiveHours: json['todayActiveHours'] as String? ?? '0h',
      nextSession: nextSessionMap != null
          ? TrainerSessionModel.fromJson(nextSessionMap)
          : null,
      clients: clientsList
          .map((c) => TrainerClientProgressModel.fromJson(
              c as Map<String, dynamic>))
          .toList(),
      todaySchedule: scheduleList
          .map((s) =>
              TrainerSessionModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trainerId': trainerId,
      'trainerName': trainerName,
      'trainerEmail': trainerEmail,
      'trainerPhotoUrl': trainerPhotoUrl,
      'initials': initials,
      'todaySessionsCount': todaySessionsCount,
      'todayClientsCount': todayClientsCount,
      'todayActiveHours': todayActiveHours,
      'nextSession': nextSession != null
          ? (nextSession as TrainerSessionModel).toJson()
          : null,
      'clients': clients
          .map((c) => (c as TrainerClientProgressModel).toJson())
          .toList(),
      'todaySchedule': todaySchedule
          .map((s) => (s as TrainerSessionModel).toJson())
          .toList(),
    };
  }
}
