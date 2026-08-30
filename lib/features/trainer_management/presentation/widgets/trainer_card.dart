import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

import '../../domain/entities/managed_trainer.dart';

class TrainerCard extends StatelessWidget {
  const TrainerCard({super.key, required this.trainer, required this.onTap});

  final ManagedTrainer trainer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(trainer.displayName);

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.radiusLG,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusLG,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.radiusLG,
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      _TrainerAvatar(trainer: trainer, initials: initials),
                      if (trainer.isActive)
                        Positioned(
                          right: 0,
                          bottom: 1,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.owner,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trainer.displayName ?? 'Unnamed Trainer',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          trainer.specialization ?? 'Fitness Trainer',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (trainer.rating > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFFFA23A),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              trainer.rating.toStringAsFixed(1),
                              style: AppTextStyles.labelMedium.copyWith(
                                color: const Color(0xFFFFA23A),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 4),

                      Text(
                        '${trainer.sessionCount} sessions',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Divider(height: 1, color: AppColors.border),

              const SizedBox(height: 9),

              Row(
                children: [
                  Expanded(
                    child: _BottomInfo(
                      icon: Icons.people_alt_outlined,
                      text: '${trainer.clientCount} clients',
                    ),
                  ),

                  Expanded(
                    child: _BottomInfo(
                      icon: Icons.calendar_today_outlined,
                      text: trainer.joinedAt != null
                          ? 'Since ${_monthYear(trainer.joinedAt!)}'
                          : 'Not joined',
                    ),
                  ),

                  if (trainer.monthlySalary != null)
                    Text(
                      '₹${_money(trainer.monthlySalary!)} /mo',
                      style: const TextStyle(
                        color: AppColors.owner,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '?';
    }

    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String _monthYear(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  String _money(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }
}

class _BottomInfo extends StatelessWidget {
  const _BottomInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 11, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}

class _TrainerAvatar extends StatelessWidget {
  const _TrainerAvatar({required this.trainer, required this.initials});

  final ManagedTrainer trainer;
  final String initials;

  @override
  Widget build(BuildContext context) {
    if (trainer.photoUrl != null && trainer.photoUrl!.trim().isNotEmpty) {
      return ClipOval(
        child: Image.network(
          trainer.photoUrl!,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return _InitialAvatar(initials: initials);
          },
        ),
      );
    }

    return _InitialAvatar(initials: initials);
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.owner.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.owner,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
