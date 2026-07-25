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
    // 1. Get user profile
    final userDocument = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!userDocument.exists) {
      throw Exception(
        'User profile not found.',
      );
    }

    final userData =
        userDocument.data() ?? {};

    // 2. Get membership
    final membershipSnapshot =
    await _firestore
        .collection('memberships')
        .where(
      'userId',
      isEqualTo: uid,
    )
        .limit(1)
        .get();

    Map<String, dynamic> membershipData = {};

    if (membershipSnapshot.docs.isNotEmpty) {
      membershipData =
          membershipSnapshot.docs.first.data();
    }

    // 3. Get today's workout
    final workoutSnapshot =
    await _firestore
        .collection('workouts')
        .where(
      'userId',
      isEqualTo: uid,
    )
        .limit(1)
        .get();

    Map<String, dynamic> workoutData = {};

    if (workoutSnapshot.docs.isNotEmpty) {
      workoutData =
          workoutSnapshot.docs.first.data();
    }

    // 4. Get workout progress
    final progressDocument =
    await _firestore
        .collection('workout_progress')
        .doc(uid)
        .get();

    final progressData =
        progressDocument.data() ?? {};

    // 5. Get body metrics
    final metricsDocument =
    await _firestore
        .collection('body_metrics')
        .doc(uid)
        .get();

    final metricsData =
        metricsDocument.data() ?? {};

    // 6. Combine everything
    return MemberDashboardModel.fromMap({
      // User
      'userName':
      userData['displayName'] ?? 'User',

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
      membershipData['gymName'] ??
          'No Gym',

      'membershipStatus':
      membershipData['status'] ??
          'Inactive',

      'membershipExpiryDate':
      membershipData['expiryDate'],

      // Workout
      'workoutName':
      workoutData['name'] ??
          'No workout',

      'workoutDescription':
      workoutData['description'] ??
          '',

      'exerciseCount':
      workoutData['exerciseCount'] ??
          0,

      'workoutDuration':
      workoutData['duration'] ??
          0,

      // Progress
      'completedWorkouts':
      progressData['completedWorkouts'] ??
          0,

      'totalWorkouts':
      progressData['totalWorkouts'] ??
          0,

      // Metrics
      'currentWeight':
      metricsData['currentWeight'] ??
          userData['weight'] ??
          0,

      'previousWeight':
      metricsData['previousWeight'] ??
          userData['weight'] ??
          0,
    });
  }
}