import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_card.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final workoutAsync = ref.watch(
      todaysWorkoutProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Workout'),
      ),

      body: workoutAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },

        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to load workout.\n$error',
                textAlign: TextAlign.center,
              ),
            ),
          );
        },

        data: (workout) {
          if (workout == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No workout has been assigned for today.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                todaysWorkoutProvider,
              );

              await ref.read(
                todaysWorkoutProvider.future,
              );
            },

            child: ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),

              padding: const EdgeInsets.all(24),

              children: [
                // Workout Header
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

                const SizedBox(height: 20),

                // Workout Summary
                Row(
                  children: [
                    Expanded(
                      child: _WorkoutInfo(
                        icon: Icons.timer_outlined,
                        label: 'Duration',
                        value:
                        '${workout.duration} min',
                      ),
                    ),

                    Expanded(
                      child: _WorkoutInfo(
                        icon:
                        Icons.fitness_center_outlined,
                        label: 'Exercises',
                        value:
                        '${workout.exerciseCount}',
                      ),
                    ),

                    Expanded(
                      child: _WorkoutInfo(
                        icon: Icons.speed_outlined,
                        label: 'Difficulty',
                        value:
                        workout.difficulty ??
                            'Normal',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Text(
                  'Exercises',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge,
                ),

                const SizedBox(height: 16),

                if (workout.exercises.isEmpty)
                  const Padding(
                    padding:
                    EdgeInsets.symmetric(
                      vertical: 32,
                    ),
                    child: Center(
                      child: Text(
                        'No exercises added yet.',
                      ),
                    ),
                  )
                else
                  ...workout.exercises.map(
                        (exercise) {
                      return Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child: ExerciseCard(
                          exercise: exercise,
                          onTap: () {
                            context.push(
                              AppRoutes.workoutDetail,
                              extra: workout.id,
                            );
                          },
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Start workout will be
                      // implemented next.
                    },
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                    ),
                    label: const Text(
                      'Start Workout',
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WorkoutInfo extends StatelessWidget {
  const _WorkoutInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),

        const SizedBox(height: 8),

        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}