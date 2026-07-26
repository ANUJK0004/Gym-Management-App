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
      _getMembership(uid),
      _getWorkout(uid),
      _getWorkoutProgress(uid),
      _getBodyMetrics(uid),
    ]);

    final userData =
    results[0] as Map<String, dynamic>;

    final membershipData =
    results[1];

    final workoutData =
    results[2];

    final progressData =
    results[3];

    final bodyMetricsData =
    results[4];

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

      // Membership
      'gymName':
      membershipData?['gymName'] ?? '',
      'membershipStatus':
      membershipData?['status'] ?? 'Inactive',
      'membershipExpiryDate':
      membershipData?['expiryDate'],

      // Workout
      'workoutName':
      workoutData?['name'] ?? 'No workout',
      'workoutDescription':
      workoutData?['description'] ?? '',
      'exerciseCount':
      workoutData?['exerciseCount'] ?? 0,
      'workoutDuration':
      workoutData?['duration'] ?? 0,

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

  Future<Map<String, dynamic>?> _getMembership(
      String uid,
      ) async {
    final snapshot = await _firestore
        .collection('memberships')
        .where(
      'userId',
      isEqualTo: uid,
    )
        .where(
      'status',
      isEqualTo: 'Active',
    )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first.data();
  }

  Future<Map<String, dynamic>?> _getWorkout(
      String uid,
      ) async {
    final snapshot = await _firestore
        .collection('workouts')
        .where(
      'userId',
      isEqualTo: uid,
    )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first.data();
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