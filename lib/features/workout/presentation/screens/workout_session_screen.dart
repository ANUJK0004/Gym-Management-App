import 'package:flutter/material.dart';

import '../../domain/entities/workout.dart';
import '../../domain/entities/exercise.dart';

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({
    super.key,
    required this.workout,
  });

  final Workout workout;

  @override
  State<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState
    extends State<WorkoutSessionScreen> {

  int _currentExerciseIndex = 0;

  int _completedSets = 0;

  late final List<bool> _completedExercises;

  @override
  void initState() {
    super.initState();

    _completedExercises = List<bool>.filled(
      widget.workout.exercises.length,
      false,
    );
  }

  Exercise? get _currentExercise {
    if (widget.workout.exercises.isEmpty) {
      return null;
    }

    return widget.workout.exercises[
    _currentExerciseIndex
    ];
  }

  int get _totalExercises =>
      widget.workout.exercises.length;

  int get _completedExerciseCount =>
      _completedExercises
          .where((completed) => completed)
          .length;

  double get _progress {
    if (_totalExercises == 0) {
      return 0;
    }

    return _completedExerciseCount /
        _totalExercises;
  }

  void _completeCurrentExercise() {
    setState(() {
      _completedExercises[
      _currentExerciseIndex] = true;
    });

    if (_currentExerciseIndex <
        _totalExercises - 1) {
      setState(() {
        _currentExerciseIndex++;
        _completedSets = 0;
      });

      return;
    }

    _showWorkoutCompleted();
  }

  void _completeSet() {
    final exercise = _currentExercise;

    if (exercise == null) {
      return;
    }

    if (_completedSets >= exercise.sets) {
      return;
    }

    setState(() {
      _completedSets++;
    });

    if (_completedSets >= exercise.sets) {
      _completeCurrentExercise();
    }
  }

  void _showWorkoutCompleted() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Workout Completed!',
          ),

          content: Text(
            'Great job! You completed '
                '${widget.workout.name}.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop();

                Navigator.of(context)
                    .pop();
              },
              child: const Text(
                'Done',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _currentExercise;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.workout.name,
        ),
      ),

      body: exercise == null
          ? _buildEmptyWorkout()
          : _buildWorkoutSession(
        exercise,
      ),
    );
  }

  Widget _buildWorkoutSession(
      Exercise exercise,
      ) {
    return SafeArea(
      child: Column(
        children: [

          // =========================
          // PROGRESS
          // =========================

          Padding(
            padding:
            const EdgeInsets.fromLTRB(
              24,
              16,
              24,
              8,
            ),

            child: Column(
              children: [

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

                  children: [
                    Text(
                      'Exercise '
                          '${_currentExerciseIndex + 1}'
                          ' of '
                          '$_totalExercises',
                    ),

                    Text(
                      '${(_progress * 100).round()}%',
                    ),
                  ],
                ),

                const SizedBox(
                  height: 8,
                ),

                LinearProgressIndicator(
                  value: _progress,
                ),
              ],
            ),
          ),

          // =========================
          // EXERCISE CONTENT
          // =========================

          Expanded(
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.all(24),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [

                  Text(
                    exercise.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  if (exercise.description !=
                      null &&
                      exercise.description!
                          .isNotEmpty) ...[
                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      exercise.description!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                  ],

                  const SizedBox(
                    height: 32,
                  ),

                  // =========================
                  // EXERCISE DETAILS
                  // =========================

                  Row(
                    children: [

                      Expanded(
                        child:
                        _InfoCard(
                          label: 'Sets',
                          value:
                          '${exercise.sets}',
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child:
                        _InfoCard(
                          label: 'Reps',
                          value:
                          '${exercise.reps}',
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child:
                        _InfoCard(
                          label: 'Rest',
                          value:
                          exercise
                              .restSeconds !=
                              null
                              ? '${exercise.restSeconds}s'
                              : '--',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 40,
                  ),

                  // =========================
                  // SET TRACKER
                  // =========================

                  Text(
                    'Sets',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  ...List.generate(
                    exercise.sets,
                        (index) {

                      final completed =
                          index <
                              _completedSets;

                      return Padding(
                        padding:
                        const EdgeInsets
                            .only(
                          bottom: 12,
                        ),

                        child: ListTile(
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              12,
                            ),
                          ),

                          tileColor:
                          completed
                              ? Colors.green
                              .withValues(
                            alpha: 0.15,
                          )
                              : Theme.of(
                            context,
                          )
                              .colorScheme
                              .surfaceContainerHighest,

                          leading:
                          CircleAvatar(
                            child: Text(
                              '${index + 1}',
                            ),
                          ),

                          title: Text(
                            'Set ${index + 1}',
                          ),

                          subtitle:
                          Text(
                            '${exercise.reps} reps'
                                '${exercise.weight != null ? ' • ${exercise.weight} kg' : ''}',
                          ),

                          trailing:
                          completed
                              ? const Icon(
                            Icons
                                .check_circle,
                            color:
                            Colors.green,
                          )
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // =========================
          // BOTTOM ACTION
          // =========================

          Container(
            padding:
            const EdgeInsets.all(20),

            child: SizedBox(
              width: double.infinity,

              height: 54,

              child: ElevatedButton(
                onPressed:
                _completeSet,

                child: Text(
                  _completedSets <
                      exercise.sets
                      ? 'Complete Set'
                      : 'Next Exercise',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWorkout() {
    return const Center(
      child: Text(
        'No exercises available '
            'for this workout.',
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 12,
      ),

      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,

        borderRadius:
        BorderRadius.circular(
          12,
        ),
      ),

      child: Column(
        children: [

          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall,
          ),
        ],
      ),
    );
  }
}