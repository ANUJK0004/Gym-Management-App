import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/trainer_profile_provider.dart';
import '../widgets/trainer_account_section.dart';
import '../widgets/trainer_availability_section.dart';
import '../widgets/trainer_certifications_section.dart';
import '../widgets/trainer_monthly_metrics_card.dart';
import '../widgets/trainer_profile_identity.dart';
import '../widgets/trainer_profile_stats.dart';
import '../widgets/trainer_profile_top_bar.dart';
import '../widgets/trainer_sign_out_button.dart';
import '../widgets/trainer_specializations_section.dart';

class TrainerProfileScreen extends ConsumerWidget {
  const TrainerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(trainerProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14), // Dark sleek background
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Unable to load trainer profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF8E9DAE),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      ref
                          .read(trainerProfileControllerProvider.notifier)
                          .loadProfile();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: const Color(0xFF0B132B),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (profile) {
            return RefreshIndicator(
              color: const Color(0xFF38BDF8),
              backgroundColor: const Color(0xFF161922),
              onRefresh: () async {
                await ref
                    .read(trainerProfileControllerProvider.notifier)
                    .loadProfile();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          // ------------------------------------------------
                          // 1. TOP BAR (BACK BUTTON, TITLE, EDIT BUTTON)
                          // ------------------------------------------------
                          TrainerProfileTopBar(profile: profile),

                          const SizedBox(height: 20),

                          // ------------------------------------------------
                          // 2. AVATAR, NAME, DESIGNATION, EMAIL, RATINGS
                          // ------------------------------------------------
                          TrainerProfileIdentity(profile: profile),

                          const SizedBox(height: 22),

                          // ------------------------------------------------
                          // 3. 3-COLUMN METRICS (CLIENTS, EXPERIENCE, SESSIONS)
                          // ------------------------------------------------
                          TrainerProfileStats(profile: profile),

                          const SizedBox(height: 24),

                          // ------------------------------------------------
                          // 4. SPECIALIZATIONS SECTION
                          // ------------------------------------------------
                          TrainerSpecializationsSection(
                            specializations: profile.specializations,
                          ),

                          const SizedBox(height: 24),

                          // ------------------------------------------------
                          // 5. CERTIFICATIONS SECTION
                          // ------------------------------------------------
                          TrainerCertificationsSection(
                            certifications: profile.certifications,
                          ),

                          const SizedBox(height: 24),

                          // ------------------------------------------------
                          // 6. THIS MONTH SECTION (2x2 METRICS GRID)
                          // ------------------------------------------------
                          TrainerMonthlyMetricsCard(
                            metrics: profile.monthlyMetrics,
                          ),

                          const SizedBox(height: 24),

                          // ------------------------------------------------
                          // 7. AVAILABILITY SECTION
                          // ------------------------------------------------
                          TrainerAvailabilitySection(
                            availability: profile.availability,
                          ),

                          const SizedBox(height: 24),

                          // ------------------------------------------------
                          // 8. ACCOUNT SECTION
                          // ------------------------------------------------
                          TrainerAccountSection(
                            settings: profile.accountSettings,
                          ),

                          const SizedBox(height: 28),

                          // ------------------------------------------------
                          // 9. SIGN OUT BUTTON
                          // ------------------------------------------------
                          const TrainerSignOutButton(),

                          const SizedBox(height: 16),
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
