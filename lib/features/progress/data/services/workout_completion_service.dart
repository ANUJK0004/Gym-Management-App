import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../workout/domain/entities/workout.dart';

class WorkoutCompletionService {
  WorkoutCompletionService(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  Future<bool> completeWorkout({
    required String userId,
    required Workout workout,
  }) async {
    final today = DateTime.now();

    final dateKey =
        '${today.year}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    final completionId =
        '${workout.id}_$dateKey';

    final completionReference =
    _firestore
        .collection('workout_completions')
        .doc(userId)
        .collection('completed')
        .doc(completionId);

    final progressReference =
    _firestore
        .collection('progress')
        .doc(userId);

    return _firestore.runTransaction(
          (transaction) async {
        final completionSnapshot =
        await transaction.get(
          completionReference,
        );

        // Already completed today.
        if (completionSnapshot.exists) {
          return false;
        }

        final progressSnapshot =
        await transaction.get(
          progressReference,
        );

        final progressData =
            progressSnapshot.data() ?? {};

        final currentTotal =
            (progressData['totalWorkouts']
            as num?)
                ?.toInt() ??
                0;

        final currentWorkoutChange =
            (progressData['workoutChange']
            as num?)
                ?.toInt() ??
                0;

        transaction.set(
          completionReference,
          {
            'workoutId': workout.id,
            'workoutName':
            workout.name,
            'userId': userId,
            'completedAt':
            FieldValue.serverTimestamp(),
          },
        );

        transaction.set(
          progressReference,
          {
            'userId': userId,
            'totalWorkouts':
            currentTotal + 1,
            'workoutChange':
            currentWorkoutChange + 1,
            'updatedAt':
            FieldValue.serverTimestamp(),
          },
          SetOptions(
            merge: true,
          ),
        );

        final activityReference =
        progressReference
            .collection('weekly_activity')
            .doc('day_${_dayOrder(today)}');

        final activitySnapshot =
        await transaction.get(
          activityReference,
        );

        final activityData =
            activitySnapshot.data() ?? {};

        final currentActivity =
            (activityData['workouts']
            as num?)
                ?.toInt() ??
                0;

        transaction.set(
          activityReference,
          {
            'day':
            _shortDayName(today),
            'dayFull':
            _dayName(today),
            'workouts':
            currentActivity + 1,
            'order':
            _dayOrder(today),
          },
          SetOptions(
            merge: true,
          ),
        );

        await _updatePersonalRecords(
          transaction: transaction,
          userId: userId,
          workout: workout,
        );

        return true;
      },
    );
  }

  Future<void> _updatePersonalRecords({
    required Transaction transaction,
    required String userId,
    required Workout workout,
  }) async {
    for (final exercise
    in workout.exercises) {
      final weight =
          exercise.weight;

      if (weight == null ||
          weight <= 0) {
        continue;
      }

      final recordReference =
      _firestore
          .collection('progress')
          .doc(userId)
          .collection('personal_records')
          .doc(exercise.id);

      final recordSnapshot =
      await transaction.get(
        recordReference,
      );

      if (!recordSnapshot.exists) {
        transaction.set(
          recordReference,
          {
            'exerciseName':
            exercise.name,
            'weight': weight,
            'date':
            FieldValue.serverTimestamp(),
          },
        );

        continue;
      }

      final data =
          recordSnapshot.data() ?? {};

      final existingWeight =
          (data['weight'] as num?)
              ?.toDouble() ??
              0;

      if (weight > existingWeight) {
        transaction.update(
          recordReference,
          {
            'exerciseName':
            exercise.name,
            'weight': weight,
            'date':
            FieldValue.serverTimestamp(),
          },
        );
      }
    }
  }

  String _shortDayName(
      DateTime date,
      ) {
    const days = [
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];

    return days[
    date.weekday - 1
    ];
  }

  String _dayName(
      DateTime date,
      ) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[
    date.weekday - 1
    ];
  }

  int _dayOrder(
      DateTime date,
      ) {
    return date.weekday - 1;
  }
}