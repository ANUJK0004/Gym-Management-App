import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/workout.dart';

class WorkoutSessionState {
  const WorkoutSessionState({
    required this.workout,
    this.currentExerciseIndex = 0,
    this.completedExerciseIndexes = const {},
    this.isPaused = false,
    this.isFinished = false,
    this.elapsedSeconds = 0,
  });

  final Workout workout;

  final int currentExerciseIndex;

  final Set<int> completedExerciseIndexes;

  final bool isPaused;

  final bool isFinished;

  final int elapsedSeconds;

  int get totalExercises =>
      workout.exercises.length;

  int get completedExercises =>
      completedExerciseIndexes.length;

  double get progress {
    if (totalExercises == 0) {
      return 0;
    }

    return completedExercises /
        totalExercises;
  }

  bool get hasExercises =>
      workout.exercises.isNotEmpty;

  bool get isLastExercise =>
      currentExerciseIndex ==
          totalExercises - 1;

  WorkoutSessionState copyWith({
    int? currentExerciseIndex,
    Set<int>?
    completedExerciseIndexes,
    bool? isPaused,
    bool? isFinished,
    int? elapsedSeconds,
  }) {
    return WorkoutSessionState(
      workout: workout,
      currentExerciseIndex:
      currentExerciseIndex ??
          this.currentExerciseIndex,
      completedExerciseIndexes:
      completedExerciseIndexes ??
          this.completedExerciseIndexes,
      isPaused:
      isPaused ?? this.isPaused,
      isFinished:
      isFinished ?? this.isFinished,
      elapsedSeconds:
      elapsedSeconds ??
          this.elapsedSeconds,
    );
  }
}

class WorkoutSessionNotifier
    extends StateNotifier<
        WorkoutSessionState> {
  WorkoutSessionNotifier(
      Workout workout,
      ) : super(
    WorkoutSessionState(
      workout: workout,
    ),
  );

  void updateElapsedTime() {
    if (state.isPaused ||
        state.isFinished) {
      return;
    }

    state = state.copyWith(
      elapsedSeconds:
      state.elapsedSeconds + 1,
    );
  }

  void togglePause() {
    if (state.isFinished) {
      return;
    }

    state = state.copyWith(
      isPaused: !state.isPaused,
    );
  }

  void completeCurrentExercise() {
    if (!state.hasExercises ||
        state.isFinished) {
      return;
    }

    final completed =
    Set<int>.from(
      state.completedExerciseIndexes,
    );

    completed.add(
      state.currentExerciseIndex,
    );

    if (state.isLastExercise) {
      state = state.copyWith(
        completedExerciseIndexes:
        completed,
        isFinished: true,
      );

      return;
    }

    state = state.copyWith(
      completedExerciseIndexes:
      completed,
      currentExerciseIndex:
      state.currentExerciseIndex + 1,
    );
  }

  void goToPreviousExercise() {
    if (state.currentExerciseIndex ==
        0) {
      return;
    }

    state = state.copyWith(
      currentExerciseIndex:
      state.currentExerciseIndex - 1,
    );
  }

  void goToExercise(
      int index,
      ) {
    if (index < 0 ||
        index >= state.totalExercises) {
      return;
    }

    state = state.copyWith(
      currentExerciseIndex: index,
    );
  }
}

final workoutSessionProvider =
StateNotifierProvider.family<
    WorkoutSessionNotifier,
    WorkoutSessionState,
    Workout>(
      (ref, workout) {
    return WorkoutSessionNotifier(
      workout,
    );
  },
);