import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_completion.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_remote_datasource.dart';

class WorkoutRepositoryImpl
    implements WorkoutRepository {
  WorkoutRepositoryImpl(
      this._dataSource,
      );

  final WorkoutRemoteDataSource _dataSource;

  @override
  Future<List<Workout>> getUserWorkouts(
      String userId,
      ) {
    return _dataSource.getUserWorkouts(
      userId,
    );
  }

  @override
  Future<Workout?> getWorkout(
      String workoutId,
      ) {
    return _dataSource.getWorkout(
      workoutId,
    );
  }

  @override
  Future<Workout?> getTodaysWorkout(
      String userId,
      ) {
    return _dataSource.getTodaysWorkout(
      userId,
    );
  }

  @override
  Future<WorkoutCompletion> completeWorkout(
      WorkoutCompletion completion,
      ) {
    return _dataSource.completeWorkout(
      completion,
    );
  }
}