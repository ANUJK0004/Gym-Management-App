import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/report_membership_breakdown.dart';


class ReportMembershipBreakdownWidget extends StatelessWidget {
  const ReportMembershipBreakdownWidget({
    super.key,
    required this.items,
  });

  final List<ReportMembershipBreakdown> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MEMBERSHIP BREAKDOWN',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          _EmptyBreakdown()
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _BreakdownRow(item: item),
            ),
          ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.item,
  });

  final ReportMembershipBreakdown item;

  @override
  Widget build(BuildContext context) {
    final barColor = _colorFor(item.planName);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: AppColors.border,
          width: .5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.planName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${item.memberCount}',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 68,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (item.percentage / 100).clamp(0, 1),
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor:
                    AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 32,
            child: Text(
              '${item.percentage.toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(String name) {
    final normalized = name.toLowerCase();

    if (normalized.contains('premium')) {
      return AppColors.owner;
    }

    if (normalized.contains('standard')) {
      return Colors.lightBlueAccent;
    }

    if (normalized.contains('basic')) {
      return Colors.amberAccent;
    }

    return AppColors.owner.withValues(alpha: .65);
  }
}

class _EmptyBreakdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: AppColors.border,
          width: .5,
        ),
      ),
      child: const Text(
        'No active membership plan assignments yet.',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      ),
    );
  }
}
