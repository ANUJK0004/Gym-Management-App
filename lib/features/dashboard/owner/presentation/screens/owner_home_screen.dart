import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../../gym/presentation/providers/gym_provider.dart';
import '../providers/owner_dashboard_provider.dart';

class OwnerHomeScreen extends ConsumerWidget {
  const OwnerHomeScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final statsAsync =
    ref.watch(
      ownerDashboardStatsProvider,
    );

    final gymAsync =
    ref.watch(
      ownerGymProvider,
    );

    final user =
        ref.watch(
          firebaseAuthProvider,
        ).currentUser;

    final displayName =
    user?.displayName?.trim();

    final ownerName =
    displayName != null &&
        displayName.isNotEmpty
        ? displayName
        : 'Owner';

    final initials =
    _getInitials(
      ownerName,
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor:
        AppColors.background,

        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(
              ownerDashboardStatsProvider,
            );

            ref.invalidate(
              ownerGymProvider,
            );

            await ref.read(
              ownerDashboardStatsProvider
                  .future,
            );
          },

          child: CustomScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),

            slivers: [
              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  14,
                  18,
                  14,
                  24,
                ),

                sliver:
                SliverList(
                  delegate:
                  SliverChildListDelegate(
                    [
                      _OwnerHeader(
                        ownerName:
                        ownerName,
                        initials:
                        initials,
                        gymAsync:
                        gymAsync,
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      _StatsGrid(
                        statsAsync:
                        statsAsync,
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      const _RevenueCard(),

                      const SizedBox(
                        height: 22,
                      ),

                      const _SectionTitle(
                        title:
                        'MANAGE',
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const _ManagementGrid(),

                      const SizedBox(
                        height: 22,
                      ),

                      const _SectionTitle(
                        title:
                        'RECENT ACTIVITY',
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      const _RecentActivityList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(
      String name,
      ) {
    final parts =
    name
        .split(' ')
        .where(
          (part) =>
      part.isNotEmpty,
    )
        .toList();

    if (parts.isEmpty) {
      return 'O';
    }

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
// HEADER
// ------------------------------------------------------------

class _OwnerHeader
    extends StatelessWidget {
  const _OwnerHeader({
    required this.ownerName,
    required this.initials,
    required this.gymAsync,
  });

  final String ownerName;
  final String initials;
  final AsyncValue gymAsync;

  @override
  Widget build(
      BuildContext context,
      ) {
    final gymName =
    gymAsync.when(
      data: (gym) =>
      gym?.name ??
          'GymSync HQ',

      loading: () =>
      'Loading gym...',

      error: (_, _) =>
      'GymSync HQ',
    );

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'ADMIN CONSOLE',
                style:
                AppTextStyles
                    .labelMedium
                    .copyWith(
                  color:
                  AppColors
                      .textSecondary,
                  letterSpacing:
                  0.8,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                gymName,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style:
                AppTextStyles
                    .headlineMedium
                    .copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 2,
              ),

              Text(
                'Welcome, $ownerName',
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
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

        _HeaderIconButton(
          icon:
          Icons
              .notifications_none_rounded,
        ),

        const SizedBox(
          width: 10,
        ),

        Container(
          width: 42,
          height: 42,
          decoration:
          const BoxDecoration(
            color:
            AppColors.primary,
            shape:
            BoxShape.circle,
          ),
          alignment:
          Alignment.center,
          child: Text(
            initials,
            style:
            AppTextStyles
                .titleMedium
                .copyWith(
              color:
              Colors.black,
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton
    extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: 42,
      height: 42,
      decoration:
      BoxDecoration(
        color:
        AppColors.surface,
        shape:
        BoxShape.circle,
        border:
        Border.all(
          color:
          AppColors.border,
          width: 0.5,
        ),
      ),
      child: Icon(
        icon,
        size: 20,
        color:
        AppColors.textPrimary,
      ),
    );
  }
}

// ------------------------------------------------------------
// STATS
// ------------------------------------------------------------

class _StatsGrid
    extends StatelessWidget {
  const _StatsGrid({
    required this.statsAsync,
  });

  final AsyncValue statsAsync;

  @override
  Widget build(
      BuildContext context,
      ) {
    return statsAsync.when(
      loading: () {
        return const SizedBox(
          height: 180,
          child: Center(
            child:
            CircularProgressIndicator(),
          ),
        );
      },

      error: (
          error,
          stackTrace,
          ) {
        return Container(
          padding:
          const EdgeInsets.all(16),
          decoration:
          BoxDecoration(
            color:
            AppColors.surface,
            borderRadius:
            AppRadius.radiusLG,
            border:
            Border.all(
              color:
              AppColors.border,
              width: 0.5,
            ),
          ),
          child: Text(
            'Unable to load dashboard statistics.',
            style:
            AppTextStyles.bodyMedium,
          ),
        );
      },

      data: (stats) {
        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.65,
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),

          children: [
            _StatCard(
              icon:
              Icons.groups_rounded,
              value:
              _formatNumber(
                stats.totalMembers,
              ),
              label:
              'Total Members',
              change:
              'Live',
            ),

            _StatCard(
              icon:
              Icons
                  .monetization_on_rounded,
              value:
              '₹0',
              label:
              'Monthly Revenue',
              change:
              '—',
            ),

            _StatCard(
              icon:
              Icons
                  .directions_run_rounded,
              value:
              stats.activeTrainers
                  .toString(),
              label:
              'Active Trainers',
              change:
              'Live',
            ),

            _StatCard(
              icon:
              Icons.star_rounded,
              value:
              stats
                  .newMembersThisMonth
                  .toString(),
              label:
              'New This Month',
              change:
              'Live',
            ),
          ],
        );
      },
    );
  }

  String _formatNumber(
      int value,
      ) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
  }
}

class _StatCard
    extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.change,
  });

  final IconData icon;
  final String value;
  final String label;
  final String change;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(14),
      decoration:
      BoxDecoration(
        color:
        AppColors.surface,
        borderRadius:
        AppRadius.radiusLG,
        border:
        Border.all(
          color:
          AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color:
                AppColors.primary,
              ),

              const Spacer(),

              Text(
                change,
                style:
                AppTextStyles.labelMedium.copyWith(
                  color:
                  AppColors.primary,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            value,
            style:
            AppTextStyles.titleLarge.copyWith(
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            label,
            style:
            AppTextStyles.labelMedium.copyWith(
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
// REVENUE
// ------------------------------------------------------------

class _RevenueCard
    extends StatelessWidget {
  const _RevenueCard();

  @override
  Widget build(
      BuildContext context,
      ) {
    final values = [
      0.35,
      0.45,
      0.52,
      0.58,
      0.62,
      0.68,
      0.72,
      0.67,
      0.76,
      0.86,
      0.82,
      0.92,
    ];

    final months = [
      'J',
      'F',
      'M',
      'A',
      'M',
      'J',
      'J',
      'A',
      'S',
      'O',
      'N',
      'D',
    ];

    return Container(
      height: 180,
      padding:
      const EdgeInsets.all(16),
      decoration:
      BoxDecoration(
        color:
        AppColors.surface,
        borderRadius:
        AppRadius.radiusLG,
        border:
        Border.all(
          color:
          AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revenue',
                    style:
                    AppTextStyles.titleMedium.copyWith(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  Text(
                    '2024 Overview',
                    style:
                    AppTextStyles.labelMedium.copyWith(
                      color:
                      AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Text(
                '1M',
                style:
                AppTextStyles.labelMedium.copyWith(
                  color:
                  AppColors.textSecondary,
                ),
              ),

              const SizedBox(
                width: 18,
              ),

              Text(
                '3M',
                style:
                AppTextStyles.labelMedium.copyWith(
                  color:
                  AppColors.textSecondary,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration:
                BoxDecoration(
                  color:
                  AppColors.primary,
                  borderRadius:
                  BorderRadius.circular(
                    8,
                  ),
                ),
                child:
                const Text(
                  '1Y',
                  style:
                  TextStyle(
                    color:
                    Colors.black,
                    fontSize:
                    10,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          SizedBox(
            height: 58,
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children:
              List.generate(
                values.length,
                    (index) {
                  return Expanded(
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 2,
                      ),
                      child:
                      FractionallySizedBox(
                        heightFactor:
                        values[index],
                        alignment:
                        Alignment.bottomCenter,
                        child:
                        Container(
                          decoration:
                          BoxDecoration(
                            color:
                            index >= 9
                                ? AppColors
                                .primary
                                : AppColors
                                .border,
                            borderRadius:
                            const BorderRadius
                                .vertical(
                              top:
                              Radius.circular(
                                4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Row(
            children:
            List.generate(
              months.length,
                  (index) {
                return Expanded(
                  child: Text(
                    months[index],
                    textAlign:
                    TextAlign.center,
                    style:
                    const TextStyle(
                      fontSize: 7,
                      color:
                      AppColors
                          .textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// MANAGEMENT GRID
// ------------------------------------------------------------

class _ManagementGrid
    extends StatelessWidget {
  const _ManagementGrid();

  @override
  Widget build(
      BuildContext context,
      ) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics:
      const NeverScrollableScrollPhysics(),
      children: [
        _ManagementCard(
          icon:
          Icons.groups_rounded,
          title:
          'Members',
          subtitle:
          'Manage gym members',
          onTap: () {
            context.push(
              AppRoutes
                  .memberManagement,
            );
          },
        ),

        _ManagementCard(
          icon: Icons.directions_run_rounded,
          title: 'Trainers',
          subtitle: 'Manage trainers',
          onTap: () {
            context.push(
              AppRoutes.ownerTrainerManagement,
            );
          },
        ),

        _ManagementCard(
          icon:
          Icons.fitness_center_rounded,
          title:
          'Gym Management',
          subtitle:
          'Gym profile & details',
          onTap: () {
            context.push(
              AppRoutes
                  .ownerGymManagement,
            );
          },
        ),

        _ManagementCard(
          icon:
          Icons.card_membership_rounded,
          title:
          'Membership Plans',
          subtitle:
          'Plans & pricing',
          onTap: () {
            context.push(
              AppRoutes
                  .ownerMembershipPlans,
            );
          },
        ),
      ],
    );
  }
}

// ------------------------------------------------------------
// MANAGEMENT CARD
// ------------------------------------------------------------

class _ManagementCard
    extends StatelessWidget {
  const _ManagementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Material(
      color:
      Colors.transparent,
      borderRadius:
      AppRadius.radiusLG,
      child: InkWell(
        onTap:
        onTap,
        borderRadius:
        AppRadius.radiusLG,
        child: Ink(
          padding:
          const EdgeInsets.all(20),
          decoration:
          BoxDecoration(
            color:
            AppColors.surface,
            borderRadius:
            AppRadius.radiusLG,
            border:
            Border.all(
              color:
              AppColors.border,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color:
                AppColors.primary,
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      AppTextStyles.bodyMedium.copyWith(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 2,
                    ),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      AppTextStyles.labelMedium.copyWith(
                        color:
                        AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 4,
              ),

              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color:
                AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// RECENT ACTIVITY
// ------------------------------------------------------------

class _RecentActivityList
    extends StatelessWidget {
  const _RecentActivityList();

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      children: const [
        _ActivityItem(
          icon:
          Icons.person_add_alt_1_rounded,
          title:
          'New member joined: Maria Santos',
          time:
          '2 min ago',
        ),

        SizedBox(
          height: 8,
        ),

        _ActivityItem(
          icon:
          Icons.calendar_month_rounded,
          title:
          'Trainer Mike added session',
          time:
          '15 min ago',
        ),

        SizedBox(
          height: 8,
        ),

        _ActivityItem(
          icon:
          Icons.credit_card_rounded,
          title:
          'Payment received ₹2,800',
          time:
          '1 hr ago',
        ),

        SizedBox(
          height: 8,
        ),

        _ActivityItem(
          icon:
          Icons.warning_amber_rounded,
          title:
          'Membership expired: 3 users',
          time:
          '3 hr ago',
        ),
      ],
    );
  }
}

class _ActivityItem
    extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.time,
  });

  final IconData icon;
  final String title;
  final String time;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration:
      BoxDecoration(
        color:
        AppColors.surface,
        borderRadius:
        AppRadius.radiusMD,
        border:
        Border.all(
          color:
          AppColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color:
            AppColors.primary,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style:
              AppTextStyles.bodySmall.copyWith(
                fontWeight:
                FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Text(
            time,
            style:
            AppTextStyles.labelMedium.copyWith(
              color:
              AppColors.textSecondary,
              fontSize: 9,
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
  Widget build(
      BuildContext context,
      ) {
    return Text(
      title,
      style:
      AppTextStyles.labelMedium.copyWith(
        color:
        AppColors.textSecondary,
        fontWeight:
        FontWeight.w600,
        letterSpacing:
        0.8,
      ),
    );
  }
}