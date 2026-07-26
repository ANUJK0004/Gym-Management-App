import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';

import '../../domain/entities/membership.dart';

import 'membership_status_badge.dart';

class MembershipDetailsCard
    extends StatelessWidget {
  const MembershipDetailsCard({
    super.key,
    required this.membership,
  });

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        AppRadius.radiusLG,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  membership.gymName,
                  style:
                  AppTextStyles.headlineMedium,
                ),
              ),

              MembershipStatusBadge(
                membership: membership,
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (membership.membershipType !=
              null)
            _MembershipDetailRow(
              label: 'Membership',
              value:
              membership.membershipType!,
            ),

          if (membership.startDate != null)
            _MembershipDetailRow(
              label: 'Started',
              value: _formatDate(
                membership.startDate!,
              ),
            ),

          if (membership.expiryDate != null)
            _MembershipDetailRow(
              label: 'Expires',
              value: _formatDate(
                membership.expiryDate!,
              ),
            ),

          _MembershipDetailRow(
            label: 'Remaining',
            value:
            '${membership.remainingDays} days',
          ),

          if (membership.paymentStatus !=
              null)
            _MembershipDetailRow(
              label: 'Payment',
              value:
              membership.paymentStatus!,
            ),

          _MembershipDetailRow(
            label: 'Auto Renew',
            value: membership.autoRenew
                ? 'Enabled'
                : 'Disabled',
          ),
        ],
      ),
    );
  }

  String _formatDate(
      DateTime date,
      ) {
    return '${date.day}/'
        '${date.month}/'
        '${date.year}';
  }
}

class _MembershipDetailRow
    extends StatelessWidget {
  const _MembershipDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
              AppTextStyles.bodyMedium
                  .copyWith(
                color:
                AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style:
            AppTextStyles.bodyMedium
                .copyWith(
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}