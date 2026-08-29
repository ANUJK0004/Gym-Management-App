import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/trainer_client.dart';
import '../models/trainer_client_model.dart';
import 'client_management_datasource.dart';
import 'client_management_mock_datasource.dart';

class ClientManagementRemoteDatasource implements ClientManagementDatasource {
  ClientManagementRemoteDatasource(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _trainerId => _auth.currentUser?.uid ?? 'trainer_001';

  CollectionReference<Map<String, dynamic>> get _clientsCollection =>
      _firestore.collection('users').doc(_trainerId).collection('clients');

  @override
  Future<List<TrainerClientModel>> getClients() async {
    try {
      var snapshot = await _clientsCollection.get();

      if (snapshot.docs.isEmpty) {
        // Seed default clients to Firestore if empty
        final initialClients = ClientManagementMockDatasource();
        final defaults = await initialClients.getClients();
        final batch = _firestore.batch();

        for (final c in defaults) {
          final docRef = _clientsCollection.doc(c.id);
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
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
        snapshot = await _clientsCollection.get();
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final rawJoined = data['joinedDate'];
        DateTime? joinedDate;
        if (rawJoined is Timestamp) {
          joinedDate = rawJoined.toDate();
        }

        final rawUpcoming = data['upcomingSessions'] as List<dynamic>? ?? [];
        final upcomingSessions = rawUpcoming
            .map((u) {
              final map = u as Map<String, dynamic>;
              return ClientUpcomingSession(
                id: map['id'] as String? ?? '',
                dayLabel: map['dayLabel'] as String? ?? 'TOD',
                title: map['title'] as String? ?? 'Session',
                time: map['time'] as String? ?? '11:00 AM',
                durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 45,
              );
            })
            .toList();

        final rawWeekly = data['weeklyActivity'] as List<dynamic>?;
        final weeklyActivity = rawWeekly != null
            ? rawWeekly.map((w) => (w as num).toDouble()).toList()
            : const [0.55, 0.75, 0.1, 0.9, 0.72, 0.8, 0.65];

        return TrainerClientModel(
          id: doc.id,
          name: data['name'] as String? ?? '',
          initials: data['initials'] as String? ?? 'CL',
          email: data['email'] as String? ?? '',
          age: (data['age'] as num?)?.toInt(),
          heightCm: (data['heightCm'] as num?)?.toInt(),
          weightKg: (data['weightKg'] as num?)?.toDouble(),
          goal: data['goal'] as String? ?? 'General Fitness',
          trainingPlan: data['trainingPlan'] as String? ?? 'Custom Plan',
          sessionsCount: (data['sessionsCount'] as num?)?.toInt() ?? 0,
          progressPercentage:
              (data['progressPercentage'] as num?)?.toInt() ?? 0,
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
      }).toList();
    } catch (_) {
      final mock = ClientManagementMockDatasource();
      return mock.getClients();
    }
  }

  @override
  Future<TrainerClientModel> addClient(TrainerClientModel client) async {
    final docRef = _clientsCollection.doc(client.id);
    await docRef.set({
      'id': client.id,
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
      'joinedDate': client.joinedDate != null
          ? Timestamp.fromDate(client.joinedDate!)
          : FieldValue.serverTimestamp(),
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
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return client;
  }

  @override
  Future<TrainerClientModel> updateClient(TrainerClientModel client) async {
    final docRef = _clientsCollection.doc(client.id);
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

  @override
  Future<void> deleteClient(String clientId) async {
    await _clientsCollection.doc(clientId).delete();
  }

  @override
  Future<void> toggleClientActiveStatus(String clientId) async {
    final docRef = _clientsCollection.doc(clientId);
    final doc = await docRef.get();
    if (doc.exists) {
      final current = doc.data()?['isActive'] as bool? ?? true;
      await docRef.update({
        'isActive': !current,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
