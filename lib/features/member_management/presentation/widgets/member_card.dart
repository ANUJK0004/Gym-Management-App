import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

import '../../domain/entities/managed_member.dart';

class MemberCard extends StatelessWidget {
  const MemberCard({
    super.key,
    required this.member,
    required this.onTap,
  });

  final ManagedMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(
      member.displayName,
    );

    final status =
        member.membershipStatus ?? 'Inactive';

    final isActive =
        status.toLowerCase() == 'active';

    final isExpired =
        status.toLowerCase() == 'expired';

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.radiusLG,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusLG,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.radiusLG,
            border: Border.all(
              color: AppColors.border,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // ------------------------------------------------
              // PROFILE IMAGE / INITIALS
              // ------------------------------------------------

              _MemberAvatar(
                member: member,
                initials: initials,
              ),

              const SizedBox(
                width: 12,
              ),

              // ------------------------------------------------
              // MEMBER INFORMATION
              // ------------------------------------------------

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.displayName ??
                          'Unnamed Member',
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: AppTextStyles
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
                      _membershipText(),
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: AppTextStyles
                          .labelMedium
                          .copyWith(
                        color: AppColors
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

              // ------------------------------------------------
              // STATUS
              // ------------------------------------------------

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Text(
                    _statusLabel(
                      status,
                    ),
                    style: AppTextStyles
                        .labelMedium
                        .copyWith(
                      color: isActive
                          ? AppColors.primary
                          : isExpired
                          ? Colors.redAccent
                          : AppColors
                          .textSecondary,
                      fontSize: 9,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 7,
                  ),

                  const Icon(
                    Icons
                        .chevron_right_rounded,
                    size: 18,
                    color: AppColors
                        .textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _membershipText() {
    if (member.membershipPlanId !=
        null) {
      if (member.joinedAt != null) {
        return 'Plan assigned • '
            '${_formatYear(member.joinedAt!)}';
      }

      return 'Membership plan assigned';
    }

    if (member.joinedAt != null) {
      return 'No plan assigned • '
          '${_formatYear(member.joinedAt!)}';
    }

    return 'No membership plan';
  }

  String _formatYear(
      DateTime date,
      ) {
    return date.year.toString();
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
}

// ------------------------------------------------------------
// MEMBER AVATAR
// ------------------------------------------------------------

class _MemberAvatar
    extends StatelessWidget {
  const _MemberAvatar({
    required this.member,
    required this.initials,
  });

  final ManagedMember member;
  final String initials;

  @override
  Widget build(
      BuildContext context,
      ) {
    if (member.photoUrl != null &&
        member.photoUrl!
            .trim()
            .isNotEmpty) {
      return ClipOval(
        child: Image.network(
          member.photoUrl!,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorBuilder:
              (_, _, _) {
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
      alignment: Alignment.center,
      decoration:
      const BoxDecoration(
        color: Color(0xFF294725),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: AppTextStyles
            .labelMedium
            .copyWith(
          color: AppColors.primary,
          fontWeight:
          FontWeight.w800,
        ),
      ),
    );
  }
}