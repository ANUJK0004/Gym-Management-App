class ClientUpcomingSession {
  const ClientUpcomingSession({
    required this.id,
    required this.dayLabel,
    required this.title,
    required this.time,
    required this.durationMinutes,
  });

  final String id;
  final String dayLabel; // 'TOD', 'THU', 'SAT', etc.
  final String title; // 'HIIT + Cardio', 'Assessment'
  final String time; // '11:00 AM', '9:00 AM'
  final int durationMinutes; // 45, 30

  String get timeAndDuration => '$time · $durationMinutes min';
}

class TrainerClient {
  const TrainerClient({
    required this.id,
    required this.name,
    required this.initials,
    required this.email,
    this.age,
    this.heightCm,
    this.weightKg,
    required this.goal,
    required this.trainingPlan,
    this.sessionsCount = 0,
    this.progressPercentage = 0,
    this.streakDays = 0,
    this.nextSession,
    this.isActive = true,
    this.avatarUrl,
    this.joinedDate,
    this.phone,
    this.notes,
    this.attendanceRate = 91,
    this.attendanceDelta = '+5%',
    this.avgIntensity = 8.2,
    this.intensityDelta = '+0.4',
    this.weightChange = -3.2,
    this.goalOnTrack = true,
    this.weeklyActivity = const [0.55, 0.75, 0.1, 0.9, 0.72, 0.8, 0.65],
    this.upcomingSessions = const [],
  });

  final String id;
  final String name;
  final String initials;
  final String email;
  final int? age;
  final int? heightCm;
  final double? weightKg;
  final String goal;
  final String trainingPlan;
  final int sessionsCount;
  final int progressPercentage;
  final int streakDays;
  final String? nextSession;
  final bool isActive;
  final String? avatarUrl;
  final DateTime? joinedDate;
  final String? phone;
  final String? notes;

  final int attendanceRate;
  final String attendanceDelta;
  final double avgIntensity;
  final String intensityDelta;
  final double weightChange;
  final bool goalOnTrack;
  final List<double> weeklyActivity;
  final List<ClientUpcomingSession> upcomingSessions;

  double get progressValue => (progressPercentage / 100.0).clamp(0.0, 1.0);

  String get subtitle => '$goal · $trainingPlan';

  String get formattedHeight => heightCm != null ? '${heightCm}cm' : '163cm';

  String get formattedWeight =>
      weightKg != null ? '${weightKg! % 1 == 0 ? weightKg!.toInt() : weightKg!}kg' : '--';

  String get formattedStreak => '${streakDays}d';

  String get formattedWeightChange =>
      weightChange < 0 ? '${weightChange.toStringAsFixed(1)}kg' : '+${weightChange.toStringAsFixed(1)}kg';

  TrainerClient copyWith({
    String? id,
    String? name,
    String? initials,
    String? email,
    int? age,
    int? heightCm,
    double? weightKg,
    String? goal,
    String? trainingPlan,
    int? sessionsCount,
    int? progressPercentage,
    int? streakDays,
    String? nextSession,
    bool? isActive,
    String? avatarUrl,
    DateTime? joinedDate,
    String? phone,
    String? notes,
    int? attendanceRate,
    String? attendanceDelta,
    double? avgIntensity,
    String? intensityDelta,
    double? weightChange,
    bool? goalOnTrack,
    List<double>? weeklyActivity,
    List<ClientUpcomingSession>? upcomingSessions,
  }) {
    return TrainerClient(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      email: email ?? this.email,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goal: goal ?? this.goal,
      trainingPlan: trainingPlan ?? this.trainingPlan,
      sessionsCount: sessionsCount ?? this.sessionsCount,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      streakDays: streakDays ?? this.streakDays,
      nextSession: nextSession ?? this.nextSession,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinedDate: joinedDate ?? this.joinedDate,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      attendanceDelta: attendanceDelta ?? this.attendanceDelta,
      avgIntensity: avgIntensity ?? this.avgIntensity,
      intensityDelta: intensityDelta ?? this.intensityDelta,
      weightChange: weightChange ?? this.weightChange,
      goalOnTrack: goalOnTrack ?? this.goalOnTrack,
      weeklyActivity: weeklyActivity ?? this.weeklyActivity,
      upcomingSessions: upcomingSessions ?? this.upcomingSessions,
    );
  }

  static String generateInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'CL';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
