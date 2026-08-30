import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trainer_schedule_session.dart';

class TrainerScheduleSessionModel extends TrainerScheduleSession {
  const TrainerScheduleSessionModel({
    required super.id,
    super.trainerId,
    super.clientId,
    required super.clientName,
    super.clientAvatar,
    super.clientInitials = 'CL',
    required super.workoutType,
    required super.durationMinutes,
    required super.timeSlot,
    super.startTime,
    super.startsIn = 'Upcoming',
    required super.date,
    super.isCompleted = false,
    super.isNext = false,
    super.status = 'upcoming',
    super.notes,
    super.iconEmoji = '💪',
    super.scheduledOrder,
    super.createdAt,
    super.updatedAt,
  });

  factory TrainerScheduleSessionModel.fromJson(
    Map<String, dynamic> json, {
    String? id,
  }) {
    // Parse date
    DateTime parsedDate = DateTime.now();
    final rawDate = json['date'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    // Parse createdAt
    DateTime? createdAt;
    final rawCreatedAt = json['createdAt'];
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    }

    // Parse updatedAt
    DateTime? updatedAt;
    final rawUpdatedAt = json['updatedAt'];
    if (rawUpdatedAt is Timestamp) {
      updatedAt = rawUpdatedAt.toDate();
    }

    final duration = (json['durationMinutes'] as num?)?.toInt() ?? 45;
    final timeSlot = json['timeSlot'] as String? ?? json['startTime'] as String? ?? '9:00 AM';

    return TrainerScheduleSessionModel(
      id: id ?? (json['id'] as String? ?? ''),
      trainerId: json['trainerId'] as String?,
      clientId: json['clientId'] as String?,
      clientName: json['clientName'] as String? ?? 'Client',
      clientAvatar: json['clientAvatar'] as String?,
      clientInitials: json['clientInitials'] as String? ?? _getInitials(json['clientName'] as String? ?? 'CL'),
      workoutType: json['workoutType'] as String? ?? 'Workout',
      durationMinutes: duration,
      timeSlot: timeSlot,
      startTime: json['startTime'] as String? ?? timeSlot,
      startsIn: json['startsIn'] as String? ?? 'Upcoming',
      date: parsedDate,
      isCompleted: json['isCompleted'] as bool? ?? (json['status'] == 'completed'),
      isNext: json['isNext'] as bool? ?? false,
      status: json['status'] as String? ?? (json['isCompleted'] == true ? 'completed' : 'upcoming'),
      notes: json['notes'] as String?,
      iconEmoji: json['iconEmoji'] as String? ?? '💪',
      scheduledOrder: (json['scheduledOrder'] as num?)?.toInt(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory TrainerScheduleSessionModel.fromDomain(TrainerScheduleSession session) {
    return TrainerScheduleSessionModel(
      id: session.id,
      trainerId: session.trainerId,
      clientId: session.clientId,
      clientName: session.clientName,
      clientAvatar: session.clientAvatar,
      clientInitials: session.clientInitials,
      workoutType: session.workoutType,
      durationMinutes: session.durationMinutes,
      timeSlot: session.timeSlot,
      startTime: session.startTime ?? session.timeSlot,
      startsIn: session.startsIn,
      date: session.date,
      isCompleted: session.isCompleted,
      isNext: session.isNext,
      status: session.status,
      notes: session.notes,
      iconEmoji: session.iconEmoji,
      scheduledOrder: session.scheduledOrder,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (trainerId != null) 'trainerId': trainerId,
      if (clientId != null) 'clientId': clientId,
      'clientName': clientName,
      'clientAvatar': clientAvatar,
      'clientInitials': clientInitials,
      'workoutType': workoutType,
      'durationMinutes': durationMinutes,
      'timeSlot': timeSlot,
      'startTime': startTime ?? timeSlot,
      'startsIn': startsIn,
      'date': Timestamp.fromDate(date),
      'isCompleted': isCompleted,
      'isNext': isNext,
      'status': isCompleted ? 'completed' : status,
      'notes': notes,
      'iconEmoji': iconEmoji,
      'scheduledOrder': scheduledOrder ?? date.millisecondsSinceEpoch,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'CL';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
