import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/exercise_model.dart';
import '../models/workout_completion_model.dart';
import '../models/workout_model.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout.dart';
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
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final todayDayName = dayNames[now.weekday - 1].toLowerCase();

    // 1. Look for specific day match (e.g., 'Monday')
    for (final workout in workouts) {
      final day = workout.day?.toLowerCase();
      if (day != null && day == todayDayName) {
        return workout;
      }
    }

    // 2. Look for date match (assignedDate == today)
    for (final workout in workouts) {
      final assignedDate = workout.assignedDate;
      if (assignedDate != null) {
        final isToday = assignedDate.year == now.year &&
            assignedDate.month == now.month &&
            assignedDate.day == now.day;
        if (isToday) {
          return workout;
        }
      }
    }

    // 3. Look for 'Everyday' workout
    for (final workout in workouts) {
      final day = workout.day?.toLowerCase();
      if (day == 'everyday') {
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

  Future<WorkoutModel> createWorkout(
      Workout workout,
      ) async {
    final workoutRef = workout.id.isNotEmpty
        ? _workoutsCollection.doc(workout.id)
        : _workoutsCollection.doc();

    final workoutModel = WorkoutModel(
      id: workoutRef.id,
      userId: workout.userId,
      name: workout.name,
      description: workout.description,
      imageUrl: workout.imageUrl,
      difficulty: workout.difficulty,
      duration: workout.duration,
      assignedDate: workout.assignedDate,
      day: workout.day ?? 'Everyday',
      exercises: workout.exercises,
    );

    final batch = _firestore.batch();
    batch.set(workoutRef, workoutModel.toFirestore());

    for (var i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      final exerciseRef = exercise.id.isNotEmpty
          ? workoutRef.collection('exercises').doc(exercise.id)
          : workoutRef.collection('exercises').doc();

      final exerciseModel = ExerciseModel(
        id: exerciseRef.id,
        name: exercise.name,
        description: exercise.description,
        imageUrl: exercise.imageUrl,
        muscleGroup: exercise.muscleGroup,
        sets: exercise.sets,
        reps: exercise.reps,
        weight: exercise.weight,
        restSeconds: exercise.restSeconds,
        order: exercise.order > 0 ? exercise.order : i,
      );

      batch.set(exerciseRef, exerciseModel.toFirestore());
    }

    await batch.commit();
    return workoutModel;
  }

  Future<void> addExerciseToWorkout({
    required String workoutId,
    required Exercise exercise,
  }) async {
    final exercisesCollection =
        _workoutsCollection.doc(workoutId).collection('exercises');

    final exerciseRef = exercise.id.isNotEmpty
        ? exercisesCollection.doc(exercise.id)
        : exercisesCollection.doc();

    final exerciseModel = ExerciseModel(
      id: exerciseRef.id,
      name: exercise.name,
      description: exercise.description,
      imageUrl: exercise.imageUrl,
      muscleGroup: exercise.muscleGroup,
      sets: exercise.sets,
      reps: exercise.reps,
      weight: exercise.weight,
      restSeconds: exercise.restSeconds,
      order: exercise.order,
    );

    await exerciseRef.set(exerciseModel.toFirestore());
  }

  Future<void> deleteWorkout(String workoutId) async {
    final exercisesSnapshot = await _workoutsCollection
        .doc(workoutId)
        .collection('exercises')
        .get();

    final batch = _firestore.batch();
    for (final doc in exercisesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_workoutsCollection.doc(workoutId));
    await batch.commit();
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