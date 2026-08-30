import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

import '../../../../gym/presentation/providers/gym_provider.dart';

import '../../../../membership_plan/domain/entities/membership_plan.dart';
import '../../../../membership_plan/presentation/providers/membership_plan_provider.dart';
import '../../../domain/entities/member_enrollment.dart';
import '../../providers/member_enrollment_provider.dart';
import '../../providers/member_management_provider.dart';

import 'add_member_membership_step.dart';
import 'add_member_payment_step.dart';
import 'add_member_personal_step.dart';
import 'add_member_step_indicator.dart';
import 'member_enrollment_success.dart';

class AddMemberSheet extends ConsumerStatefulWidget {
  const AddMemberSheet({
    super.key,
  });

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

  String? _fitnessGoal;

  DateTime _startDate =
  DateTime.now();

  String? _selectedPlanId;

  String? _selectedPaymentMethod;

  bool _isSubmitting = false;

  MemberEnrollment? _completedEnrollment;

  Timer? _successTimer;

  @override
  void dispose() {
    _successTimer?.cancel();

    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync =
    ref.watch(ownerMembershipPlansProvider);

    if (_completedEnrollment != null) {
      return _buildSuccess();
    }

    return SafeArea(
      top: false,
      child: Material(
        color: AppColors.surface,
        borderRadius:
        const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        child: SizedBox(
          height:
          MediaQuery.of(context).size.height *
              0.82,
          child: Column(
            children: [
              const SizedBox(height: 12),

              _buildHandle(),

              const SizedBox(height: 12),

              _buildHeader(),

              const SizedBox(height: 10),

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: AddMemberStepIndicator(
                  currentStep: _currentStep,
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: _buildStep(
                  plansAsync,
                ),
              ),

              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 34,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.textSecondary
            .withValues(alpha: 0.55),
        borderRadius:
        BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildHeader() {
    final stepTitle = switch (_currentStep) {
      0 => 'Personal Info',
      1 => 'Membership',
      2 => 'Payment',
      _ => '',
    };

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
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
                  style:
                  AppTextStyles.headlineMedium
                      .copyWith(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Step ${_currentStep + 1} of 3 — $stepTitle',
                  style:
                  AppTextStyles.bodySmall
                      .copyWith(
                    color:
                    AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          InkWell(
            onTap: _isSubmitting
                ? null
                : () => Navigator.of(context).pop(),
            borderRadius:
            BorderRadius.circular(30),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 19,
                color:
                AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
      AsyncValue<List<MembershipPlan>>
      plansAsync,
      ) {
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
        return plansAsync.when(
          loading: () {
            return const Center(
              child:
              CircularProgressIndicator(
                color: AppColors.owner,
              ),
            );
          },
          error: (error, stack) {
            return _buildPlanError(
              error,
            );
          },
          data: (plans) {
            final activePlans =
            plans
                .where(
                  (plan) =>
              plan.isActive,
            )
                .toList();

            if (activePlans.isEmpty) {
              return _buildNoPlans();
            }

            if (_selectedPlanId == null ||
                !activePlans.any(
                      (plan) =>
                  plan.id ==
                      _selectedPlanId,
                )) {
              WidgetsBinding.instance
                  .addPostFrameCallback(
                    (_) {
                  if (!mounted) {
                    return;
                  }

                  setState(() {
                    _selectedPlanId =
                        activePlans
                            .first
                            .id;
                  });
                },
              );
            }

            final addMemberPlans =
            activePlans
                .map(
              _toAddMemberPlan,
            )
                .toList();

            return AddMemberMembershipStep(
              plans: addMemberPlans,
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
                      value ??
                          DateTime.now();
                });
              },
            );
          },
        );

      case 2:
        final plan =
            _selectedPlan;

        if (plan == null) {
          return const Center(
            child: Text(
              'Please select a membership plan.',
              style: TextStyle(
                color:
                AppColors.textSecondary,
              ),
            ),
          );
        }

        return AddMemberPaymentStep(
          memberName:
          '${_firstNameController.text.trim()} '
              '${_lastNameController.text.trim()}'
              .trim(),
          planName: plan.name,
          fitnessGoal:
          _fitnessGoal,
          amount: plan.price,
          selectedPaymentMethod:
          _selectedPaymentMethod,
          onPaymentMethodChanged:
              (value) {
            setState(() {
              _selectedPaymentMethod =
                  value;
            });
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFooter() {
    if (_currentStep == 0) {
      return _buildNavigationButtons(
        backEnabled: false,
        nextLabel: 'Continue →',
        onNext: _goToMembership,
      );
    }

    if (_currentStep == 1) {
      return _buildNavigationButtons(
        backEnabled: true,
        nextLabel: 'Continue →',
        onBack: _goBack,
        onNext: _goToPayment,
      );
    }

    return _buildNavigationButtons(
      backEnabled: true,
      nextLabel: '✓ Enroll Member',
      onBack: _goBack,
      onNext: _submitEnrollment,
      loading: _isSubmitting,
    );
  }

  Widget _buildNavigationButtons({
    required bool backEnabled,
    required String nextLabel,
    VoidCallback? onBack,
    VoidCallback? onNext,
    bool loading = false,
  }) {
    return Container(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        10,
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
          if (backEnabled) ...[
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed:
                  loading
                      ? null
                      : onBack,
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.background,
                    foregroundColor:
                    AppColors.textPrimary,
                    elevation: 0,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      AppRadius.radiusMD,
                    ),
                  ),
                  child: const Text(
                    '← Back',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed:
                loading
                    ? null
                    : onNext,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  AppColors.owner,
                  foregroundColor:
                  Colors.black,
                  disabledBackgroundColor:
                  AppColors.owner
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
                child: loading
                    ? const SizedBox(
                  width: 21,
                  height: 21,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.black,
                  ),
                )
                    : Text(
                  nextLabel,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanError(
      Object error,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load membership plans.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                AppColors.textPrimary,
                fontWeight:
                FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color:
                AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () {
                ref.invalidate(
                  ownerMembershipPlansProvider,
                );
              },
              child: const Text(
                'Retry',
                style: TextStyle(
                  color:
                  AppColors.owner,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPlans() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No active membership plans are available.\n'
              'Create a membership plan first.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
            AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return MemberEnrollmentSuccess(
      enrollment:
      _completedEnrollment!,
      onDone: () {
        Navigator.of(context).pop();
      },
    );
  }

  MembershipPlan? get _selectedPlan {
    final plans =
        ref
            .read(
          ownerMembershipPlansProvider,
        )
            .value;

    if (plans == null ||
        _selectedPlanId == null) {
      return null;
    }

    for (final plan in plans) {
      if (plan.id ==
          _selectedPlanId) {
        return plan;
      }
    }

    return null;
  }

  AddMemberMembershipPlan
  _toAddMemberPlan(
      MembershipPlan plan,
      ) {
    return AddMemberMembershipPlan(
      id: plan.id,
      name: plan.name,
      amount: plan.price,
      features:
      _descriptionToFeatures(
        plan.description,
      ),
    );
  }

  List<String> _descriptionToFeatures(
      String? description,
      ) {
    if (description == null ||
        description.trim().isEmpty) {
      return const [];
    }

    return description
        .split(
      RegExp(r'[•\n,]'),
    )
        .map(
          (value) => value.trim(),
    )
        .where(
          (value) =>
      value.isNotEmpty,
    )
        .take(4)
        .toList();
  }

  bool _validatePersonal() {
    if (_firstNameController.text
        .trim()
        .isEmpty) {
      _showMessage(
        'First name is required.',
      );
      return false;
    }

    if (_lastNameController.text
        .trim()
        .isEmpty) {
      _showMessage(
        'Last name is required.',
      );
      return false;
    }

    final email =
    _emailController.text.trim();

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      _showMessage(
        'Enter a valid email address.',
      );
      return false;
    }

    final phone =
    _phoneController.text.trim();

    if (phone.isNotEmpty &&
        phone.length < 7) {
      _showMessage(
        'Enter a valid phone number.',
      );
      return false;
    }

    return true;
  }

  void _goToMembership() {
    FocusScope.of(context).unfocus();

    if (!_validatePersonal()) {
      return;
    }

    setState(() {
      _currentStep = 1;
    });
  }

  void _goToPayment() {
    FocusScope.of(context).unfocus();

    if (_selectedPlan == null) {
      _showMessage(
        'Please select a membership plan.',
      );
      return;
    }

    setState(() {
      _currentStep = 2;
    });
  }

  void _goBack() {
    FocusScope.of(context).unfocus();

    if (_currentStep <= 0) {
      return;
    }

    setState(() {
      _currentStep--;
    });
  }

  Future<void>
  _submitEnrollment() async {
    FocusScope.of(context).unfocus();

    final plan = _selectedPlan;

    if (plan == null) {
      _showMessage(
        'Please select a membership plan.',
      );
      return;
    }

    final gym =
        ref.read(ownerGymProvider).value;

    if (gym == null) {
      _showMessage(
        'Create your gym before adding members.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

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
            .trim(),
        phone:
        _nullableText(
          _phoneController.text,
        ),
        dateOfBirth:
        _dateOfBirth,
        gender: _gender,
        fitnessGoal:
        _fitnessGoal,
        membershipPlanId:
        plan.id,
        membershipPlanName:
        plan.name,
        amount:
        plan.price,
        paymentMethod:
        _selectedPaymentMethod,
        startDate:
        _startDate,
      );

      if (!mounted) {
        return;
      }

      ref.invalidate(
        gymMembersProvider,
      );

      setState(() {
        _isSubmitting = false;
        _completedEnrollment =
            enrollment;
      });

      _successTimer?.cancel();

      _successTimer = Timer(
        const Duration(seconds: 3),
            () {
          if (!mounted) {
            return;
          }

          Navigator.of(context).pop();
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(
        'Failed to add member: $error',
      );
    }
  }

  String? _nullableText(
      String value,
      ) {
    final trimmed = value.trim();

    return trimmed.isEmpty
        ? null
        : trimmed;
  }

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}