import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweatsync/app/routes/app_routes.dart';
import 'package:sweatsync/features/dashboard/member/presentation/widgets/profile_summary_card.dart';

import '../../../../attendance/presentation/widgets/member_attendance_card.dart';
import '../../../../membership/presentation/providers/membership_provider.dart';
import '../../../../workout/presentation/providers/workout_provider.dart';

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

    final activeMembershipAsync =
    ref.watch(activeMembershipProvider);

    final todaysWorkoutAsync =
    ref.watch(todaysWorkoutProvider);

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

                ref.invalidate(
                  activeMembershipProvider,
                );

                ref.invalidate(
                  todaysWorkoutProvider,
                );

                await Future.wait([
                  ref.read(
                    memberDashboardProvider.future,
                  ),
                  ref.read(
                    activeMembershipProvider.future,
                  ),
                  ref.read(
                    todaysWorkoutProvider.future,
                  ),
                ]);
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
                          // --------------------------------
                          // DASHBOARD HEADER
                          // --------------------------------
                          DashboardHeader(
                            name:
                            dashboard.userName,
                            photoUrl:
                            dashboard.photoUrl,
                            onNotificationPressed: () {
                              _showNotificationsSheet(context, dashboard.userName);
                            },
                            onProfilePressed: () {
                              context.push(
                                AppRoutes.profile,
                              );
                            },
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          // --------------------------------
                          // PROFILE SUMMARY
                          // --------------------------------
                          ProfileSummaryCard(
                            fitnessGoal:
                            dashboard.fitnessGoal,
                            activityLevel:
                            dashboard.activityLevel,
                            height:
                            dashboard.height,
                            weight:
                            dashboard.weight,
                            onEditProfile: () {
                              context.push(
                                AppRoutes.profile,
                              );
                            },
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          // --------------------------------
                          // ACTIVE MEMBERSHIP
                          // --------------------------------
                          activeMembershipAsync.when(
                            loading: () {
                              return const SizedBox(
                                height: 120,
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
                              return MembershipCard(
                                gymName:
                                'Unable to load membership',
                                status:
                                'Error',
                                expiryDate:
                                null,
                                onTap: () {
                                  context.push(
                                    AppRoutes.membership,
                                  );
                                },
                              );
                            },

                            data: (
                                membership,
                                ) {
                              return MembershipCard(
                                gymName:
                                membership?.gymName ??
                                    'No active membership',
                                status:
                                membership?.status ??
                                    'Inactive',
                                expiryDate:
                                membership
                                    ?.expiryDate,
                                onTap: () {
                                  context.push(
                                    AppRoutes.membership,
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(
                            height: 24,
                          ),

                          // --------------------------------
                          // GYM ATTENDANCE
                          // --------------------------------
                          const MemberAttendanceCard(),

                          const SizedBox(
                            height: 28,
                          ),

                          // --------------------------------
                          // TODAY'S WORKOUT
                          // --------------------------------
                          todaysWorkoutAsync.when(
                            loading: () {
                              return const SizedBox(
                                height: 180,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },

                            error: (error, stackTrace) {
                              return TodaysWorkoutCard(
                                workoutName: 'Unable to load workout',
                                description: 'Please try again later.',
                                exerciseCount: 0,
                                duration: 0,
                                onStartWorkout: null,
                              );
                            },

                            data: (workout) {
                              if (workout == null) {
                                return TodaysWorkoutCard(
                                  workoutName: 'No workout today',
                                  description:
                                  'You have no workout assigned for today.',
                                  exerciseCount: 0,
                                  duration: 0,
                                  onStartWorkout: null,
                                );
                              }

                              return TodaysWorkoutCard(
                                workoutName: workout.name,
                                description: workout.description,
                                exerciseCount: workout.exerciseCount,
                                duration: workout.duration,
                                onStartWorkout: () {
                                  context.push(
                                    AppRoutes.workoutSession,
                                    extra: workout,
                                  );
                                },
                              );
                            },
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          // --------------------------------
                          // WEEKLY PROGRESS
                          // --------------------------------
                          WeeklyProgressCard(
                            completedWorkouts:
                            dashboard
                                .completedWorkouts,
                            totalWorkouts:
                            dashboard
                                .totalWorkouts,
                            weeklyActivity:
                            dashboard
                                .weeklyActivity,
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          // --------------------------------
                          // BODY METRICS
                          // --------------------------------
                          BodyMetricsCard(
                            currentWeight:
                            dashboard
                                .currentWeight,
                            previousWeight:
                            dashboard
                                .previousWeight,
                            monthlyWorkouts:
                            dashboard
                                .monthlyWorkouts,
                            workoutChange:
                            dashboard
                                .workoutChange,
                            onViewProgress: () {
                              context.push(AppRoutes.progress);
                            },
                          ),

                          const SizedBox(
                            height: 28,
                          ),

                          // --------------------------------
                          // QUICK ACTIONS
                          // --------------------------------
                          QuickActions(
                            onWorkoutPressed: () {
                              context.push(
                                AppRoutes.workout,
                              );
                            },
                            onProgressPressed: () {
                              context.push(
                                AppRoutes.progress,
                              );
                            },
                            onMembershipPressed: () {
                              context.push(
                                AppRoutes.membership,
                              );
                            },
                          ),

                          const SizedBox(
                            height: 24,
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

  void _showNotificationsSheet(BuildContext context, String userName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E2C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF28293D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.celebration_rounded,
                        color: Color(0xFF6C5CE7),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to SweatSync, $userName! 👋',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Check in with your Gym QR to track your daily attendance and start today\'s workout.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}