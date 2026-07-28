import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/exercise_model.dart';
import '../models/workout_completion_model.dart';
import '../models/workout_model.dart';
import '../../domain/entities/workout_completion.dart';

class WorkoutRemoteDataSource {
  WorkoutRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
  get _workoutsCollection {
    return _firestore.collection(
      'workouts',
    );
  }

  CollectionReference<Map<String, dynamic>>
  get _completionCollection {
    return _firestore.collection(
      'workout_completions',
    );
  }

  Future<List<WorkoutModel>> getUserWorkouts(
      String userId,
      ) async {
    final querySnapshot =
    await _workoutsCollection
        .where(
      'userId',
      isEqualTo: userId,
    )
        .get();

    return Future.wait(
      querySnapshot.docs.map(
        _buildWorkoutWithExercises,
      ),
    );
  }

  Future<WorkoutModel?> getWorkout(
      String workoutId,
      ) async {
    final document =
    await _workoutsCollection
        .doc(workoutId)
        .get();

    if (!document.exists) {
      return null;
    }

    return _buildWorkoutWithExercises(
      document,
    );
  }

  Future<WorkoutModel?> getTodaysWorkout(
      String userId,
      ) async {
    final workouts =
    await getUserWorkouts(
      userId,
    );

    final now = DateTime.now();

    for (final workout in workouts) {
      final assignedDate =
          workout.assignedDate;

      if (assignedDate == null) {
        continue;
      }

      final isToday =
          assignedDate.year == now.year &&
              assignedDate.month == now.month &&
              assignedDate.day == now.day;

      if (isToday) {
        return workout;
      }
    }

    return null;
  }

  Future<WorkoutCompletion>
  completeWorkout(
      WorkoutCompletion completion,
      ) async {
    final completionReference =
    _completionCollection.doc();

    final completionModel =
    WorkoutCompletionModel(
      id: completionReference.id,
      userId: completion.userId,
      workoutId: completion.workoutId,
      completedAt:
      completion.completedAt,
      duration:
      completion.duration,
      completedExercises:
      completion.completedExercises,
      totalExercises:
      completion.totalExercises,
    );

    final progressReference =
    _firestore
        .collection(
      'workout_progress',
    )
        .doc(
      completion.userId,
    );

    await _firestore.runTransaction(
          (transaction) async {
        final progressSnapshot =
        await transaction.get(
          progressReference,
        );

        if (progressSnapshot.exists) {
          final data =
              progressSnapshot.data() ??
                  {};

          final currentCompleted =
              (data['completedWorkouts']
              as num?)
                  ?.toInt() ??
                  0;

          transaction.update(
            progressReference,
            {
              'completedWorkouts':
              currentCompleted + 1,
            },
          );
        } else {
          transaction.set(
            progressReference,
            {
              'completedWorkouts': 1,
              'totalWorkouts':
              1,
            },
          );
        }

        transaction.set(
          completionReference,
          completionModel
              .toFirestore(),
        );
      },
    );

    return completionModel;
  }

  Future<WorkoutModel>
  _buildWorkoutWithExercises(
      DocumentSnapshot<
          Map<String, dynamic>>
      workoutDocument,
      ) async {
    final exercisesSnapshot =
    await _workoutsCollection
        .doc(
      workoutDocument.id,
    )
        .collection(
      'exercises',
    )
        .orderBy(
      'order',
    )
        .get();

    final exercises =
    exercisesSnapshot.docs
        .map(
      ExerciseModel
          .fromFirestore,
    )
        .toList();

    return WorkoutModel.fromFirestore(
      workoutDocument,
      exercises: exercises,
    );
  }
}