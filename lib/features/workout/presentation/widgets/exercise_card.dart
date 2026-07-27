import 'package:flutter/material.dart';

import '../../domain/entities/exercise.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  final Exercise exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(12),

        child: Padding(
          padding:
          const EdgeInsets.all(16),

          child: Row(
            children: [
              Container(
                height: 56,
                width: 56,

                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(12),

                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(
                    alpha: 0.12,
                  ),
                ),

                child: exercise.imageUrl != null
                    ? ClipRRect(
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                  child: Image.network(
                    exercise.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return const Icon(
                        Icons
                            .fitness_center,
                      );
                    },
                  ),
                )
                    : const Icon(
                  Icons
                      .fitness_center,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      exercise.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),

                    if (exercise.muscleGroup !=
                        null) ...[
                      const SizedBox(height: 4),

                      Text(
                        exercise.muscleGroup!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                    ],

                    const SizedBox(height: 8),

                    Text(
                      '${exercise.sets} sets × '
                          '${exercise.reps} reps',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}