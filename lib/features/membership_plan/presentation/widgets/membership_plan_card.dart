import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

import '../../domain/entities/membership_plan.dart';

class MembershipPlanCard
    extends StatelessWidget {
  const MembershipPlanCard({
    super.key,
    required this.plan,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final MembershipPlan plan;

  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
      const EdgeInsets.all(18),
      decoration:
      BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        AppRadius.radiusLG,
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: AppTextStyles
                      .titleMedium
                      .copyWith(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),

              Container(
                padding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration:
                BoxDecoration(
                  color: plan.isActive
                      ? AppColors.owner
                      .withValues(alpha: 0.12)
                      : Colors.grey
                      .withValues(alpha: 0.12),
                  borderRadius:
                  BorderRadius
                      .circular(20),
                ),
                child: Text(
                  plan.isActive
                      ? 'Active'
                      : 'Inactive',
                  style: AppTextStyles
                      .labelMedium
                      .copyWith(
                    color: plan.isActive
                        ? AppColors.owner
                        : AppColors
                        .textSecondary,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          if (plan.description != null &&
              plan.description!
                  .trim()
                  .isNotEmpty) ...[
            const SizedBox(
              height: 8,
            ),

            Text(
              plan.description!,
              style: AppTextStyles
                  .bodySmall
                  .copyWith(
                color: AppColors
                    .textSecondary,
              ),
            ),
          ],

          const SizedBox(
            height: 18,
          ),

          Row(
            children: [
              _PlanInfo(
                icon:
                Icons.currency_rupee,
                label: 'Price',
                value:
                '₹${plan.price.toStringAsFixed(2)}',
              ),

              const SizedBox(
                width: 20,
              ),

              _PlanInfo(
                icon: Icons
                    .calendar_today_outlined,
                label: 'Duration',
                value:
                '${plan.durationInDays} days',
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          Row(
            children: [
              Expanded(
                child:
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                  ),
                  label:
                  const Text('Edit'),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                OutlinedButton.icon(
                  onPressed:
                  onToggleStatus,
                  icon: Icon(
                    plan.isActive
                        ? Icons
                        .visibility_off_outlined
                        : Icons
                        .visibility_outlined,
                    size: 18,
                  ),
                  label: Text(
                    plan.isActive
                        ? 'Disable'
                        : 'Activate',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              style:
              OutlinedButton.styleFrom(
                foregroundColor:
                Colors.red,
                side: const BorderSide(
                  color: Colors.red,
                ),
              ),
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
              ),
              label:
              const Text(
                'Delete Plan',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanInfo
    extends StatelessWidget {
  const _PlanInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.owner,
        ),

        const SizedBox(
          width: 7,
        ),

        Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles
                  .labelMedium
                  .copyWith(
                color: AppColors
                    .textSecondary,
              ),
            ),

            Text(
              value,
              style: AppTextStyles
                  .bodyMedium
                  .copyWith(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}