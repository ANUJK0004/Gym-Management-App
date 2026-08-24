import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

import '../../data/datasources/workout_remote_datasource.dart';
import '../../data/repositories/workout_repository_impl.dart';

import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_completion.dart';
import '../../domain/repositories/workout_repository.dart';

final workoutDataSourceProvider =
Provider<WorkoutRemoteDataSource>((ref) {
  return WorkoutRemoteDataSource(
    FirebaseFirestore.instance,
  );
});

final workoutRepositoryProvider =
Provider<WorkoutRepository>((ref) {
  return WorkoutRepositoryImpl(
    ref.watch(
      workoutDataSourceProvider,
    ),
  );
});

final workoutProvider =
FutureProvider<List<Workout>>((ref) async {
  final authState =
  ref.watch(authStateProvider);

  final authUser =
      authState.value;

  if (authUser == null) {
    return [];
  }

  final repository =
  ref.watch(
    workoutRepositoryProvider,
  );

  return repository.getUserWorkouts(
    authUser.id,
  );
});

final todaysWorkoutProvider =
FutureProvider<Workout?>((ref) async {
  final authState =
  ref.watch(authStateProvider);

  final authUser =
      authState.value;

  if (authUser == null) {
    return null;
  }

  final repository =
  ref.watch(
    workoutRepositoryProvider,
  );

  return repository.getTodaysWorkout(
    authUser.id,
  );
});

final workoutByIdProvider =
FutureProvider.family<
    Workout?,
    String>(
      (ref, workoutId) async {
    final repository =
    ref.watch(
      workoutRepositoryProvider,
    );

    return repository.getWorkout(
      workoutId,
    );
  },
);

final workoutCompletionProvider =
FutureProvider.family<
    WorkoutCompletion,
    WorkoutCompletion>(
      (ref, completion) async {
    final repository =
    ref.watch(
      workoutRepositoryProvider,
    );

    return repository.completeWorkout(
      completion,
    );
  },
);

class WorkoutCreationNotifier
    extends StateNotifier<AsyncValue<Workout?>> {
  WorkoutCreationNotifier(
    this._repository,
    this._ref,
  ) : super(const AsyncValue.data(null));

  final WorkoutRepository _repository;
  final Ref _ref;

  Future<Workout> createCustomWorkout({
    required String name,
    required String description,
    required List<Exercise> exercises,
    int duration = 45,
    String? difficulty,
    DateTime? assignedDate,
  }) async {
    final authState = _ref.read(authStateProvider);
    final authUser = authState.value;
    if (authUser == null) {
      throw Exception('User is not authenticated');
    }

    state = const AsyncValue.loading();
    try {
      final workout = Workout(
        id: '',
        userId: authUser.id,
        name: name,
        description: description,
        difficulty: difficulty ?? 'Normal',
        duration: duration,
        assignedDate: assignedDate ?? DateTime.now(),
        exercises: exercises,
      );

      final created = await _repository.createWorkout(workout);
      _ref.invalidate(workoutProvider);
      _ref.invalidate(todaysWorkoutProvider);
      state = AsyncValue.data(created);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> addExercise({
    required String workoutId,
    required Exercise exercise,
  }) async {
    await _repository.addExerciseToWorkout(
      workoutId: workoutId,
      exercise: exercise,
    );
    _ref.invalidate(workoutProvider);
    _ref.invalidate(todaysWorkoutProvider);
    _ref.invalidate(workoutByIdProvider(workoutId));
  }
}

final workoutCreationNotifierProvider =
    StateNotifierProvider<WorkoutCreationNotifier, AsyncValue<Workout?>>((ref) {
  return WorkoutCreationNotifier(
    ref.watch(workoutRepositoryProvider),
    ref,
  );
});