import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/app/routes/app_routes.dart';
import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';
import 'package:sweatsync/design_system/appbar/app_back_button.dart';

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

    final plansAsync = ref.watch(
      ownerMembershipPlansProvider,
    );

    return Scaffold(
      backgroundColor:
      AppColors.background,

      appBar: AppBar(
        leadingWidth: 56,
        leading: const Center(
          child: AppBackButton(
            fallbackRoute: AppRoutes.ownerHome,
          ),
        ),
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
        onPressed: () async {
          final result =
          await _openPlanForm(
            context,
            gymAsync.value!.id,
          );

          if (!context.mounted) {
            return;
          }

          _showFormResult(
            context,
            result,
          );
        },
        backgroundColor:
        AppColors.primary,
        child:
        const Icon(
          Icons.add,
          color:
          AppColors.textInverse,
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
                  onCreatePlan: () async {
                    final result =
                    await _openPlanForm(
                      context,
                      gym.id,
                    );

                    if (!context.mounted) {
                      return;
                    }

                    _showFormResult(
                      context,
                      result,
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
                  const EdgeInsets.fromLTRB(
                    22,
                    22,
                    22,
                    100,
                  ),
                  children: [
                    Text(
                      'MEMBERSHIP PLANS',
                      style: AppTextStyles
                          .labelMedium
                          .copyWith(
                        color: AppColors
                            .textSecondary,
                        fontWeight:
                        FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Create and manage the plans available to your gym members.',
                      style: AppTextStyles
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

                          onEdit: () async {
                            final result =
                            await _openPlanForm(
                              context,
                              gym.id,
                              plan: plan,
                            );

                            if (!context.mounted) {
                              return;
                            }

                            _showFormResult(
                              context,
                              result,
                              planName:
                              plan.name,
                            );
                          },

                          onToggleStatus:
                              () async {
                            await _togglePlan(
                              context,
                              ref,
                              gym.id,
                              plan,
                            );
                          },

                          onDelete: () async {
                            await _deletePlan(
                              context,
                              ref,
                              gym.id,
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

  Future<
      MembershipPlanActionResult?>
  _openPlanForm(
      BuildContext context,
      String gymId, {
        MembershipPlan? plan,
      }) {
    return showModalBottomSheet<
        MembershipPlanActionResult>(
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

  void _showFormResult(
      BuildContext context,
      MembershipPlanActionResult?
      result, {
        String? planName,
      }) {
    if (!context.mounted ||
        result == null) {
      return;
    }

    switch (result) {
      case MembershipPlanActionResult
          .created:
        _showSnackBar(
          context,
          'Membership plan created successfully.',
          seconds: 3,
        );
        break;

      case MembershipPlanActionResult
          .updated:
        _showSnackBar(
          context,
          'Changes saved for plan "${planName ?? 'plan'}".',
          seconds: 2,
        );
        break;

      case MembershipPlanActionResult
          .noChanges:
        break;

      case MembershipPlanActionResult
          .duplicate:
        _showSnackBar(
          context,
          'A plan with the same name, price and duration already exists.',
        );
        break;

      case MembershipPlanActionResult
          .failed:
        _showSnackBar(
          context,
          'Failed to save membership plan.',
        );
        break;

      default:
        break;
    }
  }

  Future<void> _togglePlan(
      BuildContext context,
      WidgetRef ref,
      String gymId,
      MembershipPlan plan,
      ) async {
    final result = await ref
        .read(
      membershipPlanControllerProvider
          .notifier,
    )
        .togglePlanStatus(
      plan: plan,
      gymId: gymId,
    );

    if (!context.mounted) {
      return;
    }

    switch (result) {
      case MembershipPlanActionResult
          .activated:
        _showSnackBar(
          context,
          'Plan "${plan.name}" activated.',
        );
        break;

      case MembershipPlanActionResult
          .deactivated:
        _showSnackBar(
          context,
          'Plan "${plan.name}" disabled for new members.',
        );
        break;

      default:
        _showSnackBar(
          context,
          'Failed to update plan "${plan.name}".',
        );
    }
  }

  Future<void> _deletePlan(
      BuildContext context,
      WidgetRef ref,
      String gymId,
      MembershipPlan plan,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title:
          const Text(
            'Delete Membership Plan?',
          ),
          content:
          Text(
            'Are you sure you want to delete "${plan.name}"?\n\n'
                'If members are currently using this plan, '
                'the plan will be disabled instead of deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child:
              const Text('Cancel'),
            ),
            FilledButton(
              style:
              FilledButton.styleFrom(
                backgroundColor:
                Colors.red,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child:
              const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !context.mounted) {
      return;
    }

    final result = await ref
        .read(
      membershipPlanControllerProvider
          .notifier,
    )
        .deletePlan(
      plan: plan,
      gymId: gymId,
    );

    if (!context.mounted) {
      return;
    }

    switch (result) {
      case MembershipPlanActionResult
          .deleted:
        _showSnackBar(
          context,
          'Plan "${plan.name}" deleted successfully.',
        );
        break;

      case MembershipPlanActionResult
          .disabledBecauseInUse:
        _showSnackBar(
          context,
          'Plan "${plan.name}" is being used by members, so it was disabled instead of deleted.',
        );
        break;

      default:
        _showSnackBar(
          context,
          'Failed to delete plan "${plan.name}".',
        );
    }
  }

  void _showSnackBar(
      BuildContext context,
      String message, {
        int seconds = 2,
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
          Text(message),
          duration:
          Duration(seconds: seconds),
        ),
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
                color: AppColors.primary
                    .withValues(alpha: 0.12),
                borderRadius:
                BorderRadius.circular(
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
              style: AppTextStyles
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
              style: AppTextStyles
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
              const Icon(Icons.add),
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
        child:
        Text(
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
        child:
        Text(
          message,
          textAlign:
          TextAlign.center,
        ),
      ),
    );
  }
}