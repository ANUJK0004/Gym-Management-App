import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({
    super.key,
    required this.value,
    this.minHeight = 6,
  });

  final double value;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: minHeight,
        backgroundColor: AppColors.border,
        valueColor: const AlwaysStoppedAnimation<Color>(
          AppColors.primary,
        ),
      ),
    );
  }
}