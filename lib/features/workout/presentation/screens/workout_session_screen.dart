import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_completion.dart';
import '../providers/workout_provider.dart';
import '../providers/workout_session_provider.dart';
import '../widgets/session_exercise_tile.dart';

class WorkoutSessionScreen
    extends ConsumerStatefulWidget {
  const WorkoutSessionScreen({
    super.key,
    required this.workout,
  });

  final Workout workout;

  @override
  ConsumerState<
      WorkoutSessionScreen>
  createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState
    extends ConsumerState<
        WorkoutSessionScreen> {
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

  @override
  Widget build(
      BuildContext context,
      ) {
    final session =
    ref.watch(
      workoutSessionProvider(
        widget.workout,
      ),
    );

    final notifier =
    ref.read(
      workoutSessionProvider(
        widget.workout,
      ).notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.workout.name,
            ),
            Text(
              widget.workout.description,
              style:
              const TextStyle(
                fontSize: 11,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            _showExitConfirmation(
              context,
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              session.isPaused
                  ? Icons.play_arrow
                  : Icons.pause,
            ),
            onPressed:
            notifier.togglePause,
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
              const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:
                        _SessionStat(
                          label:
                          'Elapsed Time',
                          value:
                          _formatDuration(
                            session
                                .elapsedSeconds,
                          ),
                        ),
                      ),
                      Expanded(
                        child:
                        _SessionStat(
                          label:
                          'Exercises',
                          value:
                          '${session.completedExercises}/${session.totalExercises}',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                      ),
                      Text(
                        '${(session.progress * 100).round()}%',
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  LinearProgressIndicator(
                    value:
                    session.progress,
                    minHeight: 6,
                  ),
                ],
              ),
            ),

            Expanded(
              child:
              widget.workout.exercises
                  .isEmpty
                  ? const Center(
                child: Text(
                  'No exercises added yet.',
                ),
              )
                  : ListView.builder(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 16,
                ),
                itemCount:
                widget
                    .workout
                    .exercises
                    .length,
                itemBuilder:
                    (context, index) {
                  final exercise =
                  widget
                      .workout
                      .exercises[index];

                  return SessionExerciseTile(
                    exercise:
                    exercise,
                    index:
                    index,
                    isActive:
                    index ==
                        session
                            .currentExerciseIndex,
                    isCompleted:
                    session
                        .completedExerciseIndexes
                        .contains(
                      index,
                    ),
                    onTap: () {
                      notifier
                          .goToExercise(
                        index,
                      );
                    },
                  );
                },
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (session
                      .currentExerciseIndex >
                      0)
                    Expanded(
                      child:
                      OutlinedButton(
                        onPressed:
                        notifier
                            .goToPreviousExercise,
                        child:
                        const Text(
                          'Previous',
                        ),
                      ),
                    ),

                  if (session
                      .currentExerciseIndex >
                      0)
                    const SizedBox(
                      width: 12,
                    ),

                  Expanded(
                    flex: 2,
                    child:
                    FilledButton(
                      onPressed:
                      _isCompleting
                          ? null
                          : () {
                        if (session
                            .isLastExercise) {
                          _finishWorkout(
                            session,
                          );
                        } else {
                          notifier
                              .completeCurrentExercise();
                        }
                      },
                      child:
                      _isCompleting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                        CircularProgressIndicator(
                          strokeWidth:
                          2,
                        ),
                      )
                          : Text(
                        session
                            .isLastExercise
                            ? 'Finish Workout'
                            : 'Complete Exercise',
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

      ref.invalidate(
        workoutProvider,
      );

      ref.invalidate(
        todaysWorkoutProvider,
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

class _SessionStat
    extends StatelessWidget {
  const _SessionStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
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
          height: 4,
        ),
        Text(
          label,
          style:
          const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}