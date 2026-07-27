import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/exercise_model.dart';
import '../models/workout_model.dart';

class WorkoutRemoteDataSource {
  WorkoutRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
  get _workoutsCollection {
    return _firestore.collection('workouts');
  }

  Future<List<WorkoutModel>> getUserWorkouts(
      String userId,
      ) async {
    final querySnapshot = await _workoutsCollection
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
    final document = await _workoutsCollection
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
    final now = DateTime.now();

    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final startOfTomorrow = DateTime(
      now.year,
      now.month,
      now.day + 1,
    );

    // First fetch the user's workouts.
    // This avoids requiring a composite Firestore index
    // on userId + assignedDate.
    final querySnapshot = await _workoutsCollection
        .where(
      'userId',
      isEqualTo: userId,
    )
        .get();

    // Filter today's workout locally.
    final todaysDocuments = querySnapshot.docs.where((document) {
      final data = document.data();

      final assignedDate = data['assignedDate'];

      if (assignedDate is! Timestamp) {
        return false;
      }

      final date = assignedDate.toDate();

      return !date.isBefore(startOfDay) &&
          date.isBefore(startOfTomorrow);
    }).toList();

    if (todaysDocuments.isEmpty) {
      return null;
    }

    // If multiple workouts exist for today,
    // use the earliest assigned workout.
    todaysDocuments.sort((a, b) {
      final aDate =
      (a.data()['assignedDate'] as Timestamp).toDate();

      final bDate =
      (b.data()['assignedDate'] as Timestamp).toDate();

      return aDate.compareTo(bDate);
    });

    return _buildWorkoutWithExercises(
      todaysDocuments.first,
    );
  }


  Future<WorkoutModel> _buildWorkoutWithExercises(
      DocumentSnapshot<Map<String, dynamic>> workoutDocument,
      ) async {
    final exercisesSnapshot = await _workoutsCollection
        .doc(workoutDocument.id)
        .collection('exercises')
        .orderBy('order')
        .get();

    final exercises = exercisesSnapshot.docs
        .map(
      ExerciseModel.fromFirestore,
    )
        .toList();

    return WorkoutModel.fromFirestore(
      workoutDocument,
      exercises: exercises,
    );
  }
}