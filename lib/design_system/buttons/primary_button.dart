import 'package:flutter/material.dart';
import 'package:sweatsync/app/theme/app_animations.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_radius.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primary;
    final fg = foregroundColor ?? AppColors.textInverse;

    final button = AnimatedContainer(
      duration: AppAnimation.fast,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.4),
          disabledForegroundColor: fg.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusLG,
          ),
        ),
        child: AnimatedSwitcher(
          duration: AppAnimation.fast,
          child: isLoading
              ? const SizedBox(
            key: ValueKey('loading'),
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.textInverse,
            ),
          )
              : Row(
            key: const ValueKey('content'),
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: AppDimensions.iconMedium,
                ),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          ),
        ),
      ),
    );

    if (isExpanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}