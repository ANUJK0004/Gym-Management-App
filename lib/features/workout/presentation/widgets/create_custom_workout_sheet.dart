import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout.dart';
import '../providers/workout_provider.dart';
import 'add_exercise_sheet.dart';

class CreateCustomWorkoutSheet extends ConsumerStatefulWidget {
  const CreateCustomWorkoutSheet({
    super.key,
    this.initialWorkout,
  });

  final Workout? initialWorkout;

  static Future<void> show(
    BuildContext context, {
    Workout? initialWorkout,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CreateCustomWorkoutSheet(
          initialWorkout: initialWorkout,
        ),
      ),
    );
  }

  @override
  ConsumerState<CreateCustomWorkoutSheet> createState() =>
      _CreateCustomWorkoutSheetState();
}

class _CreateCustomWorkoutSheetState
    extends ConsumerState<CreateCustomWorkoutSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  int _duration = 45;
  String _difficulty = 'Intermediate';
  final List<Exercise> _exercises = [];
  bool _isLoading = false;

  final List<int> _durations = [30, 45, 60, 75, 90];
  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    if (widget.initialWorkout != null) {
      _nameController.text = widget.initialWorkout!.name;
      _descController.text = widget.initialWorkout!.description;
      _duration = widget.initialWorkout!.duration > 0
          ? widget.initialWorkout!.duration
          : 45;
      _difficulty = widget.initialWorkout!.difficulty ?? 'Intermediate';
      _exercises.addAll(widget.initialWorkout!.exercises);
    } else {
      _nameController.text = 'Custom Workout';
      _descController.text = 'Personal routine';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _openAddExercise() {
    AddExerciseBottomSheet.show(
      context,
      onExerciseAdded: (exercise) {
        setState(() {
          _exercises.add(
            exercise.copyWith(order: _exercises.length),
          );
        });
      },
    );
  }

  Future<void> _saveAndStart() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a workout name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final created = await ref
          .read(workoutCreationNotifierProvider.notifier)
          .createCustomWorkout(
            name: name,
            description: _descController.text.trim().isNotEmpty
                ? _descController.text.trim()
                : 'Custom routine',
            exercises: _exercises,
            duration: _duration,
            difficulty: _difficulty,
          );

      if (!mounted) return;
      Navigator.of(context).pop();

      context.push(
        AppRoutes.workoutSession,
        extra: created,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save workout: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF191919),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: Color(0xFF2E2E2E), width: 1),
          left: BorderSide(color: Color(0xFF2E2E2E), width: 1),
          right: BorderSide(color: Color(0xFF2E2E2E), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Drag Handle & Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF424242),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create Workout',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2A2A2A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFFAAAAAA),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(color: Color(0xFF262626), height: 1),

            // Scrollable Form Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Workout Name
                  _buildLabel('WORKOUT NAME'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _inputDecoration('e.g. Upper Body Blast'),
                  ),

                  const SizedBox(height: 18),

                  // Subtitle / Focus
                  _buildLabel('FOCUS / DESCRIPTION'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descController,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: _inputDecoration('e.g. Chest, Shoulders & Triceps'),
                  ),

                  const SizedBox(height: 18),

                  // Duration & Difficulty Row
                  Row(
                    children: [
                      // Duration
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('DURATION'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              children: _durations.map((d) {
                                final isSelected = _duration == d;
                                return GestureDetector(
                                  onTap: () => setState(() => _duration = d),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : const Color(0xFF222222),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${d}m',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? AppColors.textInverse
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      // Difficulty
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('DIFFICULTY'),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              children: _difficulties.map((diff) {
                                final isSelected = _difficulty == diff;
                                return GestureDetector(
                                  onTap: () => setState(() => _difficulty = diff),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : const Color(0xFF222222),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      diff,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? AppColors.textInverse
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Exercises Header with Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('EXERCISES (${_exercises.length})'),
                      TextButton.icon(
                        onPressed: _openAddExercise,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Exercise'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (_exercises.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF282828),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.fitness_center_outlined,
                            size: 36,
                            color: Color(0xFF555555),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No exercises added yet',
                            style: TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: _openAddExercise,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add First Exercise'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF222222),
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._exercises.asMap().entries.map((entry) {
                      final index = entry.key;
                      final exercise = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F1F1F),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2C2C2C),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2A2A2A),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${exercise.muscleGroup ?? "All"} • ${exercise.sets} sets × ${exercise.reps} reps'
                                    '${exercise.weight != null ? " • ${exercise.weight} kg" : ""}',
                                    style: const TextStyle(
                                      color: Color(0xFF8E8E93),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Color(0xFFFF5252),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _exercises.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAndStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textInverse,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.textInverse,
                          ),
                        )
                      : const Text(
                          'Save & Start Workout',
                          style: TextStyle(
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
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Color(0xFF888888),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF555555),
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFF141414),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF333333)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF333333)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
