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
    final (userData, progressData, weeklyData) = await (
      _getUser(uid),
      _getProgress(uid),
      _getWeeklyActivityAndCompletions(uid),
    ).wait;

    final currentWeight = (progressData?['currentWeight'] as num?)?.toDouble() ??
        (userData['weight'] as num?)?.toDouble() ??
        0.0;

    final weightChange = (progressData?['weightChange'] as num?)?.toDouble() ?? 0.0;
    final previousWeight = currentWeight - weightChange;

    final monthlyWorkouts = (progressData?['totalWorkouts'] as num?)?.toInt() ??
        (weeklyData['completedThisWeek'] as int? ?? 0);

    final workoutChange = (progressData?['workoutChange'] as num?)?.toInt() ?? 0;

    final weeklyActivity = weeklyData['weeklyActivity'] as List<bool>? ??
        const [false, false, false, false, false, false, false];

    final completedWorkoutsThisWeek = weeklyData['completedThisWeek'] as int? ?? 0;
    final totalWorkoutsThisWeek = weeklyData['totalThisWeek'] as int? ?? 7;

    return MemberDashboardModel.fromMap({
      // User profile
      'userName': userData['displayName'] ?? '',
      'photoUrl': userData['photoUrl'],
      'fitnessGoal': userData['fitnessGoal'],
      'activityLevel': userData['activityLevel'],
      'height': userData['height'],
      'weight': currentWeight > 0 ? currentWeight : userData['weight'],

      // Weekly workouts
      'completedWorkouts': completedWorkoutsThisWeek,
      'totalWorkouts': totalWorkoutsThisWeek,
      'weeklyActivity': weeklyActivity,

      // Body metrics & Progress
      'currentWeight': currentWeight,
      'previousWeight': previousWeight,
      'monthlyWorkouts': monthlyWorkouts,
      'workoutChange': workoutChange,
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

  Future<Map<String, dynamic>?> _getProgress(
      String uid,
      ) async {
    final document = await _firestore
        .collection('progress')
        .doc(uid)
        .get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }

  Future<Map<String, dynamic>> _getWeeklyActivityAndCompletions(
      String uid,
      ) async {
    final now = DateTime.now();
    // Monday of the current week (weekday 1 = Monday, 7 = Sunday)
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 7));

    final weeklyActivity = List<bool>.filled(7, false);

    try {
      // 1. Query workout completions
      final completionsSnapshot = await _firestore
          .collection('workout_completions')
          .where('userId', isEqualTo: uid)
          .get();

      for (final doc in completionsSnapshot.docs) {
        final data = doc.data();
        final rawCompleted = data['completedAt'];
        DateTime? completedAt;

        if (rawCompleted is Timestamp) {
          completedAt = rawCompleted.toDate();
        } else if (rawCompleted is String) {
          completedAt = DateTime.tryParse(rawCompleted);
        }

        if (completedAt != null &&
            completedAt.isAfter(monday.subtract(const Duration(seconds: 1))) &&
            completedAt.isBefore(sunday)) {
          final dayIndex = completedAt.weekday - 1;
          if (dayIndex >= 0 && dayIndex < 7) {
            weeklyActivity[dayIndex] = true;
          }
        }
      }

      // 2. Also check progress/weekly_activity subcollection
      final subcollectionSnapshot = await _firestore
          .collection('progress')
          .doc(uid)
          .collection('weekly_activity')
          .get();

      for (final doc in subcollectionSnapshot.docs) {
        final data = doc.data();
        final workouts = (data['workouts'] as num?)?.toInt() ?? 0;
        final order = (data['order'] as num?)?.toInt();
        if (order != null && order >= 0 && order < 7 && workouts > 0) {
          weeklyActivity[order] = true;
        }
      }

      // 3. Check assigned workouts for this week
      final assignedWorkoutsSnapshot = await _firestore
          .collection('workouts')
          .where('userId', isEqualTo: uid)
          .get();

      int assignedCount = 0;
      for (final doc in assignedWorkoutsSnapshot.docs) {
        final data = doc.data();
        final rawAssigned = data['assignedDate'];
        DateTime? assignedDate;
        if (rawAssigned is Timestamp) {
          assignedDate = rawAssigned.toDate();
        } else if (rawAssigned is String) {
          assignedDate = DateTime.tryParse(rawAssigned);
        }

        if (assignedDate != null &&
            assignedDate.isAfter(monday.subtract(const Duration(seconds: 1))) &&
            assignedDate.isBefore(sunday)) {
          assignedCount++;
        }
      }

      return {
        'weeklyActivity': weeklyActivity,
        'completedThisWeek': weeklyActivity.where((b) => b).length,
        'totalThisWeek': assignedCount > 0 ? assignedCount : 7,
      };
    } catch (_) {
      return {
        'weeklyActivity': weeklyActivity,
        'completedThisWeek': 0,
        'totalThisWeek': 7,
      };
    }
  }
}