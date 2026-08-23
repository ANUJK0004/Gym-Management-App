import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';

import '../../../../activity/presentation/providers/activity_provider.dart';
import '../../../../activity/presentation/widgets/recent_activity_list.dart';
import '../../../../gym/presentation/providers/gym_provider.dart';
import '../../domain/entities/owner_dashboard_data.dart';
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
    final dashboardAsync = ref.watch(
      ownerDashboardProvider,
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,

        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(ownerDashboardProvider);
            ref.invalidate(recentActivityProvider);
            ref.invalidate(ownerGymProvider);

            await Future.wait([
              ref.read(ownerDashboardProvider.future),
              ref.read(ownerGymProvider.future),
            ]);
          },

          child: dashboardAsync.when(
            loading: () {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },

            error: (error, stackTrace) {
              return ListView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height:
                    MediaQuery.of(context).size.height *
                        0.7,
                    child: Center(
                      child: Padding(
                        padding:
                        const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 60,
                              color: Colors.redAccent,
                            ),

                            const SizedBox(height: 16),

                            Text(
                              'Unable to load dashboard',
                              style: AppTextStyles
                                  .titleLarge
                                  .copyWith(
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              error.toString(),
                              textAlign:
                              TextAlign.center,
                              style: AppTextStyles
                                  .bodyMedium,
                            ),

                            const SizedBox(height: 20),

                            FilledButton.icon(
                              onPressed: () {
                                ref.invalidate(
                                  ownerDashboardProvider,
                                );
                              },
                              icon: const Icon(
                                Icons.refresh,
                              ),
                              label: const Text(
                                'Retry',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },

            data: (dashboard) {
              return CustomScrollView(
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

                    sliver: SliverList(
                      delegate:
                      SliverChildListDelegate(
                        [
                          _OwnerHeader(
                            dashboard: dashboard,
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          _StatsGrid(
                            dashboard: dashboard,
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          _RevenueCard(
                            dashboard: dashboard,
                          ),

                          const SizedBox(
                            height: 22,
                          ),

                          const _SectionTitle(
                            title: 'MANAGE',
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

                          const RecentActivityList(
                            maxItems: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

String getInitials(String name) {
  final parts = name
      .trim()
      .split(' ')
      .where(
        (e) => e.isNotEmpty,
  )
      .toList();

  if (parts.isEmpty) {
    return 'O';
  }

  if (parts.length == 1) {
    return parts.first[0].toUpperCase();
  }

  return '${parts.first[0]}${parts.last[0]}'
      .toUpperCase();
}
// ------------------------------------------------------------
// HEADER
// ------------------------------------------------------------

class _OwnerHeader extends StatelessWidget {
  const _OwnerHeader({
    required this.dashboard,
  });

  final OwnerDashboardData dashboard;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'ADMIN CONSOLE',
                style: AppTextStyles
                    .labelMedium
                    .copyWith(
                  color:
                  AppColors.textSecondary,
                  letterSpacing: 0.8,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                dashboard.gymName,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: AppTextStyles
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
                'Welcome, ${dashboard.ownerName}',
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
        ),

        const _HeaderIconButton(
          icon:
          Icons.notifications_none_rounded,
        ),

        const SizedBox(width: 10),

        if (dashboard.ownerPhotoUrl != null &&
            dashboard.ownerPhotoUrl!
                .isNotEmpty)
          CircleAvatar(
            radius: 21,
            backgroundImage:
            NetworkImage(
              dashboard.ownerPhotoUrl!,
            ),
          )
        else
          Container(
            width: 42,
            height: 42,
            decoration:
            const BoxDecoration(
              color:
              AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment:
            Alignment.center,
            child: Text(
              getInitials(
                dashboard.ownerName,
              ),
              style: AppTextStyles
                  .titleMedium
                  .copyWith(
                color: Colors.black,
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
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.border,
          width: .5,
        ),
      ),
      child: Icon(
        icon,
        size: 20,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ------------------------------------------------------------
// STATS
// ------------------------------------------------------------

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.dashboard,
  });

  final OwnerDashboardData dashboard;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.65,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          icon: Icons.groups_rounded,
          value: _formatNumber(
            dashboard.totalMembers,
          ),
          label: 'Total Members',
          change: '${dashboard.activeMembers} Active',
        ),

        _StatCard(
          icon: Icons.monetization_on_rounded,
          value:
          '₹${dashboard.monthlyRevenue.toStringAsFixed(0)}',
          label: 'Monthly Revenue',
          change: 'Live',
        ),

        _StatCard(
          icon: Icons.directions_run_rounded,
          value: dashboard.activeTrainers.toString(),
          label: 'Active Trainers',
          change: 'Working',
        ),

        _StatCard(
          icon: Icons.star_rounded,
          value:
          dashboard.newMembersThisMonth.toString(),
          label: 'New This Month',
          change: 'This Month',
        ),
      ],
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
  }
}

class _StatCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: AppColors.border,
          width: .5,
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
                color: AppColors.primary,
              ),

              const Spacer(),

              Text(
                change,
                style: AppTextStyles.labelMedium
                    .copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            value,
            style: AppTextStyles.titleLarge
                .copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: AppTextStyles.labelMedium
                .copyWith(
              color: AppColors.textSecondary,
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

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({
    required this.dashboard,
  });

  final OwnerDashboardData dashboard;

  @override
  Widget build(BuildContext context) {
    final trend = dashboard.monthlyRevenueTrend.length == 12
        ? dashboard.monthlyRevenueTrend
        : List.filled(12, 0.0);

    final maxRevenue = trend.reduce((a, b) => a > b ? a : b);
    final currentMonthIndex = DateTime.now().month - 1; // 0..11

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: AppColors.border,
          width: .5,
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
                    style: AppTextStyles.titleMedium
                        .copyWith(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  Text(
                    'Current Month',
                    style: AppTextStyles.labelMedium
                        .copyWith(
                      color: AppColors
                          .textSecondary,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Text(
                '₹${dashboard.monthlyRevenue.toStringAsFixed(0)}',
                style: AppTextStyles.titleMedium
                    .copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
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
              children: List.generate(
                months.length,
                    (index) {
                  final amount = trend[index];
                  final isCurrentMonth = index == currentMonthIndex;
                  final hasRevenue =
                      amount > 0 || (isCurrentMonth && dashboard.monthlyRevenue > 0);

                  double heightFactor;
                  if (maxRevenue > 0 && amount > 0) {
                    heightFactor = (amount / maxRevenue).clamp(0.12, 1.0);
                  } else if (isCurrentMonth && dashboard.monthlyRevenue > 0) {
                    heightFactor = 0.85;
                  } else {
                    heightFactor = 0.08;
                  }

                  return Expanded(
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 2,
                      ),
                      child:
                      FractionallySizedBox(
                        heightFactor: heightFactor,
                        alignment:
                        Alignment.bottomCenter,
                        child: Container(
                          decoration:
                          BoxDecoration(
                            color: hasRevenue
                                ? AppColors.primary
                                : AppColors.border,
                            borderRadius:
                            const BorderRadius
                                .vertical(
                              top: Radius.circular(
                                  4),
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

          const SizedBox(height: 4),

          Row(
            children: List.generate(
              months.length,
                  (index) {
                final isCurrentMonth = index == currentMonthIndex;
                return Expanded(
                  child: Text(
                    months[index],
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: isCurrentMonth
                          ? FontWeight.w700
                          : FontWeight.normal,
                      color: isCurrentMonth
                          ? AppColors.primary
                          : AppColors.textSecondary,
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

class _ManagementGrid extends StatelessWidget {
  const _ManagementGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _ManagementCard(
          icon: Icons.qr_code_scanner_rounded,
          title: 'Attendance',
          subtitle: 'Daily QR & Check-ins',
          onTap: () {
            context.push(
              AppRoutes.ownerAttendance,
            );
          },
        ),

        _ManagementCard(
          icon: Icons.groups_rounded,
          title: 'Members',
          subtitle: 'Manage gym members',
          onTap: () {
            context.push(
              AppRoutes.memberManagement,
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
          icon: Icons.workspace_premium_rounded,
          title: 'Membership Plans',
          subtitle: 'Plans & Pricing',
          onTap: () {
            context.push(
              AppRoutes.ownerMembershipPlans,
            );
          },
        ),

        _ManagementCard(
          icon: Icons.bar_chart_rounded,
          title: 'Reports',
          subtitle: 'Analytics & reports',
          onTap: () {
            context.push(
              AppRoutes.ownerReports,
            );
          },
        ),

        _ManagementCard(
          icon: Icons.fitness_center_rounded,
          title: 'Gym Profile',
          subtitle: 'Operating info & bio',
          onTap: () {
            context.push(
              AppRoutes.ownerGymManagement,
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

class _ManagementCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.radiusLG,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusLG,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.radiusLG,
            border: Border.all(
              color: AppColors.border,
              width: .5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: AppColors.primary,
              ),

              const SizedBox(width: 10),

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
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium
                          .copyWith(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMedium
                          .copyWith(
                        color:
                        AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ------------------------------------------------------------
// SECTION TITLE
// ------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.labelMedium.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: .8,
      ),
    );
  }
}