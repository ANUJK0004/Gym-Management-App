import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trainer_dashboard_data_model.dart';
import '../../domain/entities/trainer_dashboard_data.dart';

class TrainerDashboardRemoteDataSource {
  const TrainerDashboardRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> _trainerSessions(String trainerId) =>
      _firestore.collection('users').doc(trainerId).collection('sessions');

  CollectionReference<Map<String, dynamic>> _trainerClients(String trainerId) =>
      _firestore.collection('users').doc(trainerId).collection('clients');

  // ===========================================================================
  // GET DASHBOARD
  // ===========================================================================

  Future<TrainerDashboardDataModel> getDashboard({
    required String trainerId,
  }) async {
    // 1. Fetch trainer user profile from Firestore
    final userDoc = await _usersCollection.doc(trainerId).get();
    final userData = userDoc.data() ?? {};

    final trainerName = (userData['displayName'] as String?)?.trim();
    final effectiveName =
        (trainerName != null && trainerName.isNotEmpty) ? trainerName : 'Coach Mike';

    final trainerEmail =
        (userData['email'] as String?) ?? 'coach.mike@sweatsync.com';
    final trainerPhotoUrl = userData['photoUrl'] as String?;

    final initials = _getInitials(effectiveName);

    // 2. Fetch Sessions for this Trainer
    var sessionsSnapshot = await _trainerSessions(trainerId)
        .orderBy('scheduledOrder', descending: false)
        .get();

    // Auto-seed initial sessions if empty
    if (sessionsSnapshot.docs.isEmpty) {
      await _seedInitialSessions(trainerId);
      sessionsSnapshot = await _trainerSessions(trainerId)
          .orderBy('scheduledOrder', descending: false)
          .get();
    }

    final allSessions = sessionsSnapshot.docs.map((doc) {
      final data = doc.data();
      return TrainerSessionModel(
        id: doc.id,
        clientName: data['clientName'] as String? ?? 'Client',
        clientAvatar: data['clientAvatar'] as String?,
        clientInitials: data['clientInitials'] as String? ?? 'CL',
        workoutType: data['workoutType'] as String? ?? 'Workout',
        durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? 45,
        startTime: data['startTime'] as String? ?? '11:00 AM',
        startsIn: data['startsIn'] as String? ?? 'In 35 minutes',
        iconEmoji: data['iconEmoji'] as String? ?? '💪',
        isCompleted: data['isCompleted'] as bool? ?? false,
      );
    }).toList();

    // 3. Fetch Clients for this Trainer
    var clientsSnapshot = await _trainerClients(trainerId)
        .orderBy('progressPercentage', descending: true)
        .get();

    // Auto-seed initial clients if empty
    if (clientsSnapshot.docs.isEmpty) {
      await _seedInitialClients(trainerId);
      clientsSnapshot = await _trainerClients(trainerId)
          .orderBy('progressPercentage', descending: true)
          .get();
    }

    final clientsList = clientsSnapshot.docs.map((doc) {
      final data = doc.data();
      return TrainerClientProgressModel(
        id: doc.id,
        name: data['name'] as String? ?? 'Client',
        initials: data['initials'] as String? ?? 'CL',
        goal: data['goal'] as String? ?? 'Fitness',
        sessionsCount: (data['sessionsCount'] as num?)?.toInt() ?? 0,
        progressPercentage:
            (data['progressPercentage'] as num?)?.toInt() ?? 0,
        isOnline: data['isOnline'] as bool? ?? true,
        avatarUrl: data['avatarUrl'] as String?,
      );
    }).toList();

    // 4. Compute Today's Schedule Metrics
    final todaySessionsCount =
        allSessions.isNotEmpty ? allSessions.length : 8;

    // Distinct client names for today's sessions
    final distinctClients =
        allSessions.map((s) => s.clientName).toSet().length;
    final todayClientsCount =
        distinctClients > 0 ? distinctClients : (clientsList.isNotEmpty ? clientsList.length : 4);

    // Sum active minutes and format to "Xh Ym"
    final totalMinutes = allSessions.fold<int>(
      0,
      (acc, s) => acc + s.durationMinutes,
    );
    final activeHours = totalMinutes > 0
        ? '${totalMinutes ~/ 60}h ${totalMinutes % 60 > 0 ? "${totalMinutes % 60}m" : ""}'
        : '6h 30m';

    // Next Session is the first uncompleted session
    TrainerSession? nextSession;
    for (final session in allSessions) {
      if (!session.isCompleted) {
        nextSession = session;
        break;
      }
    }
    nextSession ??= allSessions.isNotEmpty ? allSessions.first : null;

    return TrainerDashboardDataModel(
      trainerId: trainerId,
      trainerName: effectiveName,
      trainerEmail: trainerEmail,
      trainerPhotoUrl: trainerPhotoUrl,
      initials: initials,
      todaySessionsCount: todaySessionsCount,
      todayClientsCount: todayClientsCount,
      todayActiveHours: activeHours.trim(),
      nextSession: nextSession,
      clients: clientsList,
      todaySchedule: allSessions,
    );
  }

  // ===========================================================================
  // SESSION ACTIONS
  // ===========================================================================

  Future<void> startSession({
    required String trainerId,
    required String sessionId,
  }) async {
    await _trainerSessions(trainerId).doc(sessionId).update({
      'status': 'in_progress',
      'startedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeSession({
    required String trainerId,
    required String sessionId,
    String? clientId,
  }) async {
    await _trainerSessions(trainerId).doc(sessionId).update({
      'isCompleted': true,
      'status': 'completed',
      'startsIn': 'Completed',
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (clientId != null && clientId.isNotEmpty) {
      await _trainerClients(trainerId).doc(clientId).update({
        'sessionsCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> addSession({
    required String trainerId,
    required TrainerSession session,
  }) async {
    final docRef = session.id.isNotEmpty
        ? _trainerSessions(trainerId).doc(session.id)
        : _trainerSessions(trainerId).doc();

    await docRef.set({
      'clientName': session.clientName,
      'clientAvatar': session.clientAvatar,
      'clientInitials': session.clientInitials,
      'workoutType': session.workoutType,
      'durationMinutes': session.durationMinutes,
      'startTime': session.startTime,
      'startsIn': session.startsIn,
      'iconEmoji': session.iconEmoji,
      'isCompleted': session.isCompleted,
      'status': session.isCompleted ? 'completed' : 'upcoming',
      'scheduledOrder': DateTime.now().millisecondsSinceEpoch,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ===========================================================================
  // CLIENT ACTIONS
  // ===========================================================================

  Future<void> addClient({
    required String trainerId,
    required TrainerClientProgress client,
  }) async {
    final docRef = client.id.isNotEmpty
        ? _trainerClients(trainerId).doc(client.id)
        : _trainerClients(trainerId).doc();

    await docRef.set({
      'name': client.name,
      'initials': client.initials,
      'goal': client.goal,
      'sessionsCount': client.sessionsCount,
      'progressPercentage': client.progressPercentage,
      'isOnline': client.isOnline,
      'avatarUrl': client.avatarUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateClientProgress({
    required String trainerId,
    required String clientId,
    required int progressPercentage,
    int? sessionsCount,
  }) async {
    final updates = <String, dynamic>{
      'progressPercentage': progressPercentage.clamp(0, 100),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (sessionsCount != null) {
      updates['sessionsCount'] = sessionsCount;
    }

    await _trainerClients(trainerId).doc(clientId).update(updates);
  }

  // ===========================================================================
  // AUTO-SEED STARTER DATA
  // ===========================================================================

  Future<void> _seedInitialSessions(String trainerId) async {
    final initialSessions = [
      {
        'id': 'sched_001',
        'clientName': 'David Miller',
        'clientInitials': 'DM',
        'workoutType': 'CrossFit Prep',
        'durationMinutes': 60,
        'startTime': '08:30 AM',
        'startsIn': 'Completed',
        'iconEmoji': '🔥',
        'isCompleted': true,
        'scheduledOrder': 1,
      },
      {
        'id': 'sched_002',
        'clientName': 'Emma Davis',
        'clientInitials': 'ED',
        'workoutType': 'Marathon Prep',
        'durationMinutes': 45,
        'startTime': '10:00 AM',
        'startsIn': 'Completed',
        'iconEmoji': '🏃',
        'isCompleted': true,
        'scheduledOrder': 2,
      },
      {
        'id': 'sched_003',
        'clientName': 'Sarah Chen',
        'clientInitials': 'SC',
        'workoutType': 'HIIT Training',
        'durationMinutes': 45,
        'startTime': '11:00 AM',
        'startsIn': 'In 35 minutes',
        'iconEmoji': '💪',
        'isCompleted': false,
        'scheduledOrder': 3,
      },
      {
        'id': 'sched_004',
        'clientName': 'Marcus King',
        'clientInitials': 'MK',
        'workoutType': 'Muscle Gain',
        'durationMinutes': 60,
        'startTime': '02:00 PM',
        'startsIn': 'In 3h 35m',
        'iconEmoji': '🏋️',
        'isCompleted': false,
        'scheduledOrder': 4,
      },
      {
        'id': 'sched_005',
        'clientName': 'James Liu',
        'clientInitials': 'JL',
        'workoutType': 'Strength Training',
        'durationMinutes': 45,
        'startTime': '04:30 PM',
        'startsIn': 'In 6h 05m',
        'iconEmoji': '⚡',
        'isCompleted': false,
        'scheduledOrder': 5,
      },
      {
        'id': 'sched_006',
        'clientName': 'Elena Rostova',
        'clientInitials': 'ER',
        'workoutType': 'Mobility & Core',
        'durationMinutes': 45,
        'startTime': '06:00 PM',
        'startsIn': 'In 7h 35m',
        'iconEmoji': '🧘',
        'isCompleted': false,
        'scheduledOrder': 6,
      },
      {
        'id': 'sched_007',
        'clientName': 'Sarah Chen',
        'clientInitials': 'SC',
        'workoutType': 'Cardio Recovery',
        'durationMinutes': 45,
        'startTime': '07:00 PM',
        'startsIn': 'In 8h 35m',
        'iconEmoji': '🏃',
        'isCompleted': false,
        'scheduledOrder': 7,
      },
      {
        'id': 'sched_008',
        'clientName': 'Marcus King',
        'clientInitials': 'MK',
        'workoutType': 'Core & Stretching',
        'durationMinutes': 45,
        'startTime': '08:00 PM',
        'startsIn': 'In 9h 35m',
        'iconEmoji': '🧘',
        'isCompleted': false,
        'scheduledOrder': 8,
      },
    ];

    final batch = _firestore.batch();
    for (final s in initialSessions) {
      final docRef = _trainerSessions(trainerId).doc(s['id'] as String);
      batch.set(docRef, {
        ...s,
        'trainerId': trainerId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> _seedInitialClients(String trainerId) async {
    final initialClients = [
      {
        'id': 'client_001',
        'name': 'Sarah Chen',
        'initials': 'SC',
        'goal': 'Weight Loss',
        'sessionsCount': 12,
        'progressPercentage': 72,
        'isOnline': true,
      },
      {
        'id': 'client_002',
        'name': 'Marcus King',
        'initials': 'MK',
        'goal': 'Muscle Gain',
        'sessionsCount': 8,
        'progressPercentage': 58,
        'isOnline': true,
      },
      {
        'id': 'client_003',
        'name': 'Emma Davis',
        'initials': 'ED',
        'goal': 'Marathon Prep',
        'sessionsCount': 20,
        'progressPercentage': 85,
        'isOnline': true,
      },
      {
        'id': 'client_004',
        'name': 'James Liu',
        'initials': 'JL',
        'goal': 'Strength Training',
        'sessionsCount': 15,
        'progressPercentage': 40,
        'isOnline': true,
      },
      {
        'id': 'client_005',
        'name': 'Elena Rostova',
        'initials': 'ER',
        'goal': 'Mobility & Core',
        'sessionsCount': 6,
        'progressPercentage': 64,
        'isOnline': false,
      },
      {
        'id': 'client_006',
        'name': 'David Miller',
        'initials': 'DM',
        'goal': 'CrossFit Prep',
        'sessionsCount': 10,
        'progressPercentage': 90,
        'isOnline': true,
      },
    ];

    final batch = _firestore.batch();
    for (final c in initialClients) {
      final docRef = _trainerClients(trainerId).doc(c['id'] as String);
      batch.set(docRef, {
        ...c,
        'trainerId': trainerId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  static String _getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'MT';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
