import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';

class AddMemberStepIndicator extends StatelessWidget {
  const AddMemberStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        totalSteps,
            (index) {
          final completed = index < currentStep;
          final active = index == currentStep;

          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(
                right: index == totalSteps - 1 ? 0 : 8,
              ),
              decoration: BoxDecoration(
                color: completed || active
                    ? AppColors.primary
                    : AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }
}