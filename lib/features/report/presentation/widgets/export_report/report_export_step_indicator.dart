import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';


class ReportExportStepIndicator extends StatelessWidget {
  const ReportExportStepIndicator({
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
          final active = index <= currentStep;

          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(
                right: index == totalSteps - 1 ? 0 : 7,
              ),
              decoration: BoxDecoration(
                color: active
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