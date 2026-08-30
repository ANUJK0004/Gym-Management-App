import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/trainer_client.dart';
import '../models/trainer_client_model.dart';
import 'client_management_datasource.dart';
import 'client_management_mock_datasource.dart';

class ClientManagementRemoteDatasource implements ClientManagementDatasource {
  ClientManagementRemoteDatasource(this._firestore, [this._auth]);

  final FirebaseFirestore _firestore;
  final FirebaseAuth? _auth;

  String _resolveTrainerId(String? trainerId) {
    if (trainerId != null && trainerId.isNotEmpty) {
      return trainerId;
    }
    return _auth?.currentUser?.uid ?? 'trainer_001';
  }

  CollectionReference<Map<String, dynamic>> _trainerClients(String? trainerId) {
    final effectiveTrainerId = _resolveTrainerId(trainerId);
    return _firestore
        .collection('users')
        .doc(effectiveTrainerId)
        .collection('clients');
  }

  // ===========================================================================
  // REAL-TIME STREAM WATCH CLIENTS
  // ===========================================================================

  @override
  Stream<List<TrainerClientModel>> watchClients({String? trainerId}) {
    return _trainerClients(trainerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _mapDocToModel(doc)).toList();
    });
  }

  // ===========================================================================
  // GET CLIENTS (WITH STARTER SEEDING ON EMPTY)
  // ===========================================================================

  @override
  Future<List<TrainerClientModel>> getClients({String? trainerId}) async {
    final collection = _trainerClients(trainerId);
    var snapshot = await collection.orderBy('createdAt', descending: true).get();

    if (snapshot.docs.isEmpty) {
      await _seedStarterClients(trainerId);
      snapshot = await collection.orderBy('createdAt', descending: true).get();
    }

    return snapshot.docs.map((doc) => _mapDocToModel(doc)).toList();
  }

  // ===========================================================================
  // ADD CLIENT
  // ===========================================================================

  @override
  Future<TrainerClientModel> addClient(
    TrainerClientModel client, {
    String? trainerId,
  }) async {
    final collection = _trainerClients(trainerId);
    final docRef =
        client.id.isNotEmpty ? collection.doc(client.id) : collection.doc();

    final modelWithId = client.id.isNotEmpty
        ? client
        : TrainerClientModel(
            id: docRef.id,
            name: client.name,
            initials: client.initials,
            email: client.email,
            age: client.age,
            heightCm: client.heightCm,
            weightKg: client.weightKg,
            goal: client.goal,
            trainingPlan: client.trainingPlan,
            sessionsCount: client.sessionsCount,
            progressPercentage: client.progressPercentage,
            streakDays: client.streakDays,
            nextSession: client.nextSession,
            isActive: client.isActive,
            avatarUrl: client.avatarUrl,
            joinedDate: client.joinedDate ?? DateTime.now(),
            phone: client.phone,
            notes: client.notes,
            attendanceRate: client.attendanceRate,
            attendanceDelta: client.attendanceDelta,
            avgIntensity: client.avgIntensity,
            intensityDelta: client.intensityDelta,
            weightChange: client.weightChange,
            goalOnTrack: client.goalOnTrack,
            weeklyActivity: client.weeklyActivity,
            upcomingSessions: client.upcomingSessions,
          );

    await docRef.set({
      'id': modelWithId.id,
      'name': modelWithId.name,
      'initials': modelWithId.initials,
      'email': modelWithId.email,
      'age': modelWithId.age,
      'heightCm': modelWithId.heightCm,
      'weightKg': modelWithId.weightKg,
      'goal': modelWithId.goal,
      'trainingPlan': modelWithId.trainingPlan,
      'sessionsCount': modelWithId.sessionsCount,
      'progressPercentage': modelWithId.progressPercentage,
      'streakDays': modelWithId.streakDays,
      'nextSession': modelWithId.nextSession,
      'isActive': modelWithId.isActive,
      'avatarUrl': modelWithId.avatarUrl,
      'joinedDate': modelWithId.joinedDate != null
          ? Timestamp.fromDate(modelWithId.joinedDate!)
          : FieldValue.serverTimestamp(),
      'phone': modelWithId.phone,
      'notes': modelWithId.notes,
      'attendanceRate': modelWithId.attendanceRate,
      'attendanceDelta': modelWithId.attendanceDelta,
      'avgIntensity': modelWithId.avgIntensity,
      'intensityDelta': modelWithId.intensityDelta,
      'weightChange': modelWithId.weightChange,
      'goalOnTrack': modelWithId.goalOnTrack,
      'weeklyActivity': modelWithId.weeklyActivity,
      'upcomingSessions': modelWithId.upcomingSessions
          .map((s) => {
                'id': s.id,
                'dayLabel': s.dayLabel,
                'title': s.title,
                'time': s.time,
                'durationMinutes': s.durationMinutes,
              })
          .toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return modelWithId;
  }

  // ===========================================================================
  // UPDATE CLIENT
  // ===========================================================================

  @override
  Future<TrainerClientModel> updateClient(
    TrainerClientModel client, {
    String? trainerId,
  }) async {
    final docRef = _trainerClients(trainerId).doc(client.id);
    await docRef.set({
      'name': client.name,
      'initials': client.initials,
      'email': client.email,
      'age': client.age,
      'heightCm': client.heightCm,
      'weightKg': client.weightKg,
      'goal': client.goal,
      'trainingPlan': client.trainingPlan,
      'sessionsCount': client.sessionsCount,
      'progressPercentage': client.progressPercentage,
      'streakDays': client.streakDays,
      'nextSession': client.nextSession,
      'isActive': client.isActive,
      'avatarUrl': client.avatarUrl,
      'phone': client.phone,
      'notes': client.notes,
      'attendanceRate': client.attendanceRate,
      'attendanceDelta': client.attendanceDelta,
      'avgIntensity': client.avgIntensity,
      'intensityDelta': client.intensityDelta,
      'weightChange': client.weightChange,
      'goalOnTrack': client.goalOnTrack,
      'weeklyActivity': client.weeklyActivity,
      'upcomingSessions': client.upcomingSessions
          .map((s) => {
                'id': s.id,
                'dayLabel': s.dayLabel,
                'title': s.title,
                'time': s.time,
                'durationMinutes': s.durationMinutes,
              })
          .toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return client;
  }

  // ===========================================================================
  // UPDATE NOTES
  // ===========================================================================

  @override
  Future<void> updateNotes(
    String clientId,
    String notes, {
    String? trainerId,
  }) async {
    final docRef = _trainerClients(trainerId).doc(clientId);
    await docRef.update({
      'notes': notes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ===========================================================================
  // DELETE CLIENT
  // ===========================================================================

  @override
  Future<void> deleteClient(String clientId, {String? trainerId}) async {
    await _trainerClients(trainerId).doc(clientId).delete();
  }

  // ===========================================================================
  // TOGGLE CLIENT ACTIVE STATUS
  // ===========================================================================

  @override
  Future<void> toggleClientActiveStatus(
    String clientId, {
    String? trainerId,
  }) async {
    final docRef = _trainerClients(trainerId).doc(clientId);
    final doc = await docRef.get();
    if (doc.exists) {
      final current = doc.data()?['isActive'] as bool? ?? true;
      await docRef.update({
        'isActive': !current,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ===========================================================================
  // HELPER: MAP DOC TO MODEL
  // ===========================================================================

  TrainerClientModel _mapDocToModel(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final rawJoined = data['joinedDate'];
    DateTime? joinedDate;
    if (rawJoined is Timestamp) {
      joinedDate = rawJoined.toDate();
    } else if (rawJoined is String) {
      joinedDate = DateTime.tryParse(rawJoined);
    }

    final rawUpcoming = data['upcomingSessions'] as List<dynamic>? ?? [];
    final upcomingSessions = rawUpcoming
        .map((u) {
          if (u is! Map<String, dynamic>) {
            return const ClientUpcomingSession(
              id: 's_default',
              dayLabel: 'TOD',
              title: 'Session',
              time: '11:00 AM',
              durationMinutes: 45,
            );
          }
          return ClientUpcomingSession(
            id: u['id'] as String? ?? '',
            dayLabel: u['dayLabel'] as String? ?? 'TOD',
            title: u['title'] as String? ?? 'Session',
            time: u['time'] as String? ?? '11:00 AM',
            durationMinutes: (u['durationMinutes'] as num?)?.toInt() ?? 45,
          );
        })
        .toList();

    final rawWeekly = data['weeklyActivity'] as List<dynamic>?;
    final weeklyActivity = rawWeekly != null
        ? rawWeekly.map((w) => (w as num).toDouble()).toList()
        : const [0.55, 0.75, 0.1, 0.9, 0.72, 0.8, 0.65];

    return TrainerClientModel(
      id: doc.id,
      name: data['name'] as String? ?? 'Client',
      initials: data['initials'] as String? ??
          TrainerClient.generateInitials(data['name'] as String? ?? ''),
      email: data['email'] as String? ?? '',
      age: (data['age'] as num?)?.toInt(),
      heightCm: (data['heightCm'] as num?)?.toInt() ?? 170,
      weightKg: (data['weightKg'] as num?)?.toDouble(),
      goal: data['goal'] as String? ?? 'General Fitness',
      trainingPlan: data['trainingPlan'] as String? ?? 'Custom Plan',
      sessionsCount: (data['sessionsCount'] as num?)?.toInt() ?? 0,
      progressPercentage: (data['progressPercentage'] as num?)?.toInt() ?? 0,
      streakDays: (data['streakDays'] as num?)?.toInt() ?? 0,
      nextSession: data['nextSession'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      avatarUrl: data['avatarUrl'] as String?,
      joinedDate: joinedDate,
      phone: data['phone'] as String?,
      notes: data['notes'] as String?,
      attendanceRate: (data['attendanceRate'] as num?)?.toInt() ?? 90,
      attendanceDelta: data['attendanceDelta'] as String? ?? '+0%',
      avgIntensity: (data['avgIntensity'] as num?)?.toDouble() ?? 8.0,
      intensityDelta: data['intensityDelta'] as String? ?? '+0.0',
      weightChange: (data['weightChange'] as num?)?.toDouble() ?? 0.0,
      goalOnTrack: data['goalOnTrack'] as bool? ?? true,
      weeklyActivity: weeklyActivity,
      upcomingSessions: upcomingSessions,
    );
  }

  // ===========================================================================
  // STARTER SEEDING
  // ===========================================================================

  Future<void> _seedStarterClients(String? trainerId) async {
    final initialClients = ClientManagementMockDatasource();
    final defaults = await initialClients.getClients();
    final batch = _firestore.batch();
    final collection = _trainerClients(trainerId);

    int order = 0;
    for (final c in defaults) {
      final docRef = collection.doc(c.id);
      batch.set(docRef, {
        'id': c.id,
        'name': c.name,
        'initials': c.initials,
        'email': c.email,
        'age': c.age,
        'heightCm': c.heightCm,
        'weightKg': c.weightKg,
        'goal': c.goal,
        'trainingPlan': c.trainingPlan,
        'sessionsCount': c.sessionsCount,
        'progressPercentage': c.progressPercentage,
        'streakDays': c.streakDays,
        'nextSession': c.nextSession,
        'isActive': c.isActive,
        'avatarUrl': c.avatarUrl,
        'joinedDate': c.joinedDate != null
            ? Timestamp.fromDate(c.joinedDate!)
            : FieldValue.serverTimestamp(),
        'phone': c.phone,
        'notes': c.notes,
        'attendanceRate': c.attendanceRate,
        'attendanceDelta': c.attendanceDelta,
        'avgIntensity': c.avgIntensity,
        'intensityDelta': c.intensityDelta,
        'weightChange': c.weightChange,
        'goalOnTrack': c.goalOnTrack,
        'weeklyActivity': c.weeklyActivity,
        'upcomingSessions': c.upcomingSessions
            .map((s) => {
                  'id': s.id,
                  'dayLabel': s.dayLabel,
                  'title': s.title,
                  'time': s.time,
                  'durationMinutes': s.durationMinutes,
                })
            .toList(),
        'order': order++,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
