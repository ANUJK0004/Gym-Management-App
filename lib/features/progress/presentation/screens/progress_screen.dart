import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

import '../../domain/entities/progress.dart';

import '../providers/progress_provider.dart';
import '../widgets/progress_metric_card.dart';
import '../widgets/weekly_activity_card.dart';
import '../widgets/personal_records_section.dart';

class ProgressScreen
    extends ConsumerWidget {
  const ProgressScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final progressAsync =
    ref.watch(progressProvider);

    return Scaffold(
      backgroundColor:
      AppColors.background,

      body: SafeArea(
        child: progressAsync.when(
          loading: () {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          },

          error: (
              error,
              stackTrace,
              ) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  24,
                ),

                child: Text(
                  'Something went wrong.\n$error',

                  textAlign:
                  TextAlign.center,

                  style:
                  AppTextStyles
                      .bodyMedium,
                ),
              ),
            );
          },

          data: (progress) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(
                  progressProvider,
                );

                await ref.read(
                  progressProvider.future,
                );
              },

              child:
              CustomScrollView(
                physics:
                const AlwaysScrollableScrollPhysics(),

                slivers: [
                  SliverPadding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      22,
                      24,
                      22,
                      32,
                    ),

                    sliver:
                    SliverList(
                      delegate:
                      SliverChildListDelegate(
                        [
                          const _ProgressHeader(),

                          const SizedBox(
                            height: 24,
                          ),

                          _MetricsGrid(
                            progress:
                            progress,
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          WeeklyActivityCard(
                            progress:
                            progress,
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          PersonalRecordsSection(
                            records:
                            progress
                                .personalRecords,
                          ),

                          const SizedBox(
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProgressHeader
    extends StatelessWidget {
  const _ProgressHeader();

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Text(
          'Progress',
          style: AppTextStyles
              .headlineLarge
              .copyWith(
            fontWeight:
            FontWeight.w700,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Track your fitness journey',
          style: AppTextStyles
              .bodySmall
              .copyWith(
            color:
            AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MetricsGrid
    extends StatelessWidget {
  const   _MetricsGrid({
    required this.progress,
  });

  final Progress progress;

  @override
  Widget build(
      BuildContext context,
      ) {
    return GridView.count(
      crossAxisCount: 2,

      crossAxisSpacing: 10,

      mainAxisSpacing: 10,

      shrinkWrap: true,

      physics:
      const NeverScrollableScrollPhysics(),

      childAspectRatio: 1.25,

      children: [
        ProgressMetricCard(
          title:
          'Current Weight',

          value:
          progress.currentWeight
              .toStringAsFixed(1),

          unit: 'kg',

          change:
          progress.weightChange,
        ),

        ProgressMetricCard(
          title: 'Body Fat',

          value:
          progress.bodyFat
              .toStringAsFixed(1),

          unit: '%',

          change:
          progress.bodyFatChange,
        ),

        ProgressMetricCard(
          title: 'Muscle Mass',

          value:
          progress.muscleMass
              .toStringAsFixed(1),

          unit: 'kg',

          change:
          progress.muscleMassChange,
        ),

        ProgressMetricCard(
          title: 'Workouts',

          value:
          progress.totalWorkouts
              .toString(),

          unit: 'this month',

          change: progress
              .workoutChange
              .toDouble(),
        ),
      ],
    );
  }
}