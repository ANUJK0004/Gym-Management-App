import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../domain/entities/exercise.dart';

class SessionExerciseTile extends StatelessWidget {
  const SessionExerciseTile({
    super.key,
    required this.exercise,
    required this.index,
    required this.isActive,
    required this.isCompleted,
    required this.onTap,
  });

  final Exercise exercise;
  final int index;

  final bool isActive;
  final bool isCompleted;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
    isActive
        ? AppColors.primary.withValues(
      alpha: 0.08,
    )
        : AppColors.surface;

    final borderColor =
    isActive
        ? AppColors.primary
        : AppColors.border;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
        const EdgeInsets.only(
          bottom: 12,
        ),
        padding:
        const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius:
          AppRadius.radiusLG,
          border: Border.all(
            color: borderColor,
            width:
            isActive ? 1.2 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.primary
                    : isActive
                    ? AppColors.primary
                    .withValues(
                  alpha: 0.2,
                )
                    : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                  Icons.check,
                  color:
                  AppColors.textInverse,
                )
                    : Text(
                  '${index + 1}',
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style:
                    const TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _exerciseDetails,
                    style:
                    const TextStyle(
                      fontSize: 12,
                      color:
                      AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            if (isActive)
              const Text(
                'Active',
                style:
                TextStyle(
                  color:
                  AppColors.primary,
                  fontWeight:
                  FontWeight.w700,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String get _exerciseDetails {
    final parts = <String>[];

    if (exercise.sets > 0) {
      parts.add(
        '${exercise.sets} sets',
      );
    }

    if (exercise.reps > 0) {
      parts.add(
        '${exercise.reps} reps',
      );
    }

    if (exercise.weight != null) {
      parts.add(
        '${exercise.weight} kg',
      );
    }

    return parts.join(' • ');
  }
}