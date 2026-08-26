import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../design_system/appbar/app_back_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/member/presentation/providers/member_dashboard_provider.dart';
import '../../../progress/presentation/providers/progress_provider.dart';
import '../../../progress/presentation/providers/workout_completion_provider.dart'
    hide workoutCompletionProvider;
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_completion.dart';
import '../providers/workout_provider.dart';
import '../providers/workout_session_provider.dart';
import '../widgets/add_exercise_sheet.dart';
import '../widgets/session_exercise_tile.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  const WorkoutSessionScreen({
    super.key,
    required this.workout,
  });

  final Workout workout;

  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState
    extends ConsumerState<WorkoutSessionScreen> {
  Timer? _timer;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        ref
            .read(
              workoutSessionProvider(
                widget.workout,
              ).notifier,
            )
            .updateElapsedTime();
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openAddExerciseSheet(WorkoutSessionNotifier notifier) {
    AddExerciseBottomSheet.show(
      context,
      onExerciseAdded: (newExercise) {
        notifier.addExercise(newExercise);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added "${newExercise.name}" to workout'),
            backgroundColor: AppColors.surface,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(
      workoutSessionProvider(
        widget.workout,
      ),
    );

    final notifier = ref.read(
      workoutSessionProvider(
        widget.workout,
      ).notifier,
    );

    final exercises = session.workout.exercises;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Back Button
                AppBackButton(
                  onPressed: () => _showExitConfirmation(context),
                ),

                const SizedBox(width: 8),

                // Centered Title & Subtitle
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        session.workout.name.isNotEmpty
                            ? session.workout.name
                            : 'Workout Session',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (session.workout.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          session.workout.description,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8E8E93),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Pause Button
                InkWell(
                  onTap: notifier.togglePause,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 42,
                    height: 42,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2C2C2C),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      session.isPaused ? Icons.play_arrow : Icons.pause,
                      color: session.isPaused
                          ? AppColors.primary
                          : const Color(0xFFCCCCCC),
                      size: 20,
                    ),
                  ),
                ),

                // Add Exercise Button (Matching screenshot circular button with green +)
                InkWell(
                  onTap: () => _openAddExerciseSheet(notifier),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 42,
                    height: 42,
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
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Stats & Progress Container
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  // Elapsed Time & Exercises Row (Matching Screenshot)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF191919),
                      borderRadius: AppRadius.radiusLG,
                      border: Border.all(
                        color: const Color(0xFF282828),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Elapsed Time (Large Lime Green text)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'ELAPSED TIME',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: Color(0xFF7A7A7A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatDuration(session.elapsedSeconds),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Vertical Divider
                        Container(
                          height: 44,
                          width: 1,
                          color: const Color(0xFF2D2D2D),
                        ),

                        // Exercises Count
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'EXERCISES',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: Color(0xFF7A7A7A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${session.completedExercises}/${session.totalExercises}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: Color(0xFFD4E2EC),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Progress Header & Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF888888),
                        ),
                      ),
                      Text(
                        '${(session.progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: session.progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFF242424),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Exercise List
            Expanded(
              child: exercises.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.fitness_center_outlined,
                              size: 48,
                              color: Color(0xFF555555),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No exercises in this session.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => _openAddExerciseSheet(notifier),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Exercise'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];

                        return SessionExerciseTile(
                          exercise: exercise,
                          index: index,
                          isActive: index == session.currentExerciseIndex,
                          isCompleted: session.completedExerciseIndexes.contains(index),
                          onTap: () {
                            notifier.goToExercise(index);
                          },
                        );
                      },
                    ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  if (session.currentExerciseIndex > 0) ...[
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: notifier.goToPreviousExercise,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF383838)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Previous'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isCompleting
                            ? null
                            : () {
                                if (session.isLastExercise) {
                                  _finishWorkout(session);
                                } else {
                                  notifier.completeCurrentExercise();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textInverse,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isCompleting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.textInverse,
                                ),
                              )
                            : Text(
                                session.isLastExercise
                                    ? 'Finish Workout'
                                    : 'Complete Exercise',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textInverse,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishWorkout(
      WorkoutSessionState session,
      ) async {
    if (_isCompleting) {
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    try {
      final authState =
      ref.read(authStateProvider);

      final authUser =
          authState.value;

      if (authUser == null) {
        throw Exception(
          'User is not authenticated.',
        );
      }

      final completion =
      WorkoutCompletion(
        id: '',
        userId:
        authUser.id,
        workoutId:
        widget.workout.id,
        completedAt:
        DateTime.now(),
        duration:
        session.elapsedSeconds,
        completedExercises:
        session.completedExercises +
            1,
        totalExercises:
        session.totalExercises,
      );

      await ref.read(
        workoutCompletionProvider(
          completion,
        ).future,
      );

      try {
        await ref.read(
          workoutCompletionServiceProvider,
        ).completeWorkout(
          userId: authUser.id,
          workout: widget.workout,
        );
      } catch (_) {}

      ref.invalidate(
        workoutProvider,
      );

      ref.invalidate(
        todaysWorkoutProvider,
      );

      ref.invalidate(
        progressProvider,
      );

      ref.invalidate(
        memberDashboardProvider,
      );

      if (!mounted) {
        return;
      }

      context.go(
        AppRoutes.workoutCompleted,
        extra: {
          'workout':
          widget.workout,
          'duration':
          session.elapsedSeconds,
          'completedExercises':
          session.completedExercises +
              1,
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to complete workout: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  Future<void>
  _showExitConfirmation(
      BuildContext context,
      ) async {
    final shouldExit =
    await showDialog<bool>(
      context: context,
      builder:
          (context) {
        return AlertDialog(
          title: const Text(
            'Leave Workout?',
          ),
          content:
          const Text(
            'Your current workout session will not be saved.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
              const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child:
              const Text('Leave'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true &&
        context.mounted) {
      context.pop();
    }
  }

  String _formatDuration(
      int seconds,
      ) {
    final minutes =
        seconds ~/ 60;

    final remainingSeconds =
        seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }
}