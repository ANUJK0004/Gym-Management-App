import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

import '../../data/datasources/workout_remote_datasource.dart';
import '../../data/repositories/workout_repository_impl.dart';

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