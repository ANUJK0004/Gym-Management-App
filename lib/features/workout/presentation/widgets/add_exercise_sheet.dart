import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/exercise.dart';

class AddExerciseBottomSheet extends StatefulWidget {
  const AddExerciseBottomSheet({
    super.key,
    this.onExerciseAdded,
  });

  final ValueChanged<Exercise>? onExerciseAdded;

  static Future<Exercise?> show(
    BuildContext context, {
    ValueChanged<Exercise>? onExerciseAdded,
  }) {
    return showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddExerciseBottomSheet(
          onExerciseAdded: onExerciseAdded,
        ),
      ),
    );
  }

  @override
  State<AddExerciseBottomSheet> createState() => _AddExerciseBottomSheetState();
}

class _AddExerciseBottomSheetState extends State<AddExerciseBottomSheet> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedMuscleGroup = 'Shoulders';
  int _selectedSets = 3;
  String _selectedReps = '12';

  final List<String> _muscleGroups = const [
    'Chest',
    'Back',
    'Shoulders',
    'Arms',
    'Legs',
    'Core',
    'Cardio',
    'Full Body',
  ];

  final List<int> _setOptions = const [1, 2, 3, 4, 5];

  final List<String> _repOptions = const [
    '5',
    '6',
    '8',
    '10',
    '12',
    '15',
    '20',
    'Failure',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an exercise name'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final weightText = _weightController.text.trim();
    final weight = double.tryParse(weightText.replaceAll(RegExp(r'[^0-9.]'), ''));
    final repsInt = int.tryParse(_selectedReps) ?? 0;

    final exercise = Exercise(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      muscleGroup: _selectedMuscleGroup,
      sets: _selectedSets,
      reps: repsInt,
      weight: weight,
      description: _selectedReps == 'Failure' ? 'To Failure' : null,
      order: 0,
    );

    widget.onExerciseAdded?.call(exercise);
    Navigator.of(context).pop(exercise);
  }

  @override
  Widget build(BuildContext context) {
    final isNameEmpty = _nameController.text.trim().isEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF191919),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: Color(0xFF2E2E2E),
            width: 1,
          ),
          left: BorderSide(
            color: Color(0xFF2E2E2E),
            width: 1,
          ),
          right: BorderSide(
            color: Color(0xFF2E2E2E),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
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

              // Header: Title & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Exercise',
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

              const SizedBox(height: 20),

              // 1. EXERCISE NAME Section
              _buildSectionLabel('EXERCISE NAME'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                autofocus: false,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                cursorColor: AppColors.primary,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'e.g. Romanian Deadlift',
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
                    borderSide: const BorderSide(
                      color: Color(0xFF333333),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _nameController.text.trim().isNotEmpty
                          ? AppColors.primary.withValues(alpha: 0.6)
                          : const Color(0xFF333333),
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. MUSCLE GROUP Section
              _buildSectionLabel('MUSCLE GROUP'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: _muscleGroups.map((group) {
                  final isSelected = _selectedMuscleGroup.toLowerCase() == group.toLowerCase();
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMuscleGroup = group;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFF222222),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFF303030),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        group,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.textInverse
                              : const Color(0xFFB0B0B0),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // 3. SETS, REPS, WEIGHT ROW
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SETS Column
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('SETS'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _setOptions.map((sets) {
                            final isSelected = _selectedSets == sets;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSets = sets;
                                });
                              },
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : const Color(0xFF222222),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : const Color(0xFF303030),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$sets',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? AppColors.textInverse
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // REPS Column
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('REPS'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 8,
                          children: _repOptions.map((reps) {
                            final isSelected = _selectedReps == reps;
                            final isFailure = reps == 'Failure';
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedReps = reps;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isFailure ? 10 : 8,
                                  vertical: 8,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 38,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : const Color(0xFF222222),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : const Color(0xFF303030),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    reps,
                                    style: TextStyle(
                                      fontSize: isFailure ? 11 : 13,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? AppColors.textInverse
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // WEIGHT Column
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('WEIGHT'),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'kg / BW',
                            hintStyle: const TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF222222),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF303030),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF303030),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 4. ADD TO WORKOUT CTA BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isNameEmpty
                        ? const Color(0xFF2C2C2C)
                        : AppColors.primary,
                    foregroundColor: isNameEmpty
                        ? const Color(0xFF6E6E6E)
                        : AppColors.textInverse,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Add to Workout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isNameEmpty
                          ? const Color(0xFF7A7A7A)
                          : AppColors.textInverse,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
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
}
