import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/workout_provider.dart';

class WorkoutDetailScreen
    extends ConsumerWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.workoutId,
  });

  final String workoutId;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final workoutAsync = ref.watch(
      workoutByIdProvider(workoutId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
      ),

      body: workoutAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },

        error: (error, stackTrace) {
          return Center(
            child: Text(
              'Unable to load workout.\n$error',
              textAlign: TextAlign.center,
            ),
          );
        },

        data: (workout) {
          if (workout == null) {
            return const Center(
              child: Text(
                'Workout not found.',
              ),
            );
          }

          return ListView(
            padding:
            const EdgeInsets.all(24),

            children: [
              Text(
                workout.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium,
              ),

              const SizedBox(height: 8),

              Text(
                workout.description,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge,
              ),

              const SizedBox(height: 24),

              Text(
                'Exercises',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
              ),

              const SizedBox(height: 16),

              ...workout.exercises.map(
                    (exercise) {
                  return Card(
                    margin:
                    const EdgeInsets.only(
                      bottom: 12,
                    ),

                    child: Padding(
                      padding:
                      const EdgeInsets.all(
                        16,
                      ),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [
                          Text(
                            exercise.name,
                            style: Theme.of(
                              context,
                            )
                                .textTheme
                                .titleMedium,
                          ),

                          if (exercise
                              .muscleGroup !=
                              null) ...[
                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              exercise
                                  .muscleGroup!,
                            ),
                          ],

                          const SizedBox(
                            height: 12,
                          ),

                          Text(
                            '${exercise.sets} sets × '
                                '${exercise.reps} reps',
                          ),

                          if (exercise
                              .weight !=
                              null) ...[
                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              'Weight: '
                                  '${exercise.weight} kg',
                            ),
                          ],

                          if (exercise
                              .restSeconds !=
                              null) ...[
                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              'Rest: '
                                  '${exercise.restSeconds} sec',
                            ),
                          ],

                          if (exercise
                              .description !=
                              null) ...[
                            const SizedBox(
                              height: 12,
                            ),

                            Text(
                              exercise
                                  .description!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}