import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

class AddMemberMembershipPlan {
  const AddMemberMembershipPlan({
    required this.id,
    required this.name,
    required this.amount,
    this.durationInDays = 0,
    this.features = const [],
  });

  final String id;
  final String name;
  final double amount;
  final int durationInDays;
  final List<String> features;
}

class AddMemberMembershipStep
    extends StatelessWidget {
  const AddMemberMembershipStep({
    super.key,
    required this.plans,
    required this.selectedPlanId,
    required this.selectedFitnessGoal,
    required this.startDate,
    required this.onPlanChanged,
    required this.onFitnessGoalChanged,
    required this.onStartDateChanged,
  });

  final List<AddMemberMembershipPlan> plans;

  final String? selectedPlanId;
  final String? selectedFitnessGoal;
  final DateTime? startDate;

  final ValueChanged<String> onPlanChanged;
  final ValueChanged<String?> onFitnessGoalChanged;
  final ValueChanged<DateTime?> onStartDateChanged;

  static const fitnessGoals = [
    'Weight Loss',
    'Muscle Gain',
    'Endurance',
    'Strength',
    'Toning',
    'General Fitness',
    'Rehabilitation',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        20,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _sectionLabel(
            'MEMBERSHIP PLAN',
          ),

          const SizedBox(height: 10),

          ...plans.map(
                (plan) => Padding(
              padding:
              const EdgeInsets.only(
                bottom: 10,
              ),
              child: _planCard(plan),
            ),
          ),

          const SizedBox(height: 5),

          _sectionLabel(
            'FITNESS GOAL',
          ),

          const SizedBox(height: 9),

          Wrap(
            spacing: 7,
            runSpacing: 7,
            children:
            fitnessGoals.map(
                  (goal) {
                final selected =
                    selectedFitnessGoal ==
                        goal;

                return InkWell(
                  onTap: () =>
                      onFitnessGoalChanged(
                        selected
                            ? null
                            : goal,
                      ),
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                  child: Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration:
                    BoxDecoration(
                      color: selected
                          ? AppColors
                          .primary
                          : AppColors
                          .background,
                      borderRadius:
                      BorderRadius
                          .circular(
                        20,
                      ),
                      border:
                      Border.all(
                        color: selected
                            ? AppColors
                            .primary
                            : AppColors
                            .border,
                      ),
                    ),
                    child: Text(
                      goal,
                      style: TextStyle(
                        color: selected
                            ? Colors.black
                            : AppColors
                            .textSecondary,
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),

          const SizedBox(height: 18),

          _sectionLabel(
            'START DATE',
          ),

          const SizedBox(height: 8),

          _startDateField(context),
        ],
      ),
    );
  }

  Widget _planCard(
      AddMemberMembershipPlan plan,
      ) {
    final selected =
        selectedPlanId == plan.id;

    return InkWell(
      onTap: () =>
          onPlanChanged(plan.id),
      borderRadius:
      AppRadius.radiusLG,
      child: AnimatedContainer(
        duration:
        const Duration(
          milliseconds: 150,
        ),
        padding:
        const EdgeInsets.all(14),
        decoration:
        BoxDecoration(
          color: selected
              ? const Color(
            0xFF1D2A1B,
          )
              : AppColors.background,
          borderRadius:
          AppRadius.radiusLG,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selected
                      ? Icons
                      .radio_button_checked
                      : Icons
                      .radio_button_off,
                  size: 17,
                  color: selected
                      ? AppColors.primary
                      : AppColors
                      .textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    plan.name,
                    style: AppTextStyles
                        .bodyMedium
                        .copyWith(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '₱${_money(plan.amount)}',
                  style:
                  const TextStyle(
                    color:
                    AppColors.primary,
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const Text(
                  '/mo',
                  style: TextStyle(
                    color:
                    AppColors
                        .textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),

            if (plan.features.isNotEmpty) ...[
              const SizedBox(height: 9),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children:
                plan.features.map(
                      (feature) {
                    return Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        Colors.black26,
                        borderRadius:
                        BorderRadius
                            .circular(
                          10,
                        ),
                      ),
                      child: Text(
                        '✓ $feature',
                        style:
                        const TextStyle(
                          color: AppColors
                              .textSecondary,
                          fontSize: 8,
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _startDateField(
      BuildContext context,
      ) {
    return InkWell(
      onTap: () async {
        final selected =
        await showDatePicker(
          context: context,
          initialDate:
          startDate ??
              DateTime.now(),
          firstDate:
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
          lastDate:
          DateTime.now().add(
            const Duration(
              days: 3650,
            ),
          ),
          builder:
              (context, child) {
            return Theme(
              data:
              Theme.of(context)
                  .copyWith(
                colorScheme:
                const ColorScheme
                    .dark(
                  primary:
                  AppColors.primary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (selected != null) {
          onStartDateChanged(
            selected,
          );
        }
      },
      borderRadius:
      AppRadius.radiusMD,
      child: Container(
        height: 48,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration:
        BoxDecoration(
          color:
          AppColors.background,
          borderRadius:
          AppRadius.radiusMD,
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                startDate == null
                    ? 'dd-mm-yyyy'
                    : _formatDate(
                  startDate!,
                ),
                style: TextStyle(
                  color: startDate ==
                      null
                      ? AppColors
                      .textSecondary
                      : AppColors
                      .textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
            const Icon(
              Icons
                  .calendar_today_outlined,
              size: 15,
              color:
              AppColors
                  .textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(
      String text,
      ) {
    return Text(
      text,
      style: AppTextStyles
          .labelMedium
          .copyWith(
        fontSize: 9,
        fontWeight:
        FontWeight.w700,
        color:
        AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  String _money(
      double amount,
      ) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
      RegExp(
        r'(\d)(?=(\d{3})+(?!\d))',
      ),
          (match) =>
      '${match[1]},',
    );
  }

  String _formatDate(
      DateTime date,
      ) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }
}