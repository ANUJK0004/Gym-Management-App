import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweatsync/features/progress/presentation/providers/progress_provider.dart';

import '../../data/services/workout_completion_service.dart';
import '../../../workout/domain/entities/workout.dart';

final workoutCompletionServiceProvider =
Provider<WorkoutCompletionService>((ref) {
  return WorkoutCompletionService(
    FirebaseFirestore.instance,
  );
});

final workoutCompletionProvider =
FutureProvider.family<
    bool,
    WorkoutCompletionParams>(
      (ref, params) async {
    final service =
    ref.read(
      workoutCompletionServiceProvider,
    );

    final result =
    await service.completeWorkout(
      userId: params.userId,
      workout: params.workout,
    );

    ref.invalidate(
      // Progress refresh
      // This provider can be invalidated
      // after completion.
      progressProvider,
    );

    return result;
  },
);

class WorkoutCompletionParams {
  const WorkoutCompletionParams({
    required this.userId,
    required this.workout,
  });

  final String userId;

  final Workout workout;
}