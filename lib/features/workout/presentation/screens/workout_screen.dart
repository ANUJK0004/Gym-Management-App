import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../design_system/appbar/app_back_button.dart';
import '../providers/workout_provider.dart';
import '../widgets/add_exercise_sheet.dart';
import '../widgets/create_custom_workout_sheet.dart';
import '../widgets/exercise_card.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({
    super.key,
  });

  void _onAddPressed(BuildContext context, WidgetRef ref, dynamic currentWorkout) {
    if (currentWorkout == null) {
      CreateCustomWorkoutSheet.show(context);
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF191919),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF424242),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF222222),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: AppColors.primary),
                  ),
                  title: const Text(
                    'Add Exercise to Today\'s Workout',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Add a custom exercise to your current plan'),
                  onTap: () {
                    Navigator.pop(ctx);
                    AddExerciseBottomSheet.show(
                      context,
                      onExerciseAdded: (exercise) async {
                        try {
                          await ref
                              .read(workoutCreationNotifierProvider.notifier)
                              .addExercise(
                                workoutId: currentWorkout.id,
                                exercise: exercise,
                              );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added "${exercise.name}" to today\'s workout'),
                                backgroundColor: AppColors.surface,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to add exercise: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
                const Divider(color: Color(0xFF282828)),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF222222),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.playlist_add_rounded, color: AppColors.primary),
                  ),
                  title: const Text(
                    'Create New Custom Workout',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text('Design a new custom workout routine'),
                  onTap: () {
                    Navigator.pop(ctx);
                    CreateCustomWorkoutSheet.show(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final workoutAsync = ref.watch(
      todaysWorkoutProvider,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: 56,
        leading: const Center(
          child: AppBackButton(
            fallbackRoute: AppRoutes.home,
          ),
        ),
        title: const Text(
          'Workout',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () {
                final currentWorkout = workoutAsync.value;
                _onAddPressed(context, ref, currentWorkout);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF182414),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: workoutAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Unable to load workout.\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(todaysWorkoutProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (workout) {
          if (workout == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1F1F1F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        size: 38,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Workout Scheduled Today',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Build your own custom workout routine and start training right now.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          CreateCustomWorkoutSheet.show(context);
                        },
                        icon: const Icon(Icons.add, color: AppColors.textInverse),
                        label: const Text(
                          'Create Custom Workout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textInverse,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(todaysWorkoutProvider);
              await ref.read(todaysWorkoutProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                // Workout Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF191919),
                    borderRadius: AppRadius.radiusLG,
                    border: Border.all(
                      color: const Color(0xFF282828),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  workout.day != null && workout.day != 'Everyday'
                                      ? "TODAY • ${workout.day!.toUpperCase()}"
                                      : "TODAY'S WORKOUT",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              if (workout.day != null && workout.day == 'Everyday') ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF252525),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Everyday',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFCCCCCC),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (workout.difficulty != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF252525),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                workout.difficulty!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFCCCCCC),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        workout.name,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (workout.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          workout.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFF282828)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _WorkoutInfo(
                              icon: Icons.timer_outlined,
                              label: 'Duration',
                              value: '${workout.duration} min',
                            ),
                          ),
                          Container(
                            height: 30,
                            width: 1,
                            color: const Color(0xFF282828),
                          ),
                          Expanded(
                            child: _WorkoutInfo(
                              icon: Icons.fitness_center_outlined,
                              label: 'Exercises',
                              value: '${workout.exerciseCount}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Exercises Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Exercises (${workout.exerciseCount})',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        AddExerciseBottomSheet.show(
                          context,
                          onExerciseAdded: (exercise) async {
                            try {
                              await ref
                                  .read(workoutCreationNotifierProvider.notifier)
                                  .addExercise(
                                    workoutId: workout.id,
                                    exercise: exercise,
                                  );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error adding exercise: $e'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.add,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Add Exercise',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                if (workout.exercises.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: const Center(
                      child: Text(
                        'No exercises added yet. Tap "Add Exercise" above.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  ...workout.exercises.map(
                    (exercise) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
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

                // Start Workout CTA
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push(
                        AppRoutes.workoutSession,
                        extra: workout,
                      );
                    },
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      size: 24,
                      color: AppColors.textInverse,
                    ),
                    label: const Text(
                      'Start Workout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textInverse,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
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
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}