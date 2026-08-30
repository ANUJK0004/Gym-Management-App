import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trainer_schedule_session_model.dart';

class TrainerScheduleRemoteDataSource {
  const TrainerScheduleRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _trainerSessions(String trainerId) =>
      _firestore.collection('users').doc(trainerId).collection('sessions');

  // ===========================================================================
  // REAL-TIME STREAM WATCH SESSIONS
  // ===========================================================================

  Stream<List<TrainerScheduleSessionModel>> watchSessions({
    required String trainerId,
  }) {
    return _trainerSessions(trainerId)
        .orderBy('scheduledOrder', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TrainerScheduleSessionModel.fromJson(doc.data(), id: doc.id);
      }).toList();
    });
  }

  // ===========================================================================
  // GET SESSIONS (ONE-TIME FETCH WITH AUTO-SEEDING)
  // ===========================================================================

  Future<List<TrainerScheduleSessionModel>> getSessions({
    required String trainerId,
    DateTime? date,
  }) async {
    var query = _trainerSessions(trainerId)
        .orderBy('scheduledOrder', descending: false);

    var snapshot = await query.get();

    // Auto-seed starter sessions if empty
    if (snapshot.docs.isEmpty) {
      await _seedStarterSessions(trainerId);
      snapshot = await query.get();
    }

    final allSessions = snapshot.docs.map((doc) {
      return TrainerScheduleSessionModel.fromJson(doc.data(), id: doc.id);
    }).toList();

    if (date != null) {
      return allSessions.where((s) {
        return s.date.year == date.year &&
            s.date.month == date.month &&
            s.date.day == date.day;
      }).toList();
    }

    return allSessions;
  }

  // ===========================================================================
  // ADD SESSION
  // ===========================================================================

  Future<TrainerScheduleSessionModel> addSession({
    required String trainerId,
    required TrainerScheduleSessionModel session,
  }) async {
    final collection = _trainerSessions(trainerId);
    final docRef = session.id.isNotEmpty
        ? collection.doc(session.id)
        : collection.doc();

    final modelWithId = session.id.isNotEmpty
        ? session
        : TrainerScheduleSessionModel(
            id: docRef.id,
            trainerId: trainerId,
            clientId: session.clientId,
            clientName: session.clientName,
            clientAvatar: session.clientAvatar,
            clientInitials: session.clientInitials,
            workoutType: session.workoutType,
            durationMinutes: session.durationMinutes,
            timeSlot: session.timeSlot,
            startTime: session.startTime,
            startsIn: session.startsIn,
            date: session.date,
            isCompleted: session.isCompleted,
            isNext: session.isNext,
            status: session.status,
            notes: session.notes,
            iconEmoji: session.iconEmoji,
            scheduledOrder: session.scheduledOrder ?? session.date.millisecondsSinceEpoch,
            createdAt: session.createdAt ?? DateTime.now(),
          );

    await docRef.set(modelWithId.toJson());
    return modelWithId;
  }

  // ===========================================================================
  // UPDATE SESSION
  // ===========================================================================

  Future<void> updateSession({
    required String trainerId,
    required TrainerScheduleSessionModel session,
  }) async {
    await _trainerSessions(trainerId).doc(session.id).set(
          session.toJson(),
          SetOptions(merge: true),
        );
  }

  // ===========================================================================
  // TOGGLE SESSION COMPLETED
  // ===========================================================================

  Future<void> toggleSessionCompleted({
    required String trainerId,
    required String sessionId,
    required bool isCompleted,
  }) async {
    await _trainerSessions(trainerId).doc(sessionId).update({
      'isCompleted': isCompleted,
      'status': isCompleted ? 'completed' : 'upcoming',
      'startsIn': isCompleted ? 'Completed' : 'Upcoming',
      'isNext': false,
      'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ===========================================================================
  // DELETE SESSION
  // ===========================================================================

  Future<void> deleteSession({
    required String trainerId,
    required String sessionId,
  }) async {
    await _trainerSessions(trainerId).doc(sessionId).delete();
  }

  // ===========================================================================
  // STARTER SESSIONS SEEDING (CURRENT REAL-WORLD WEEK DYNAMIC)
  // ===========================================================================

  Future<void> _seedStarterSessions(String trainerId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));

    final starterSessions = <Map<String, dynamic>>[];

    // 1. Sessions for Today
    starterSessions.addAll([
      {
        'id': 'session_today_1',
        'trainerId': trainerId,
        'clientName': 'Emma Davis',
        'clientInitials': 'ED',
        'workoutType': 'Strength Training',
        'durationMinutes': 45,
        'timeSlot': '8:00 AM',
        'startTime': '8:00 AM',
        'startsIn': 'Completed',
        'date': Timestamp.fromDate(today),
        'isCompleted': true,
        'isNext': false,
        'status': 'completed',
        'scheduledOrder': 1,
      },
      {
        'id': 'session_today_2',
        'trainerId': trainerId,
        'clientName': 'Jake Wilson',
        'clientInitials': 'JW',
        'workoutType': 'Cardio & Core',
        'durationMinutes': 45,
        'timeSlot': '9:30 AM',
        'startTime': '9:30 AM',
        'startsIn': 'Completed',
        'date': Timestamp.fromDate(today),
        'isCompleted': true,
        'isNext': false,
        'status': 'completed',
        'scheduledOrder': 2,
      },
      {
        'id': 'session_today_3',
        'trainerId': trainerId,
        'clientName': 'Sarah Chen',
        'clientInitials': 'SC',
        'workoutType': 'HIIT Training',
        'durationMinutes': 45,
        'timeSlot': '11:00 AM',
        'startTime': '11:00 AM',
        'startsIn': 'In 35 minutes',
        'date': Timestamp.fromDate(today),
        'isCompleted': false,
        'isNext': true,
        'status': 'upcoming',
        'scheduledOrder': 3,
      },
      {
        'id': 'session_today_4',
        'trainerId': trainerId,
        'clientName': 'Marcus King',
        'clientInitials': 'MK',
        'workoutType': 'Hypertrophy',
        'durationMinutes': 60,
        'timeSlot': '1:00 PM',
        'startTime': '1:00 PM',
        'startsIn': 'In 2 hours',
        'date': Timestamp.fromDate(today),
        'isCompleted': false,
        'isNext': false,
        'status': 'upcoming',
        'scheduledOrder': 4,
      },
      {
        'id': 'session_today_5',
        'trainerId': trainerId,
        'clientName': 'Emma Davis',
        'clientInitials': 'ED',
        'workoutType': 'Flexibility & Mobility',
        'durationMinutes': 30,
        'timeSlot': '3:30 PM',
        'startTime': '3:30 PM',
        'startsIn': 'In 4 hours',
        'date': Timestamp.fromDate(today),
        'isCompleted': false,
        'isNext': false,
        'status': 'upcoming',
        'scheduledOrder': 5,
      },
      {
        'id': 'session_today_6',
        'trainerId': trainerId,
        'clientName': 'New Client',
        'clientInitials': 'NC',
        'workoutType': 'Assessment',
        'durationMinutes': 45,
        'timeSlot': '5:00 PM',
        'startTime': '5:00 PM',
        'startsIn': 'In 6 hours',
        'date': Timestamp.fromDate(today),
        'isCompleted': false,
        'isNext': false,
        'status': 'upcoming',
        'scheduledOrder': 6,
      },
    ]);

    // 2. Surrounding days of the current week
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      if (day.year == today.year &&
          day.month == today.month &&
          day.day == today.day) {
        continue;
      }

      final isPast = day.isBefore(today);

      starterSessions.addAll([
        {
          'id': 'session_day_${i}_1',
          'trainerId': trainerId,
          'clientName': i % 2 == 0 ? 'Sarah Chen' : 'Marcus King',
          'clientInitials': i % 2 == 0 ? 'SC' : 'MK',
          'workoutType': i % 2 == 0 ? 'HIIT Training' : 'Strength Training',
          'durationMinutes': 45,
          'timeSlot': '9:00 AM',
          'startTime': '9:00 AM',
          'date': Timestamp.fromDate(day),
          'isCompleted': isPast,
          'status': isPast ? 'completed' : 'upcoming',
          'scheduledOrder': 100 + i * 2,
        },
        {
          'id': 'session_day_${i}_2',
          'trainerId': trainerId,
          'clientName': i % 2 == 0 ? 'Jake Wilson' : 'Lisa Park',
          'clientInitials': i % 2 == 0 ? 'JW' : 'LP',
          'workoutType': i % 2 == 0 ? 'Cardio & Core' : 'Assessment',
          'durationMinutes': 60,
          'timeSlot': '2:00 PM',
          'startTime': '2:00 PM',
          'date': Timestamp.fromDate(day),
          'isCompleted': isPast,
          'status': isPast ? 'completed' : 'upcoming',
          'scheduledOrder': 101 + i * 2,
        },
      ]);
    }

    final batch = _firestore.batch();
    for (final s in starterSessions) {
      final docRef = _trainerSessions(trainerId).doc(s['id'] as String);
      batch.set(docRef, {
        ...s,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
