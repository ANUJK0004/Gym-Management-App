import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_radius.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
    this.icon = Icons.arrow_back_rounded,
  });

  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      icon: Icon(
        icon,
        size: AppDimensions.iconMedium,
        color: AppColors.textPrimary,
      ),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
      ),
    );
  }
}