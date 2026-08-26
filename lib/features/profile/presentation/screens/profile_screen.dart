import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../design_system/appbar/app_back_button.dart';

import '../../../membership/presentation/providers/membership_provider.dart';
import '../../../progress/domain/entities/progress.dart';
import '../../../progress/presentation/providers/progress_provider.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/current_user_profile_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final profileAsync =
    ref.watch(currentUserProfileProvider);
    final membershipAsync =
    ref.watch(activeMembershipProvider);
    final progressAsync =
    ref.watch(progressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: profileAsync.when(
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },

          error: (error, stackTrace) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to load profile.\n$error',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            );
          },

          data: (profile) {
            if (profile == null) {
              return const Center(
                child: Text(
                  'Profile not found.',
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(
                  currentUserProfileProvider,
                );

                ref.invalidate(
                  activeMembershipProvider,
                );

                ref.invalidate(
                  progressProvider,
                );

                await Future.wait([
                  ref.read(
                    currentUserProfileProvider.future,
                  ),
                  ref.read(
                    activeMembershipProvider.future,
                  ),
                  ref.read(
                    progressProvider.future,
                  ),
                ]);
              },

              child: CustomScrollView(
                physics:
                const AlwaysScrollableScrollPhysics(),

                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      22,
                      18,
                      22,
                      32,
                    ),

                    sliver: SliverList(
                      delegate:
                      SliverChildListDelegate(
                        [
                          _ProfileTopBar(
                            profile: profile,
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          _ProfileIdentity(
                            profile: profile,
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          _ProfileBadges(
                            profile: profile,
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          _ProfileStats(
                            progressAsync: progressAsync,
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          const _SectionTitle(
                            title: 'FITNESS PROFILE',
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          _FitnessProfileCard(
                            profile: profile,
                          ),

                          const SizedBox(
                            height: 24,
                          ),

                          const _SectionTitle(
                            title: 'MEMBERSHIP',
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          _MembershipCard(
                            membershipAsync: membershipAsync,
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          _LogoutButton(
                            onLogout: () {
                              _showLogoutDialog(
                                context,
                                ref,
                              );
                            },
                          ),

                          const SizedBox(
                            height: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// TOP BAR
// ------------------------------------------------------------

class _ProfileTopBar
    extends StatelessWidget {
  const _ProfileTopBar({
    required this.profile,
  });

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppBackButton(
          fallbackRoute: AppRoutes.home,
        ),

        const Spacer(),

        Text(
          'Profile',
          style:
          AppTextStyles.titleMedium.copyWith(
            fontWeight:
            FontWeight.w700,
          ),
        ),

        const Spacer(),

        _RoundIconButton(
          icon: Icons.edit_rounded,
          iconColor: AppColors.primary,
          onPressed: () {
            context.push(
              AppRoutes.editProfile,
              extra: profile
            );
          },
        ),
      ],
    );
  }
}

class _RoundIconButton
    extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius:
      BorderRadius.circular(10),

      child: InkWell(
        onTap: onPressed,
        borderRadius:
        BorderRadius.circular(10),

        child: SizedBox(
          width: 42,
          height: 42,

          child: Icon(
            icon,
            size: 18,
            color:
            iconColor ??
                AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// PROFILE IDENTITY
// ------------------------------------------------------------

class _ProfileIdentity
    extends StatelessWidget {
  const _ProfileIdentity({
    required this.profile,
  });

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final initials =
    _getInitials(
      profile.displayName,
    );

    return Column(
      children: [
        Container(
          width: 92,
          height: 92,

          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,

            border: Border.all(
              color: AppColors.background,
              width: 4,
            ),
          ),

          child: profile.photoUrl != null &&
              profile.photoUrl!
                  .trim()
                  .isNotEmpty
              ? ClipOval(
            child: Image.network(
              profile.photoUrl!,
              fit: BoxFit.cover,

              errorBuilder:
                  (
                  context,
                  error,
                  stackTrace,
                  ) {
                return Center(
                  child: Text(
                    initials,
                    style: AppTextStyles
                        .headlineLarge
                        .copyWith(
                      color:
                      Colors.black,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
          )
              : Center(
            child: Text(
              initials,
              style: AppTextStyles
                  .headlineLarge
                  .copyWith(
                color: Colors.black,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        Text(
          profile.displayName ??
              'User',
          style: AppTextStyles
              .headlineMedium
              .copyWith(
            fontWeight:
            FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          profile.email,
          style: AppTextStyles
              .bodySmall
              .copyWith(
            color:
            AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// BADGES
// ------------------------------------------------------------

class _ProfileBadges
    extends StatelessWidget {
  const _ProfileBadges({
    required this.profile,
  });

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,

      children: [
        _Badge(
          text: _formatRole(profile.role),
          isPrimary: true,
        ),

        const SizedBox(
          width: 8,
        ),

        _Badge(
          text:
          _formatActivityLevel(
            profile.activityLevel,
          ),
          isPrimary: false,
        ),
      ],
    );
  }
}

class _Badge
    extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.isPrimary,
  });

  final String text;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.primary
            .withValues(alpha: 0.15)
            : AppColors.surface,

        borderRadius:
        BorderRadius.circular(20),

        border: Border.all(
          color: isPrimary
              ? AppColors.primary
              : AppColors.border,
          width: 0.5,
        ),
      ),

      child: Text(
        text,
        style:
        AppTextStyles.labelMedium
            .copyWith(
          color: isPrimary
              ? AppColors.primary
              : AppColors.textSecondary,
          fontWeight:
          FontWeight.w600,
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// PROFILE STATS
// ------------------------------------------------------------

class _ProfileStats
    extends StatelessWidget {
  const _ProfileStats({
    required this.progressAsync,
  });

  final AsyncValue<Progress> progressAsync;

  @override
  Widget build(BuildContext context) {
    return progressAsync.when(
      loading: () => Row(
        children: const [
          Expanded(
            child: _StatItem(
              value: '--',
              label: 'Workouts',
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: _StatItem(
              value: '--',
              label: 'This Month',
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: _StatItem(
              value: '--',
              label: 'Lost Total',
            ),
          ),
        ],
      ),
      error: (error, stackTrace) => Row(
        children: const [
          Expanded(
            child: _StatItem(
              value: '0',
              label: 'Workouts',
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: _StatItem(
              value: '0',
              label: 'This Month',
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: _StatItem(
              value: '0.0 kg',
              label: 'Lost Total',
            ),
          ),
        ],
      ),
      data: (progress) {
        final totalWorkouts = progress.totalWorkouts.toString();
        final thisMonth = progress.workoutChange.toString();

        String lostTotal;
        if (progress.weightChange < 0) {
          lostTotal = '-${progress.weightChange.abs().toStringAsFixed(1)} kg';
        } else if (progress.weightChange > 0) {
          lostTotal = '+${progress.weightChange.toStringAsFixed(1)} kg';
        } else {
          lostTotal = '0.0 kg';
        }

        return Row(
          children: [
            Expanded(
              child: _StatItem(
                value: totalWorkouts,
                label: 'Workouts',
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: _StatItem(
                value: thisMonth,
                label: 'This Month',
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: _StatItem(
                value: lostTotal,
                label: 'Lost Total',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatItem
    extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,

      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        AppRadius.radiusMD,

        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),

      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [
          Text(
            value,
            style: AppTextStyles
                .titleLarge
                .copyWith(
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            label,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,

            style: AppTextStyles
                .labelMedium
                .copyWith(
              color:
              AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// SECTION TITLE
// ------------------------------------------------------------

class _SectionTitle
    extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style:
      AppTextStyles.labelMedium
          .copyWith(
        color:
        AppColors.textSecondary,
        fontWeight:
        FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ------------------------------------------------------------
// FITNESS PROFILE
// ------------------------------------------------------------

class _FitnessProfileCard
    extends StatelessWidget {
  const _FitnessProfileCard({
    required this.profile,
  });

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return _GroupedCard(
      children: [
        _ProfileActionRow(
          icon: Icons.monitor_weight_outlined,
          label: 'Weight & Body Stats',
          value: profile.weight != null
              ? '${profile.weight!.toStringAsFixed(1)} kg'
              : 'Not provided',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    EditProfileScreen(
                      profile: profile,
                    ),
              ),
            );
          },
        ),

        _Divider(),

        _ProfileActionRow(
          icon: Icons.track_changes_rounded,
          label: 'My Goal',
          value:
          profile.fitnessGoal ??
              'Not provided',
        ),

        _Divider(),

        _ProfileActionRow(
          icon: Icons.fitness_center_rounded,
          label: 'Experience Level',
          value:
          _formatActivityLevel(
            profile.activityLevel,
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// MEMBERSHIP
// ------------------------------------------------------------

class _MembershipCard
    extends StatelessWidget {
  const _MembershipCard({
    required this.membershipAsync,
  });

  final AsyncValue membershipAsync;

  @override
  Widget build(BuildContext context) {
    return membershipAsync.when(
      loading: () {
        return const _MembershipLoadingCard();
      },

      error: (error, stackTrace) {
        return _MembershipErrorCard(
          message: 'Unable to load membership',
        );
      },

      data: (membership) {
        if (membership == null) {
          return const _NoMembershipCard();
        }

        return _GroupedCard(
          children: [
            _ProfileActionRow(
              icon: Icons.credit_card_rounded,
              label: 'My Plan',
              value:
              membership.membershipType ??
                  'Membership',
              onTap: () {
                // Membership details navigation
                // can be connected here later.
              },
            ),

            const _Divider(),

            _ProfileActionRow(
              icon: Icons.business_rounded,
              label: 'Gym',
              value:
              membership.gymName ??
                  'Not available',
            ),

            const _Divider(),

            _ProfileActionRow(
              icon: Icons.verified_rounded,
              label: 'Status',
              value:
              _formatMembershipStatus(
                membership.status,
              ),
            ),

            const _Divider(),

            _ProfileActionRow(
              icon:
              Icons.calendar_month_rounded,
              label: 'Renewal Date',
              value:
              _formatDate(
                membership.expiryDate,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MembershipLoadingCard
    extends StatelessWidget {
  const _MembershipLoadingCard();

  @override
  Widget build(BuildContext context) {
    return _GroupedCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Text(
                'Loading membership...',
                style:
                AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoMembershipCard
    extends StatelessWidget {
  const _NoMembershipCard();

  @override
  Widget build(BuildContext context) {
    return _GroupedCard(
      children: [
        _ProfileActionRow(
          icon: Icons.credit_card_outlined,
          label: 'My Plan',
          value: 'No active membership',
        ),

        const _Divider(),

        _ProfileActionRow(
          icon: Icons.calendar_month_outlined,
          label: 'Renewal Date',
          value: 'Not available',
        ),
      ],
    );
  }
}

class _MembershipErrorCard
    extends StatelessWidget {
  const _MembershipErrorCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return _GroupedCard(
      children: [
        _ProfileActionRow(
          icon: Icons.error_outline_rounded,
          label: 'Membership',
          value: message,
        ),
      ],
    );
  }
}

String _formatMembershipStatus(
    String? value,
    ) {
  if (value == null ||
      value.trim().isEmpty) {
    return 'Not available';
  }

  return value
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) {
      if (word.isEmpty) {
        return word;
      }

      return word[0].toUpperCase() +
          word.substring(1);
    },
  )
      .join(' ');
}

// ------------------------------------------------------------
// GROUPED CARD
// ------------------------------------------------------------

class _GroupedCard
    extends StatelessWidget {
  const _GroupedCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius:
        AppRadius.radiusLG,

        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),

      clipBehavior:
      Clip.antiAlias,

      child: Column(
        children: children,
      ),
    );
  }
}

class _Divider
    extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: AppColors.border,
    );
  }
}

// ------------------------------------------------------------
// ACTION ROW
// ------------------------------------------------------------

class _ProfileActionRow
    extends StatelessWidget {
  const _ProfileActionRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Icon(
                icon,
                size: 19,
                color:
                AppColors.primary,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Text(
                label,
                style: AppTextStyles
                    .bodyMedium
                    .copyWith(
                  fontWeight:
                  FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                textAlign:
                TextAlign.end,

                style: AppTextStyles
                    .bodySmall
                    .copyWith(
                  color:
                  AppColors.textSecondary,
                ),
              ),
            ),

            if (onTap != null) ...[
              const SizedBox(
                width: 6,
              ),

              Icon(
                Icons
                    .chevron_right_rounded,
                size: 20,
                color:
                AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// LOGOUT
// ------------------------------------------------------------

class _LogoutButton
    extends StatelessWidget {
  const _LogoutButton({
    required this.onLogout,
  });

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      child: OutlinedButton.icon(
        onPressed: onLogout,

        icon: const Icon(
          Icons.logout_rounded,
        ),

        label: const Text(
          'Log Out',
        ),

        style:
        OutlinedButton.styleFrom(
          foregroundColor:
          AppColors.error,

          side: BorderSide(
            color:
            AppColors.error
                .withValues(alpha: 0.5),
          ),

          padding:
          const EdgeInsets.symmetric(
            vertical: 14,
          ),

          shape:
          RoundedRectangleBorder(
            borderRadius:
            AppRadius.radiusMD,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// LOGOUT CONFIRMATION
// ------------------------------------------------------------

Future<void> _showLogoutDialog(
    BuildContext context,
    WidgetRef ref,
    ) async {
  final shouldLogout =
  await showDialog<bool>(
    context: context,

    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor:
        AppColors.surface,

        title: const Text(
          'Log Out',
        ),

        content: const Text(
          'Are you sure you want to log out?',
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(
                dialogContext,
              ).pop(false);
            },

            child: const Text(
              'Cancel',
            ),
          ),

          TextButton(
            onPressed: () {
              Navigator.of(
                dialogContext,
              ).pop(true);
            },

            child: Text(
              'Log Out',
              style: TextStyle(
                color:
                AppColors.error,
              ),
            ),
          ),
        ],
      );
    },
  );

  if (shouldLogout != true) {
    return;
  }

  try {
    await FirebaseAuth.instance
        .signOut();

    ref.invalidate(
      currentUserProfileProvider,
    );
  } catch (error) {
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          'Failed to log out: $error',
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// HELPERS
// ------------------------------------------------------------

String _getInitials(
    String? name,
    ) {
  if (name == null ||
      name.trim().isEmpty) {
    return 'U';
  }

  final parts =
  name.trim().split(' ');

  if (parts.length == 1) {
    return parts.first
        .substring(
      0,
      1,
    )
        .toUpperCase();
  }

  return (
      parts.first
          .substring(
        0,
        1,
      ) +
          parts.last
              .substring(
            0,
            1,
          )
  )
      .toUpperCase();
}

String _formatActivityLevel(
    String? value,
    ) {
  if (value == null ||
      value.trim().isEmpty) {
    return 'Not provided';
  }

  return value
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (word) {
      if (word.isEmpty) {
        return word;
      }

      return word[0].toUpperCase() +
          word.substring(1);
    },
  )
      .join(' ');
}

String _formatDate(
    DateTime? date,
    ) {
  if (date == null) {
    return 'Not available';
  }

  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String _formatRole(
    String? role,
    ) {
  if (role == null || role.trim().isEmpty) {
    return 'Member';
  }

  return role[0].toUpperCase() + role.substring(1).toLowerCase();
}