import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/membership.dart';

class MembershipStatusBadge extends StatelessWidget {
  const MembershipStatusBadge({
    super.key,
    required this.membership,
  });

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    final Color color;

    final String text;

    if (membership.isExpired) {
      color = AppColors.error;
      text = 'Expired';
    } else if (membership.isExpiringSoon) {
      color = AppColors.warning;
      text = 'Expiring Soon';
    } else if (membership.isActive) {
      color = AppColors.success;
      text = 'Active';
    } else {
      color = AppColors.textSecondary;
      text = membership.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.12,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}