import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class AdminAccountTile extends StatelessWidget {
  const AdminAccountTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            child: Row(
              children: [

                Icon(
                  icon,
                  color: AppColors.owner,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),

        if(showDivider)
          Divider(
            height: 1,
            thickness: .5,
            color: AppColors.border,
          ),
      ],
    );
  }
}