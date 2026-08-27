class TrainerScheduleSession {
  const TrainerScheduleSession({
    required this.id,
    required this.clientName,
    required this.workoutType,
    required this.durationMinutes,
    required this.timeSlot,
    required this.date,
    this.isCompleted = false,
    this.isNext = false,
    this.notes,
  });

  final String id;
  final String clientName;
  final String workoutType;
  final int durationMinutes;
  final String timeSlot;
  final DateTime date;
  final bool isCompleted;
  final bool isNext;
  final String? notes;

  TrainerScheduleSession copyWith({
    String? id,
    String? clientName,
    String? workoutType,
    int? durationMinutes,
    String? timeSlot,
    DateTime? date,
    bool? isCompleted,
    bool? isNext,
    String? notes,
  }) {
    return TrainerScheduleSession(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      workoutType: workoutType ?? this.workoutType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      timeSlot: timeSlot ?? this.timeSlot,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      isNext: isNext ?? this.isNext,
      notes: notes ?? this.notes,
    );
  }
}
