class TrainerSession {
  const TrainerSession({
    required this.id,
    required this.clientName,
    this.clientAvatar,
    required this.clientInitials,
    required this.workoutType,
    required this.durationMinutes,
    required this.startTime,
    required this.startsIn,
    this.iconEmoji = '💪',
    this.isCompleted = false,
  });

  final String id;
  final String clientName;
  final String? clientAvatar;
  final String clientInitials;
  final String workoutType;
  final int durationMinutes;
  final String startTime;
  final String startsIn;
  final String iconEmoji;
  final bool isCompleted;
}

class TrainerClientProgress {
  const TrainerClientProgress({
    required this.id,
    required this.name,
    required this.initials,
    required this.goal,
    required this.sessionsCount,
    required this.progressPercentage,
    this.isOnline = true,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String initials;
  final String goal;
  final int sessionsCount;
  final int progressPercentage;
  final bool isOnline;
  final String? avatarUrl;

  double get progressValue => (progressPercentage / 100.0).clamp(0.0, 1.0);
}

class TrainerDashboardData {
  const TrainerDashboardData({
    required this.trainerId,
    required this.trainerName,
    required this.trainerEmail,
    this.trainerPhotoUrl,
    required this.initials,
    required this.todaySessionsCount,
    required this.todayClientsCount,
    required this.todayActiveHours,
    this.nextSession,
    this.clients = const [],
    this.todaySchedule = const [],
  });

  final String trainerId;
  final String trainerName;
  final String trainerEmail;
  final String? trainerPhotoUrl;
  final String initials;

  final int todaySessionsCount;
  final int todayClientsCount;
  final String todayActiveHours;

  final TrainerSession? nextSession;
  final List<TrainerClientProgress> clients;
  final List<TrainerSession> todaySchedule;
}
