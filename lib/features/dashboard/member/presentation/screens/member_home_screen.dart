import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweatsync/app/routes/app_routes.dart';
import 'package:sweatsync/features/dashboard/member/presentation/widgets/profile_summary_card.dart';

import '../providers/member_dashboard_provider.dart';
import '../widgets/body_metrics_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/membership_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/todays_workout_card.dart';
import '../widgets/weekly_progress_card.dart';

class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final dashboardAsync =
    ref.watch(memberDashboardProvider);

    return Scaffold(
      body: SafeArea(
        child: dashboardAsync.when(
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },

          error: (error, stackTrace) {
            return Center(
              child: Text(
                'Something went wrong.\n$error',
                textAlign: TextAlign.center,
              ),
            );
          },

          data: (dashboard) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(
                  memberDashboardProvider,
                );

                await ref.read(
                  memberDashboardProvider.future,
                );
              },

              child: CustomScrollView(
                physics:
                const AlwaysScrollableScrollPhysics(),

                slivers: [
                  SliverPadding(
                    padding:
                    const EdgeInsets.all(24),

                    sliver: SliverList(
                      delegate:
                      SliverChildListDelegate(
                        [
                          DashboardHeader(
                            name: dashboard.userName,
                            photoUrl:
                            dashboard.photoUrl,
                            onNotificationPressed: () {
                              // TODO:
                              // Open notifications.
                            },
                            onProfilePressed: () {
                              // TODO:
                              // Navigate to profile.
                            },
                          ),

                          const SizedBox(height: 20),

                          ProfileSummaryCard(
                            fitnessGoal: dashboard.fitnessGoal,
                            activityLevel: dashboard.activityLevel,
                            height: dashboard.height,
                            weight: dashboard.weight,
                            onEditProfile: () {
                              // TODO:
                              // Navigate to profile.
                            },
                          ),

                          const SizedBox(height: 28),

                          MembershipCard(
                            gymName:
                            dashboard.gymName,
                            status:
                            dashboard.membershipStatus,
                            expiryDate:
                            dashboard
                                .membershipExpiryDate,
                            onTap: () {
                              context.push(AppRoutes.membership);
                            },
                          ),

                          const SizedBox(height: 28),

                          TodaysWorkoutCard(
                            workoutName:
                            dashboard.workoutName,
                            description:
                            dashboard
                                .workoutDescription,
                            exerciseCount:
                            dashboard
                                .exerciseCount,
                            duration:
                            dashboard
                                .workoutDuration,
                            onStartWorkout: () {
                              // TODO:
                              // Navigate to workout.
                            },
                          ),

                          const SizedBox(height: 28),

                          WeeklyProgressCard(
                            completedWorkouts:
                            dashboard
                                .completedWorkouts,
                            totalWorkouts:
                            dashboard.totalWorkouts,
                          ),

                          const SizedBox(height: 28),

                          BodyMetricsCard(
                            currentWeight:
                            dashboard
                                .currentWeight,
                            previousWeight:
                            dashboard
                                .previousWeight,
                            onViewProgress: () {
                              // TODO:
                              // Navigate to progress.
                            },
                          ),

                          const SizedBox(height: 28),

                          QuickActions(
                            onWorkoutPressed: () {
                              // TODO
                            },
                            onProgressPressed: () {
                              // TODO
                            },
                            onMembershipPressed: () {
                              context.push(AppRoutes.membership);
                            },
                          ),

                          const SizedBox(height: 24),
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