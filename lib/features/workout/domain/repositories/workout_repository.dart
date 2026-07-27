import '../entities/workout.dart';

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
}