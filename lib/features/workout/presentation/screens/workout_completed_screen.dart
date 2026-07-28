import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../domain/entities/workout.dart';

class WorkoutCompletedScreen
    extends StatelessWidget {
  const WorkoutCompletedScreen({
    super.key,
    required this.workout,
    required this.duration,
    required this.completedExercises,
  });

  final Workout workout;

  final int duration;

  final int completedExercises;

  String get formattedDuration {
    final minutes =
        duration ~/ 60;

    final seconds =
        duration % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
            const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration:
                  const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(
                  height: 28,
                ),

                const Text(
                  'Workout Complete!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  'Great job completing ${workout.name}.',
                  textAlign:
                  TextAlign.center,
                ),

                const SizedBox(
                  height: 36,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                      _SummaryCard(
                        value:
                        '$completedExercises/${workout.exerciseCount}',
                        label:
                        'Exercises',
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child:
                      _SummaryCard(
                        value:
                        formattedDuration,
                        label:
                        'Duration',
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 40,
                ),

                SizedBox(
                  width:
                  double.infinity,
                  child:
                  FilledButton(
                    onPressed: () {
                      context.go(
                        AppRoutes.home,
                      );
                    },
                    child:
                    const Text(
                      'Back to Dashboard',
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                SizedBox(
                  width:
                  double.infinity,
                  child:
                  OutlinedButton(
                    onPressed: () {
                      context.go(
                        AppRoutes.workout,
                      );
                    },
                    child:
                    const Text(
                      'View Workouts',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard
    extends StatelessWidget {
  const _SummaryCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(20),
      decoration:
      BoxDecoration(
        color:
        Theme.of(context)
            .colorScheme
            .surface,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style:
            const TextStyle(
              fontSize: 22,
              fontWeight:
              FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(label),
        ],
      ),
    );
  }
}