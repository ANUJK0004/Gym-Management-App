import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

class OwnerSettingsSection
    extends StatelessWidget {
  const OwnerSettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
          AppTextStyles.labelMedium.copyWith(
            color:
            AppColors.textSecondary,
            fontWeight:
            FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        Container(
          decoration: BoxDecoration(
            color:
            AppColors.surface,
            borderRadius:
            BorderRadius.circular(14),
            border: Border.all(
              color:
              AppColors.border,
              width: 0.5,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}