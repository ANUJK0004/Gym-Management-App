import '../entities/exercise.dart';
import '../entities/workout.dart';
import '../entities/workout_completion.dart';

abstract class WorkoutRepository {
  Future<List<Workout>> getUserWorkouts(
      String userId,
      );

  Future<Workout?> getWorkout(
      String workoutId,
      );

  Future<Workout?> getTodaysWorkout(
      String userId,
      );

  Future<WorkoutCompletion> completeWorkout(
      WorkoutCompletion completion,
      );

  Future<Workout> createWorkout(
      Workout workout,
      );

  Future<void> addExerciseToWorkout({
    required String workoutId,
    required Exercise exercise,
  });

  Future<void> deleteWorkout(
      String workoutId,
      );
}