import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';

import '../../../../gym/presentation/providers/gym_provider.dart';
import '../../../domain/entities/trainer_enrollment.dart';
import '../../providers/trainer_enrollment_provider.dart';

class AddTrainerSheet
    extends ConsumerStatefulWidget {
  const AddTrainerSheet({
    super.key,
  });

  @override
  ConsumerState<AddTrainerSheet>
  createState() =>
      _AddTrainerSheetState();
}

class _AddTrainerSheetState
    extends ConsumerState<AddTrainerSheet> {
  final _formKey =
  GlobalKey<FormState>();

  final _nameController =
  TextEditingController();

  final _emailController =
  TextEditingController();

  final _salaryController =
  TextEditingController();

  final _startDateController =
  TextEditingController();

  String? _selectedSpecialization;

  bool _submitting = false;

  static const _specializations = [
    'Strength & Conditioning',
    'Yoga & Flexibility',
    'Powerlifting',
    'HIIT Training',
    'Cardio & Endurance',
    'Nutrition Coach',
    'CrossFit',
    'Pilates',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _salaryController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return SafeArea(
      top: false,
      child: Material(
        color: AppColors.surface,
        borderRadius:
        const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.fromLTRB(
            24,
            12,
            24,
            24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _handle(),

                const SizedBox(
                  height: 18,
                ),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Add New Trainer',
                        style: TextStyle(
                          color:
                          AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: _submitting
                          ? null
                          : () =>
                          Navigator.pop(
                            context,
                          ),
                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                      child: Container(
                        width: 25,
                        height: 25,
                        decoration:
                        const BoxDecoration(
                          color:
                          Color(0xFF303030),
                          shape:
                          BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color:
                          AppColors
                              .textSecondary,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),

                _label('FULL NAME'),
                const SizedBox(height: 7),

                _field(
                  controller:
                  _nameController,
                  hint: 'e.g. Jane Cruz',
                  textInputAction:
                  TextInputAction.next,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter trainer name';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 15,
                ),

                _label('EMAIL'),
                const SizedBox(height: 7),

                _field(
                  controller:
                  _emailController,
                  hint: 'jane@gymsync.com',
                  keyboardType:
                  TextInputType.emailAddress,
                  textInputAction:
                  TextInputAction.next,
                  validator:
                  _emailValidator,
                ),

                const SizedBox(
                  height: 15,
                ),

                _label(
                  'MONTHLY SALARY (₹)',
                ),
                const SizedBox(height: 7),

                _field(
                  controller:
                  _salaryController,
                  hint: 'e.g. 30000',
                  keyboardType:
                  TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly,
                  ],
                  textInputAction:
                  TextInputAction.next,
                  validator: (value) {
                    final salary =
                    double.tryParse(
                      value?.trim() ?? '',
                    );

                    if (salary == null ||
                        salary <= 0) {
                      return 'Enter a valid salary';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 15,
                ),

                _label('START DATE'),
                const SizedBox(height: 7),

                _field(
                  controller:
                  _startDateController,
                  hint: 'YYYY-MM-DD',
                  readOnly: true,
                  suffixIcon:
                  const Icon(
                    Icons
                        .calendar_today_outlined,
                    size: 16,
                    color: AppColors
                        .textSecondary,
                  ),
                  onTap: _selectDate,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Select start date';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 15,
                ),

                _label('SPECIALIZATION'),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 7,
                  runSpacing: 8,
                  children:
                  _specializations.map(
                        (specialization) {
                      return _SpecializationChip(
                        label:
                        specialization,
                        selected:
                        _selectedSpecialization ==
                            specialization,
                        onTap: () {
                          setState(() {
                            _selectedSpecialization =
                                specialization;
                          });
                        },
                      );
                    },
                  ).toList(),
                ),

                const SizedBox(
                  height: 25,
                ),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed:
                    _submitting
                        ? null
                        : _submit,
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.primary,
                      foregroundColor:
                      Colors.black,
                      disabledBackgroundColor:
                      AppColors.primary
                          .withValues(
                        alpha: 0.45,
                      ),
                      elevation: 0,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        AppRadius.radiusMD,
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,
                        color:
                        Colors.black,
                      ),
                    )
                        : const Text(
                      'Add Trainer',
                      style:
                      TextStyle(
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius:
          BorderRadius.circular(
            10,
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 8,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    List<TextInputFormatter>?
    inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      readOnly: readOnly,
      onTap: onTap,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 11,
      ),
      decoration:
      InputDecoration(
        hintText: hint,
        hintStyle:
        const TextStyle(
          color: Color(0xFF666666),
          fontSize: 10,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          AppRadius.radiusMD,
          borderSide:
          const BorderSide(
            color:
            AppColors.border,
            width: 0.5,
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          AppRadius.radiusMD,
          borderSide:
          const BorderSide(
            color:
            AppColors.primary,
            width: 1,
          ),
        ),
        errorBorder:
        OutlineInputBorder(
          borderRadius:
          AppRadius.radiusMD,
          borderSide:
          const BorderSide(
            color:
            Colors.redAccent,
            width: 0.7,
          ),
        ),
        focusedErrorBorder:
        OutlineInputBorder(
          borderRadius:
          AppRadius.radiusMD,
          borderSide:
          const BorderSide(
            color:
            Colors.redAccent,
            width: 1,
          ),
        ),
        errorStyle:
        const TextStyle(
          fontSize: 8,
          height: 1.2,
        ),
      ),
    );
  }

  String? _emailValidator(
      String? value,
      ) {
    final email =
        value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Enter email';
    }

    final regex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!regex.hasMatch(email)) {
      return 'Enter a valid email';
    }

    return null;
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final selected =
    await showDatePicker(
      context: context,
      initialDate: now,
      firstDate:
      DateTime(now.year - 1),
      lastDate:
      DateTime(now.year + 5),
      builder:
          (context, child) {
        return Theme(
          data:
          Theme.of(context).copyWith(
            colorScheme:
            const ColorScheme.dark(
              primary:
              AppColors.primary,
              surface:
              AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected == null ||
        !mounted) {
      return;
    }

    final month =
    selected.month.toString()
        .padLeft(2, '0');

    final day =
    selected.day.toString()
        .padLeft(2, '0');

    setState(() {
      _startDateController.text =
      '${selected.year}-$month-$day';
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_selectedSpecialization ==
        null) {
      _showError(
        'Please select a specialization.',
      );
      return;
    }

    final salary =
    double.parse(
      _salaryController.text.trim(),
    );

    final startDate =
    DateTime.parse(
      _startDateController.text.trim(),
    );

    final gym =
    await ref.read(
      ownerGymProvider.future,
    );

    if (gym == null) {
      _showError(
        'Create your gym before adding trainers.',
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final enrollment =
      await ref
          .read(
        trainerEnrollmentControllerProvider
            .notifier,
      )
          .enroll(
        gymId: gym.id,
        displayName:
        _nameController.text
            .trim(),
        email:
        _emailController.text
            .trim(),
        monthlySalary:
        salary,
        startDate:
        startDate,
        specialization:
        _selectedSpecialization,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop<TrainerEnrollment>(
        context,
        enrollment,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(
        _friendlyError(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _showError(
      String message,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
          SnackBarBehavior.floating,
        ),
      );
  }

  String _friendlyError(
      Object error,
      ) {
    return error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );
  }
}

class _SpecializationChip
    extends StatelessWidget {
  const _SpecializationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color: selected
          ? AppColors.primary
          : AppColors.background,
      borderRadius:
      BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(9),
        child: Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(9),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border,
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.black
                  : AppColors
                  .textSecondary,
              fontSize: 9,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}