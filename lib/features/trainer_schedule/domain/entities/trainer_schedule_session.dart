class TrainerScheduleSession {
  const TrainerScheduleSession({
    required this.id,
    this.trainerId,
    this.clientId,
    required this.clientName,
    this.clientAvatar,
    this.clientInitials = 'CL',
    required this.workoutType,
    required this.durationMinutes,
    required this.timeSlot,
    this.startTime,
    this.startsIn = 'Upcoming',
    required this.date,
    this.isCompleted = false,
    this.isNext = false,
    this.status = 'upcoming',
    this.notes,
    this.iconEmoji = '💪',
    this.scheduledOrder,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? trainerId;
  final String? clientId;
  final String clientName;
  final String? clientAvatar;
  final String clientInitials;
  final String workoutType;
  final int durationMinutes;
  final String timeSlot;
  final String? startTime;
  final String startsIn;
  final DateTime date;
  final bool isCompleted;
  final bool isNext;
  final String status;
  final String? notes;
  final String iconEmoji;
  final int? scheduledOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TrainerScheduleSession copyWith({
    String? id,
    String? trainerId,
    String? clientId,
    String? clientName,
    String? clientAvatar,
    String? clientInitials,
    String? workoutType,
    int? durationMinutes,
    String? timeSlot,
    String? startTime,
    String? startsIn,
    DateTime? date,
    bool? isCompleted,
    bool? isNext,
    String? status,
    String? notes,
    String? iconEmoji,
    int? scheduledOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrainerScheduleSession(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientAvatar: clientAvatar ?? this.clientAvatar,
      clientInitials: clientInitials ?? this.clientInitials,
      workoutType: workoutType ?? this.workoutType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      timeSlot: timeSlot ?? this.timeSlot,
      startTime: startTime ?? this.startTime,
      startsIn: startsIn ?? this.startsIn,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      isNext: isNext ?? this.isNext,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      scheduledOrder: scheduledOrder ?? this.scheduledOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
