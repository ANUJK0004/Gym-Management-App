import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';

class TrainerStatusChip
    extends StatelessWidget {
  const TrainerStatusChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color: selected
          ? AppColors.primary
          : AppColors.surface,
      borderRadius:
      BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(9),
        child: Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          decoration:
          BoxDecoration(
            borderRadius:
            BorderRadius.circular(9),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border,
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.black
                  : AppColors
                  .textSecondary,
              fontSize: 11,
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}