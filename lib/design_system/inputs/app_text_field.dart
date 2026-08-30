import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.focusedColor,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final Color? focusedColor;

  @override
  Widget build(BuildContext context) {
    final activeColor = focusedColor ?? AppColors.primary;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      style: AppTextStyles.bodyLarge,
      cursorColor: activeColor,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(
          prefixIcon,
          color: AppColors.textSecondary,
        )
            : null,
        suffixIcon: suffixIcon,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textHint,
        ),
        labelStyle: AppTextStyles.bodyMedium,
        floatingLabelStyle: AppTextStyles.bodyMedium.copyWith(
          color: activeColor,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: AppColors.inputField,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: BorderSide(
            color: activeColor,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}