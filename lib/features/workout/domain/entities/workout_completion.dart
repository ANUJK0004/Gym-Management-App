class WorkoutCompletion {
  const WorkoutCompletion({
    required this.id,
    required this.userId,
    required this.workoutId,
    required this.completedAt,
    required this.duration,
    required this.completedExercises,
    required this.totalExercises,
  });

  final String id;
  final String userId;
  final String workoutId;

  final DateTime completedAt;

  /// Total session duration in seconds.
  final int duration;

  final int completedExercises;
  final int totalExercises;

  double get completionPercentage {
    if (totalExercises == 0) {
      return 0;
    }

    return completedExercises / totalExercises;
  }

  bool get isFullyCompleted {
    return completedExercises >= totalExercises &&
        totalExercises > 0;
  }
}