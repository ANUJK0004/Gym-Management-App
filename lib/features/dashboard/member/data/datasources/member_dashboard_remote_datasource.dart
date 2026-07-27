import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/member_dashboard_model.dart';

class MemberDashboardRemoteDataSource {
  MemberDashboardRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  Future<MemberDashboardModel> getMemberDashboard(
      String uid,
      ) async {
    final results = await Future.wait([
      _getUser(uid),
      _getWorkoutProgress(uid),
      _getBodyMetrics(uid),
    ]);

    final userData =
    results[0] as Map<String, dynamic>;

    final progressData =
    results[1];

    final bodyMetricsData =
    results[2];

    return MemberDashboardModel.fromMap({
      // User
      'userName':
      userData['displayName'] ?? '',
      'photoUrl':
      userData['photoUrl'],
      'fitnessGoal':
      userData['fitnessGoal'],
      'activityLevel':
      userData['activityLevel'],
      'height':
      userData['height'],
      'weight':
      userData['weight'],

      // Progress
      'completedWorkouts':
      progressData?['completedWorkouts'] ?? 0,
      'totalWorkouts':
      progressData?['totalWorkouts'] ?? 0,

      // Body metrics
      'currentWeight':
      bodyMetricsData?['currentWeight'] ?? 0,
      'previousWeight':
      bodyMetricsData?['previousWeight'] ?? 0,
    });
  }

  Future<Map<String, dynamic>> _getUser(
      String uid,
      ) async {
    final document = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!document.exists) {
      throw Exception(
        'User profile not found.',
      );
    }

    return document.data() ?? {};
  }

  Future<Map<String, dynamic>?> _getWorkoutProgress(
      String uid,
      ) async {
    final document = await _firestore
        .collection('workout_progress')
        .doc(uid)
        .get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }

  Future<Map<String, dynamic>?> _getBodyMetrics(
      String uid,
      ) async {
    final document = await _firestore
        .collection('body_metrics')
        .doc(uid)
        .get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }
}