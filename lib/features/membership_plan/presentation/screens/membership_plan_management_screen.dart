import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

import '../../../gym/presentation/providers/gym_provider.dart';

import '../../domain/entities/membership_plan.dart';
import '../providers/membership_plan_provider.dart';
import '../widgets/membership_plan_card.dart';
import '../widgets/membership_plan_form.dart';

class MembershipPlanManagementScreen
    extends ConsumerWidget {
  const MembershipPlanManagementScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final gymAsync =
    ref.watch(ownerGymProvider);

    final plansAsync =
    ref.watch(
      ownerMembershipPlansProvider,
    );

    return Scaffold(
      backgroundColor:
      AppColors.background,

      appBar: AppBar(
        title:
        const Text(
          'Membership Plans',
        ),
        backgroundColor:
        AppColors.background,
      ),

      floatingActionButton:
      gymAsync.value != null
          ? FloatingActionButton(
        onPressed: () {
          _openPlanForm(
            context,
            gymAsync
                .value  !
                .id,
          );
        },
        backgroundColor:
        AppColors.primary,
        child:
        const Icon(
          Icons.add,
          color:
          AppColors
              .textInverse,
        ),
      )
          : null,

      body: gymAsync.when(
        loading: () {
          return const Center(
            child:
            CircularProgressIndicator(),
          );
        },

        error: (
            error,
            stackTrace,
            ) {
          return _ErrorView(
            message:
            'Unable to load gym.\n$error',
          );
        },

        data: (gym) {
          if (gym == null) {
            return const _NoGymView();
          }

          return plansAsync.when(
            loading: () {
              return const Center(
                child:
                CircularProgressIndicator(),
              );
            },

            error: (
                error,
                stackTrace,
                ) {
              return _ErrorView(
                message:
                'Unable to load membership plans.\n$error',
              );
            },

            data: (plans) {
              if (plans.isEmpty) {
                return _EmptyPlansView(
                  onCreatePlan: () {
                    _openPlanForm(
                      context,
                      gym.id,
                    );
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(
                    ownerMembershipPlansProvider,
                  );

                  await ref.read(
                    ownerMembershipPlansProvider
                        .future,
                  );
                },
                child: ListView(
                  padding:
                  const EdgeInsets
                      .fromLTRB(
                    22,
                    22,
                    22,
                    100,
                  ),
                  children: [
                    Text(
                      'MEMBERSHIP PLANS',
                      style:
                      AppTextStyles
                          .labelMedium
                          .copyWith(
                        color: AppColors
                            .textSecondary,
                        fontWeight:
                        FontWeight.w600,
                        letterSpacing:
                        0.8,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Create and manage the plans available to your gym members.',
                      style:
                      AppTextStyles
                          .bodySmall
                          .copyWith(
                        color: AppColors
                            .textSecondary,
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    ...plans.map(
                          (plan) {
                        return MembershipPlanCard(
                          plan: plan,
                          onEdit: () {
                            _openPlanForm(
                              context,
                              gym.id,
                              plan: plan,
                            );
                          },
                          onToggleStatus:
                              () {
                            ref
                                .read(
                              membershipPlanControllerProvider
                                  .notifier,
                            )
                                .togglePlanStatus(
                              plan,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openPlanForm(
      BuildContext context,
      String gymId, {
        MembershipPlan? plan,
      }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      AppColors.background,
      builder: (_) {
        return MembershipPlanForm(
          gymId: gymId,
          plan: plan,
        );
      },
    );
  }
}

class _EmptyPlansView
    extends StatelessWidget {
  const _EmptyPlansView({
    required this.onCreatePlan,
  });

  final VoidCallback onCreatePlan;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration:
              BoxDecoration(
                color: AppColors
                    .primary
                    .withOpacity(
                  0.12,
                ),
                borderRadius:
                BorderRadius
                    .circular(
                  22,
                ),
              ),
              child:
              const Icon(
                Icons
                    .card_membership_rounded,
                size: 40,
                color:
                AppColors.primary,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              'No Membership Plans',
              style:
              AppTextStyles
                  .headlineMedium
                  .copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Create your first membership plan so members can choose a subscription.',
              textAlign:
              TextAlign.center,
              style:
              AppTextStyles
                  .bodyMedium
                  .copyWith(
                color: AppColors
                    .textSecondary,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            ElevatedButton.icon(
              onPressed:
              onCreatePlan,
              icon:
              const Icon(
                Icons.add,
              ),
              label:
              const Text(
                'Create Plan',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoGymView
    extends StatelessWidget {
  const _NoGymView();

  @override
  Widget build(
      BuildContext context,
      ) {
    return const Center(
      child: Padding(
        padding:
        EdgeInsets.all(24),
        child: Text(
          'Please set up your gym before creating membership plans.',
          textAlign:
          TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorView
    extends StatelessWidget {
  const _ErrorView({
    required this.message,
  });

  final String message;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign:
          TextAlign.center,
        ),
      ),
    );
  }
}