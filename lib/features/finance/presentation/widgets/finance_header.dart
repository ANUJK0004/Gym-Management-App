import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class FinanceHeader
    extends StatelessWidget {
  const FinanceHeader({
    super.key,
    required this.onExport,
  });

  final VoidCallback onExport;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Finance',
                style:
                AppTextStyles
                    .headlineMedium
                    .copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              Text(
                'Revenue & expenses',
                style:
                AppTextStyles
                    .labelMedium
                    .copyWith(
                  color:
                  AppColors
                      .textSecondary,
                ),
              ),
            ],
          ),
        ),

        TextButton(
          onPressed:
          onExport,
          style:
          TextButton.styleFrom(
            backgroundColor:
            AppColors.primary
                .withOpacity(
              0.15,
            ),
            foregroundColor:
            AppColors.primary,
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 14,
              vertical: 8,
            ),
          ),
          child:
          const Text(
            'Export',
          ),
        ),
      ],
    );
  }
}