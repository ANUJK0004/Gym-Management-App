import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_text_styles.dart';
import '../providers/trainer_dashboard_provider.dart';
import '../providers/trainer_shell_provider.dart';
import '../widgets/trainer_client_card.dart';
import '../widgets/trainer_header.dart';
import '../widgets/trainer_next_session_card.dart';
import '../widgets/trainer_schedule_card.dart';

class TrainerHomeScreen extends ConsumerWidget {
  const TrainerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(trainerDashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      body: SafeArea(
        child: dashboardAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 54,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load trainer portal',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      ref.invalidate(trainerDashboardProvider);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: const Color(0xFF0B132B),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'Retry',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          data: (dashboard) {
            return RefreshIndicator(
              color: const Color(0xFF38BDF8),
              backgroundColor: const Color(0xFF161922),
              onRefresh: () async {
                ref.invalidate(trainerDashboardProvider);
                await ref.read(trainerDashboardProvider.future);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          // ------------------------------------------------
                          // HEADER (PORTAL TITLE, COACH NAME, ACTIONS)
                          // ------------------------------------------------
                          TrainerHeader(dashboard: dashboard),

                          const SizedBox(height: 18),

                          // ------------------------------------------------
                          // TODAY'S SCHEDULE CARD
                          // ------------------------------------------------
                          TrainerScheduleCard(
                            dashboard: dashboard,
                            onViewSchedule: () {
                              ref
                                  .read(trainerNavIndexProvider.notifier)
                                  .setIndex(1);
                            },
                          ),

                          const SizedBox(height: 22),

                          // ------------------------------------------------
                          // NEXT SESSION SECTION
                          // ------------------------------------------------
                          const Text(
                            'NEXT SESSION',
                            style: TextStyle(
                              color: Color(0xFF8E9DAE),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),

                          const SizedBox(height: 10),

                          TrainerNextSessionCard(
                            session: dashboard.nextSession,
                            onStart: () {
                              if (dashboard.nextSession != null) {
                                _showStartSessionDialog(
                                  context,
                                  ref,
                                  dashboard.nextSession!.id,
                                  dashboard.nextSession!.clientName,
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 22),

                          // ------------------------------------------------
                          // MY CLIENTS HEADER
                          // ------------------------------------------------
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'MY CLIENTS',
                                style: TextStyle(
                                  color: Color(0xFF8E9DAE),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(trainerNavIndexProvider.notifier)
                                      .setIndex(2);
                                },
                                child: const Text(
                                  'See all',
                                  style: TextStyle(
                                    color: Color(0xFF38BDF8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // ------------------------------------------------
                          // MY CLIENTS LIST
                          // ------------------------------------------------
                          ...dashboard.clients.map(
                            (client) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TrainerClientCard(
                                client: client,
                                onTap: () {
                                  ref
                                      .read(trainerNavIndexProvider.notifier)
                                      .setIndex(2);
                                },
                              ),
                            ),
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

  void _showStartSessionDialog(
    BuildContext context,
    WidgetRef ref,
    String sessionId,
    String clientName,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161922),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF262C3A), width: 0.8),
          ),
          title: const Row(
            children: [
              Text(
                '💪',
                style: TextStyle(fontSize: 22),
              ),
              SizedBox(width: 10),
              Text(
                'Start Session',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Ready to start the 45-minute HIIT Training session with $clientName?',
            style: const TextStyle(
              color: Color(0xFF8E9DAE),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF8E9DAE)),
              ),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref
                    .read(trainerDashboardControllerProvider.notifier)
                    .startSession(sessionId);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF38BDF8),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      content: Text(
                        'Session with $clientName started in Firestore! ⏱️',
                        style: const TextStyle(
                          color: Color(0xFF0B132B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF0B132B),
              ),
              child: const Text(
                'Start Workout',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }
}
