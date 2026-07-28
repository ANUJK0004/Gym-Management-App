import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';

import '../../domain/entities/progress.dart';

class WeeklyActivityCard
    extends StatelessWidget {
  const WeeklyActivityCard({
    super.key,
    required this.progress,
  });

  final Progress progress;

  @override
  Widget build(BuildContext context) {
    final weeklyActivity =
        progress.normalizedWeeklyActivity;

    final maxWorkouts =
    weeklyActivity.fold<int>(
      1,
          (max, activity) =>
      activity.workouts > max
          ? activity.workouts
          : max,
    );

    return Container(
      padding:
      const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        AppRadius.radiusLG,
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

            children: [
              Text(
                'Weekly Activity',
                style: AppTextStyles
                    .titleMedium
                    .copyWith(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              Text(
                'This week',
                style: AppTextStyles
                    .bodySmall
                    .copyWith(
                  color:
                  AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 120,

            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.end,

              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,

              children: List.generate(
                7,
                    (index) {
                  final activity =
                  weeklyActivity[index];

                  final isToday =
                      index ==
                          progress.todayIndex;

                  final heightFactor =
                  activity.workouts == 0
                      ? 0.05
                      : activity.workouts /
                      maxWorkouts;

                  return Column(
                    mainAxisAlignment:
                    MainAxisAlignment.end,

                    children: [
                      Expanded(
                        child: Align(
                          alignment:
                          Alignment
                              .bottomCenter,

                          child:
                          FractionallySizedBox(
                            heightFactor:
                            heightFactor
                                .clamp(
                              0.05,
                              1.0,
                            ),

                            child:
                            AnimatedContainer(
                              duration:
                              const Duration(
                                milliseconds:
                                300,
                              ),

                              width: 28,

                              decoration:
                              BoxDecoration(
                                color: isToday
                                    ? AppColors
                                    .primary
                                    : AppColors
                                    .border,

                                borderRadius:
                                const BorderRadius
                                    .vertical(
                                  top:
                                  Radius.circular(
                                    6,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        activity.day,
                        style:
                        AppTextStyles
                            .labelMedium
                            .copyWith(
                          color: AppColors
                              .textSecondary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}