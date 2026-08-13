import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';

class TrainerSearchBar extends StatelessWidget {
  const TrainerSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: 'Search trainers...',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 19,
          color:
          AppColors.textSecondary,
        ),
        suffixIcon:
        controller.text.isNotEmpty
            ? IconButton(
          onPressed: () {
            controller.clear();
            onChanged('');
          },
          icon: const Icon(
            Icons.close_rounded,
            size: 18,
          ),
        )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(10),
          borderSide:
          const BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(10),
          borderSide:
          const BorderSide(
            color: AppColors.primary,
            width: 1,
          ),
        ),
      ),
    );
  }
}