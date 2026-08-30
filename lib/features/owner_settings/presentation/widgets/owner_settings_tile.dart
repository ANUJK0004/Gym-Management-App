import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

class OwnerSettingsTile
    extends StatelessWidget {
  const OwnerSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
    this.showDivider = true,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final bool showDivider;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color:
                  AppColors.owner,
                ),

                const SizedBox(
                  width: 14,
                ),

                Expanded(
                  child: Text(
                    title,
                    style:
                    AppTextStyles.bodyMedium,
                  ),
                ),

                if(trailing!=null)

                  trailing!

                else if (value != null)
                  Text(
                    value!,
                    style: AppTextStyles
                        .labelMedium
                        .copyWith(
                      color: AppColors
                          .textSecondary,
                    ),
                  ),

                if (onTap != null) ...[
                  const SizedBox(
                    width: 8,
                  ),
                  const Icon(
                    Icons
                        .chevron_right_rounded,
                    size: 20,
                    color: AppColors
                        .textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ),

        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color:
            AppColors.border,
          ),
      ],
    );
  }
}