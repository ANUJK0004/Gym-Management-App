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
}