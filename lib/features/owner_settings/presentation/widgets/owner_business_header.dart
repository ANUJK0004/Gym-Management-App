import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

class OwnerBusinessHeader
    extends StatelessWidget {
  const OwnerBusinessHeader({
    super.key,
    required this.businessName,
    required this.address,
    required this.isVerified,
    this.logoUrl,
    this.onEdit,
  });

  final String businessName;
  final String address;
  final bool isVerified;
  final String? logoUrl;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        AppRadius.radiusLG,
        border: Border.all(
          color: AppColors.primary
              .withOpacity(0.2),
          width: 0.7,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
            BoxDecoration(
              color:
              AppColors.primary,
              borderRadius:
              BorderRadius.circular(
                14,
              ),
            ),
            alignment:
            Alignment.center,
            child: logoUrl != null &&
                logoUrl!.isNotEmpty
                ? ClipRRect(
              borderRadius:
              BorderRadius
                  .circular(
                14,
              ),
              child:
              Image.network(
                logoUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            )
                : Text(
              _initials(
                businessName,
              ),
              style: AppTextStyles
                  .titleMedium
                  .copyWith(
                color:
                Colors.black,
                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  businessName,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: AppTextStyles
                      .titleMedium
                      .copyWith(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  address,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: AppTextStyles
                      .labelMedium
                      .copyWith(
                    color: AppColors
                        .textSecondary,
                  ),
                ),

                if (isVerified)
                  Text(
                    'Verified Business ✓',
                    style: AppTextStyles
                        .labelMedium
                        .copyWith(
                      color:
                      AppColors.primary,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_rounded,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final words =
    name.trim().split(' ');

    if (words.isEmpty) {
      return 'GS';
    }

    if (words.length == 1) {
      return words.first
          .substring(
        0,
        words.first.length > 2
            ? 2
            : words.first.length,
      )
          .toUpperCase();
    }

    return '${words.first[0]}${words[1][0]}'
        .toUpperCase();
  }
}