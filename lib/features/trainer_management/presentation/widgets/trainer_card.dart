import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

import '../../domain/entities/managed_trainer.dart';

class TrainerCard extends StatelessWidget {
  const TrainerCard({
    super.key,
    required this.trainer,
    required this.onTap,
  });

  final ManagedTrainer trainer;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    final initials =
    _getInitials(
      trainer.displayName,
    );

    return Material(
      color:
      AppColors.surface,
      borderRadius:
      AppRadius.radiusLG,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        AppRadius.radiusLG,
        child: Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration:
          BoxDecoration(
            color:
            AppColors.surface,
            borderRadius:
            AppRadius.radiusLG,
            border: Border.all(
              color:
              AppColors.border,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              _TrainerAvatar(
                trainer: trainer,
                initials: initials,
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Text(
                      trainer.displayName ??
                          'Unnamed Trainer',
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      AppTextStyles
                          .bodyMedium
                          .copyWith(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      trainer.specialization ??
                          'Fitness Trainer',
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      AppTextStyles
                          .labelMedium
                          .copyWith(
                        color:
                        AppColors
                            .textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .end,
                children: [
                  if (trainer
                      .experienceYears !=
                      null)
                    Text(
                      '${trainer.experienceYears} yrs',
                      style:
                      AppTextStyles
                          .labelMedium
                          .copyWith(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    _statusLabel(
                      trainer.status,
                    ),
                    style:
                    AppTextStyles
                        .labelMedium
                        .copyWith(
                      color:
                      trainer.isActive
                          ? AppColors
                          .primary
                          : AppColors
                          .textSecondary,
                      fontSize: 9,
                      fontWeight:
                      FontWeight.w700,
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

  String _getInitials(
      String? name,
      ) {
    if (name == null ||
        name.trim().isEmpty) {
      return '?';
    }

    final parts =
    name.trim().split(
      RegExp(r'\s+'),
    );

    if (parts.length == 1) {
      return parts.first
          .substring(
        0,
        1,
      )
          .toUpperCase();
    }

    return (
        parts.first.substring(
          0,
          1,
        ) +
            parts.last.substring(
              0,
              1,
            )
    ).toUpperCase();
  }

  String _statusLabel(
      String status,
      ) {
    if (status.isEmpty) {
      return 'Inactive';
    }

    return status[0].toUpperCase() +
        status.substring(1);
  }
}

class _TrainerAvatar
    extends StatelessWidget {
  const _TrainerAvatar({
    required this.trainer,
    required this.initials,
  });

  final ManagedTrainer trainer;
  final String initials;

  @override
  Widget build(
      BuildContext context,
      ) {
    if (trainer.photoUrl != null &&
        trainer.photoUrl!
            .trim()
            .isNotEmpty) {
      return ClipOval(
        child: Image.network(
          trainer.photoUrl!,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) {
            return _InitialAvatar(
              initials: initials,
            );
          },
        ),
      );
    }

    return _InitialAvatar(
      initials: initials,
    );
  }
}

class _InitialAvatar
    extends StatelessWidget {
  const _InitialAvatar({
    required this.initials,
  });

  final String initials;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: 42,
      height: 42,
      alignment:
      Alignment.center,
      decoration:
      const BoxDecoration(
        color:
        Color(0xFF294725),
        shape:
        BoxShape.circle,
      ),
      child: Text(
        initials,
        style: AppTextStyles
            .labelMedium
            .copyWith(
          color:
          AppColors.primary,
          fontWeight:
          FontWeight.w800,
        ),
      ),
    );
  }
}