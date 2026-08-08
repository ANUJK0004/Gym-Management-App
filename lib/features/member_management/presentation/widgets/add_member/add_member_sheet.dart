import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';


import '../../../../gym/presentation/providers/gym_provider.dart';
import '../../../domain/entities/member_enrollment.dart';
import '../../providers/member_enrollment_provider.dart';

import 'add_member_membership_step.dart';
import 'add_member_payment_step.dart';
import 'add_member_personal_step.dart';
import 'add_member_step_indicator.dart';
import 'member_enrollment_success.dart';

class AddMemberSheet extends ConsumerStatefulWidget {
  const AddMemberSheet({
    super.key,
    required this.plans,
    this.onCompleted,
  });

  final List<AddMemberMembershipPlan> plans;
  final VoidCallback? onCompleted;

  @override
  ConsumerState<AddMemberSheet> createState() =>
      _AddMemberSheetState();
}

class _AddMemberSheetState
    extends ConsumerState<AddMemberSheet> {
  final _firstNameController =
  TextEditingController();

  final _lastNameController =
  TextEditingController();

  final _emailController =
  TextEditingController();

  final _phoneController =
  TextEditingController();

  int _currentStep = 0;

  DateTime? _dateOfBirth;

  String? _gender;

  String? _selectedPlanId;

  String? _fitnessGoal;

  DateTime? _startDate;

  String? _paymentMethod;

  MemberEnrollment? _completedEnrollment;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_completedEnrollment != null) {
      return MemberEnrollmentSuccess(
        enrollment:
        _completedEnrollment!,
        onDone: () {
          widget.onCompleted?.call();

          Navigator.of(context).pop();
        },
      );
    }

    final enrollmentState =
    ref.watch(
      memberEnrollmentControllerProvider,
    );

    final isLoading =
        enrollmentState.isLoading;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight:
          MediaQuery.of(context).size.height *
              0.90,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
          BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            _dragHandle(),

            _header(),

            Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: AddMemberStepIndicator(
                currentStep:
                _currentStep,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: _buildStep(),
            ),

            _bottomActions(
              isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dragHandle() {
    return Padding(
      padding:
      const EdgeInsets.only(top: 10),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textSecondary
              .withValues(alpha: 0.45),
          borderRadius:
          BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        12,
        12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Member',
                  style: AppTextStyles
                      .headlineMedium
                      .copyWith(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _stepSubtitle,
                  style: AppTextStyles
                      .labelMedium
                      .copyWith(
                    color:
                    AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          InkWell(
            onTap: () =>
                Navigator.of(context).pop(),
            borderRadius:
            BorderRadius.circular(20),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color:
                AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color:
                AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _stepSubtitle {
    switch (_currentStep) {
      case 0:
        return 'Step 1 of 3 — Personal Info';

      case 1:
        return 'Step 2 of 3 — Membership';

      default:
        return 'Step 3 of 3 — Payment';
    }
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return AddMemberPersonalStep(
          firstNameController:
          _firstNameController,
          lastNameController:
          _lastNameController,
          emailController:
          _emailController,
          phoneController:
          _phoneController,
          selectedDateOfBirth:
          _dateOfBirth,
          selectedGender:
          _gender,
          onDateOfBirthChanged:
              (value) {
            setState(() {
              _dateOfBirth = value;
            });
          },
          onGenderChanged:
              (value) {
            setState(() {
              _gender = value;
            });
          },
        );

      case 1:
        return AddMemberMembershipStep(
          plans: widget.plans,
          selectedPlanId:
          _selectedPlanId,
          selectedFitnessGoal:
          _fitnessGoal,
          startDate:
          _startDate,
          onPlanChanged:
              (value) {
            setState(() {
              _selectedPlanId =
                  value;
            });
          },
          onFitnessGoalChanged:
              (value) {
            setState(() {
              _fitnessGoal =
                  value;
            });
          },
          onStartDateChanged:
              (value) {
            setState(() {
              _startDate =
                  value;
            });
          },
        );

      default:
        final plan =
            _selectedPlan;

        return AddMemberPaymentStep(
          amount:
          plan?.amount ?? 0,
          planName:
          plan?.name ?? '',
          selectedPaymentMethod:
          _paymentMethod,
          onPaymentMethodChanged:
              (value) {
            setState(() {
              _paymentMethod =
                  value;
            });
          },
        );
    }
  }

  Widget _bottomActions(
      bool isLoading,
      ) {
    return Container(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading
                    ? null
                    : _previousStep,
                style:
                OutlinedButton.styleFrom(
                  foregroundColor:
                  AppColors.textPrimary,
                  side:
                  const BorderSide(
                    color:
                    AppColors.border,
                  ),
                  padding:
                  const EdgeInsets
                      .symmetric(
                    vertical: 15,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    AppRadius.radiusMD,
                  ),
                ),
                child:
                const Text('← Back'),
              ),
            ),
            const SizedBox(width: 10),
          ],

          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : _nextStep,
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
                padding:
                const EdgeInsets
                    .symmetric(
                  vertical: 15,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  AppRadius.radiusMD,
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
                  : Text(
                _currentStep == 2
                    ? '✓ Enroll Member'
                    : 'Continue →',
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _nextStep() async {
    if (_currentStep == 0) {
      if (!_validatePersonalInfo()) {
        return;
      }

      setState(() {
        _currentStep = 1;
      });

      return;
    }

    if (_currentStep == 1) {
      if (!_validateMembership()) {
        return;
      }

      setState(() {
        _currentStep = 2;
      });

      return;
    }

    await _submitEnrollment();
  }

  void _previousStep() {
    if (_currentStep == 0) {
      return;
    }

    setState(() {
      _currentStep--;
    });
  }

  bool _validatePersonalInfo() {
    final firstName =
    _firstNameController.text.trim();

    final lastName =
    _lastNameController.text.trim();

    final email =
    _emailController.text.trim();

    if (firstName.isEmpty) {
      _showError('Enter the member first name.');
      return false;
    }

    if (lastName.isEmpty) {
      _showError('Enter the member last name.');
      return false;
    }

    if (email.isEmpty ||
        !_isValidEmail(email)) {
      _showError(
        'Enter a valid email address.',
      );
      return false;
    }

    return true;
  }

  bool _validateMembership() {
    if (_selectedPlan == null) {
      _showError(
        'Select a membership plan.',
      );
      return false;
    }

    if (_fitnessGoal == null) {
      _showError(
        'Select a fitness goal.',
      );
      return false;
    }

    if (_startDate == null) {
      _showError(
        'Select a membership start date.',
      );
      return false;
    }

    return true;
  }

  Future<void> _submitEnrollment() async {
    if (_paymentMethod == null) {
      _showError(
        'Select a payment method.',
      );
      return;
    }

    final gym =
    await ref.read(
      ownerGymProvider.future,
    );

    if (!mounted) {
      return;
    }

    if (gym == null) {
      _showError(
        'No gym is associated with this owner.',
      );
      return;
    }

    final plan = _selectedPlan;

    if (plan == null) {
      _showError(
        'Select a membership plan.',
      );
      return;
    }

    try {
      final enrollment =
      await ref
          .read(
        memberEnrollmentControllerProvider
            .notifier,
      )
          .enroll(
        gymId: gym.id,
        firstName:
        _firstNameController.text
            .trim(),
        lastName:
        _lastNameController.text
            .trim(),
        email:
        _emailController.text
            .trim()
            .toLowerCase(),
        phone:
        _phoneController.text
            .trim()
            .isEmpty
            ? null
            : _phoneController.text
            .trim(),
        dateOfBirth:
        _dateOfBirth,
        gender:
        _gender,
        fitnessGoal:
        _fitnessGoal,
        membershipPlanId:
        plan.id,
        membershipPlanName:
        plan.name,
        amount:
        plan.amount,
        paymentMethod:
        _paymentMethod!,
        startDate:
        _startDate!,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _completedEnrollment =
            enrollment;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(
        _cleanError(error),
      );
    }
  }

  AddMemberMembershipPlan?
  get _selectedPlan {
    if (_selectedPlanId == null) {
      return null;
    }

    for (final plan in widget.plans) {
      if (plan.id == _selectedPlanId) {
        return plan;
      }
    }

    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
  }

  String _cleanError(Object error) {
    final text = error.toString();

    if (text.startsWith('Exception: ')) {
      return text.substring(
        'Exception: '.length,
      );
    }

    return text;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }
}