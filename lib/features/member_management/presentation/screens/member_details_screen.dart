import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/app/routes/app_routes.dart';
import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';
import 'package:sweatsync/design_system/appbar/app_back_button.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gym/presentation/providers/gym_provider.dart';

import '../../../membership_plan/domain/entities/membership_plan.dart';
import '../../domain/entities/managed_member.dart';
import '../providers/member_management_provider.dart';
import '../widgets/member_status_chip.dart';

import '../../../membership_plan/presentation/providers/membership_plan_provider.dart';

class MemberDetailsScreen
    extends ConsumerWidget {
  const MemberDetailsScreen({
    super.key,
    required this.memberId,
  });

  final String memberId;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final memberAsync =
    ref.watch(
      memberDetailsProvider(
        memberId,
      ),
    );

    final ownerGymAsync =
    ref.watch(
      ownerGymProvider,
    );

    final plansAsync =
    ref.watch(
      ownerMembershipPlansProvider,
    );

    final controllerState =
    ref.watch(
      memberManagementControllerProvider,
    );

    final isBusy =
        controllerState.isLoading;

    return Scaffold(
      backgroundColor:
      AppColors.background,

      appBar: AppBar(
        leadingWidth: 56,
        leading: const Center(
          child: AppBackButton(
            fallbackRoute: AppRoutes.memberManagement,
          ),
        ),
        title: const Text(
          'Member Details',
        ),
        backgroundColor:
        AppColors.background,
      ),

      body: memberAsync.when(
        loading: () =>
        const Center(
          child:
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.owner),
          ),
        ),

        error: (
            error,
            stackTrace,
            ) =>
            Center(
              child: Padding(
                padding:
                const EdgeInsets.all(24),
                child: Text(
                  'Unable to load member.\n$error',
                  textAlign:
                  TextAlign.center,
                ),
              ),
            ),

        data: (member) {
          if (member == null) {
            return const Center(
              child: Text(
                'Member not found.',
              ),
            );
          }

          final name =
          member.displayName
              ?.trim()
              .isNotEmpty ==
              true
              ? member.displayName!
              : 'Unnamed Member';

          final ownerGym =
              ownerGymAsync.value;

          final belongsToOwnerGym =
              ownerGym != null &&
                  member.gymId ==
                      ownerGym.id;

          MembershipPlan?
          currentPlan;

          final availablePlans =
              plansAsync.value
                  ?.where(
                    (plan) =>
                plan.isActive,
              )
                  .toList() ??
                  [];

          final allPlans =
              plansAsync.value ?? [];

          if (member.membershipPlanId !=
              null) {
            for (final plan in allPlans) {
              if (plan.id ==
                  member.membershipPlanId) {
                currentPlan = plan;
                break;
              }
            }
          }

          return SingleChildScrollView(
            padding:
            const EdgeInsets.fromLTRB(
              22,
              22,
              22,
              40,
            ),
            child: Column(
              children: [
                // ------------------------------------------------
                // MEMBER HEADER
                // ------------------------------------------------

                Container(
                  width:
                  double.infinity,
                  padding:
                  const EdgeInsets.all(24),
                  decoration:
                  BoxDecoration(
                    color:
                    AppColors.surface,
                    borderRadius:
                    AppRadius.radiusLG,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor:
                        AppColors.owner
                            .withValues(
                          alpha: 0.12,
                        ),
                        backgroundImage:
                        member.photoUrl !=
                            null &&
                            member.photoUrl!
                                .isNotEmpty
                            ? NetworkImage(
                          member.photoUrl!,
                        )
                            : null,
                        child:
                        member.photoUrl ==
                            null ||
                            member.photoUrl!
                                .isEmpty
                            ? const Icon(
                          Icons
                              .person_rounded,
                          size: 40,
                          color:
                          AppColors
                              .owner,
                        )
                            : null,
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Text(
                        name,
                        style:
                        AppTextStyles
                            .headlineMedium
                            .copyWith(
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        member.email,
                        style:
                        AppTextStyles
                            .bodyMedium
                            .copyWith(
                          color:
                          AppColors
                              .textSecondary,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      MemberStatusChip(
                        label: 'Membership',
                        selected:
                        member
                            .isMembershipActive,
                        onTap: () {},
                        status:
                        member
                            .effectiveMembershipStatus,
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // ------------------------------------------------
                // PERSONAL INFORMATION
                // ------------------------------------------------

                _SectionTitle(
                  title:
                  'PERSONAL INFORMATION',
                ),

                const SizedBox(
                  height: 10,
                ),

                _InfoTile(
                  icon:
                  Icons.email_outlined,
                  title: 'Email',
                  value:
                  member.email,
                ),

                _InfoTile(
                  icon:
                  Icons.phone_outlined,
                  title: 'Phone',
                  value:
                  member.phone ??
                      'Not provided',
                ),

                _InfoTile(
                  icon: Icons
                      .verified_user_outlined,
                  title: 'Profile',
                  value:
                  member.profileCompleted
                      ? 'Completed'
                      : 'Incomplete',
                ),

                const SizedBox(
                  height: 20,
                ),

                // ------------------------------------------------
                // MEMBERSHIP
                // ------------------------------------------------

                _SectionTitle(
                  title:
                  'MEMBERSHIP',
                ),

                const SizedBox(
                  height: 10,
                ),

                if (!member.isAssignedToGym)
                  _MembershipEmptyCard(
                    icon: Icons
                        .person_add_alt_1_rounded,
                    title:
                    'Member is not assigned',
                    message:
                    'Assign this member to your gym before assigning a membership plan.',
                  )
                else if (!belongsToOwnerGym)
                  _MembershipEmptyCard(
                    icon: Icons
                        .lock_outline_rounded,
                    title:
                    'Different gym',
                    message:
                    'This member is assigned to another gym.',
                  )
                else if (plansAsync.isLoading &&
                      plansAsync.value == null)
                    const Padding(
                      padding:
                      EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.owner),
                      ),
                    )
                  else if (plansAsync.hasError)
                      _MembershipEmptyCard(
                        icon: Icons
                            .error_outline_rounded,
                        title:
                        'Unable to load plans',
                        message:
                        'Membership plans could not be loaded.',
                      )
                    else if (!member.hasMembership)
                        _NoMembershipCard(
                          availablePlans:
                          availablePlans,
                          isBusy: isBusy,
                          onAssign:
                          availablePlans.isEmpty
                              ? null
                              : () =>
                              _selectMembershipPlan(
                                context,
                                ref,
                                availablePlans,
                              ),
                        )
                      else
                        _CurrentMembershipCard(
                          member: member,
                          plan: currentPlan,
                          isBusy: isBusy,
                          onChangePlan:
                          availablePlans.isEmpty
                              ? null
                              : () =>
                              _selectMembershipPlan(
                                context,
                                ref,
                                availablePlans,
                              ),
                          onRemovePlan:
                              () =>
                              _removeMembership(
                                context,
                                ref,
                              ),
                        ),

                const SizedBox(
                  height: 24,
                ),

                // ------------------------------------------------
                // GYM ACTION
                // ------------------------------------------------

                if (!belongsToOwnerGym &&
                    member.isAssignedToGym)
                  _MembershipEmptyCard(
                    icon:
                    Icons.info_outline_rounded,
                    title:
                    'Member cannot be managed',
                    message:
                    'This account is assigned to another gym.',
                  )
                else
                  SizedBox(
                    width:
                    double.infinity,
                    child:
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: member.isAssignedToGym ? Colors.red.shade800 : AppColors.owner,
                        foregroundColor: member.isAssignedToGym ? Colors.white : Colors.black,
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onPressed:
                      isBusy
                          ? null
                          : member
                          .isAssignedToGym
                          ? () =>
                          _removeMember(
                            context,
                            ref,
                          )
                          : () =>
                          _assignMember(
                            context,
                            ref,
                          ),
                      icon: Icon(
                        member.isAssignedToGym
                            ? Icons
                            .person_remove_rounded
                            : Icons
                            .person_add_rounded,
                      ),
                      label: Text(
                        member.isAssignedToGym
                            ? 'Remove From Gym'
                            : 'Assign To Gym',
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // ASSIGN MEMBER TO GYM
  // ==========================================================

  Future<void> _assignMember(
      BuildContext context,
      WidgetRef ref,
      ) async {
    final user =
        ref
            .read(
          firebaseAuthProvider,
        )
            .currentUser;

    if (user == null) {
      _showMessage(
        context,
        'You are not authenticated.',
      );
      return;
    }

    final gym =
    await ref
        .read(
      gymRepositoryProvider,
    )
        .getGymByOwnerId(
      user.uid,
    );

    if (!context.mounted) {
      return;
    }

    if (gym == null) {
      _showMessage(
        context,
        'Create your gym before assigning members.',
      );
      return;
    }

    await ref
        .read(
      memberManagementControllerProvider
          .notifier,
    )
        .assignMember(
      uid: memberId,
      gymId: gym.id,
    );

    if (!context.mounted) {
      return;
    }

    final state =
    ref.read(
      memberManagementControllerProvider,
    );

    if (state.hasError) {
      _showMessage(
        context,
        'Failed to assign member: '
            '${state.error}',
      );
      return;
    }

    _showMessage(
      context,
      'Member assigned successfully.',
    );
  }

  // ==========================================================
  // REMOVE MEMBER FROM GYM
  // ==========================================================

  Future<void> _removeMember(
      BuildContext context,
      WidgetRef ref,
      ) async {
    final confirmed =
    await _confirmAction(
      context,
      title:
      'Remove member?',
      message:
      'This will remove the member from your gym and clear their current membership.',
      confirmText:
      'Remove',
    );

    if (!confirmed) {
      return;
    }

    await ref
        .read(
      memberManagementControllerProvider
          .notifier,
    )
        .removeMember(
      uid: memberId,
    );

    if (!context.mounted) {
      return;
    }

    final state =
    ref.read(
      memberManagementControllerProvider,
    );

    if (state.hasError) {
      _showMessage(
        context,
        'Failed to remove member: '
            '${state.error}',
      );
      return;
    }

    _showMessage(
      context,
      'Member removed from gym.',
    );
  }

  // ==========================================================
  // SELECT MEMBERSHIP PLAN
  // ==========================================================

  Future<void> _selectMembershipPlan(
      BuildContext context,
      WidgetRef ref,
      List<MembershipPlan> plans,
      ) async {
    final selectedPlan =
    await showModalBottomSheet<
        MembershipPlan>(
      context: context,
      isScrollControlled:
      true,
      backgroundColor:
      AppColors.background,
      showDragHandle:
      true,
      builder: (_) {
        return _MembershipPlanPicker(
          plans: plans,
        );
      },
    );

    if (selectedPlan == null) {
      return;
    }

    await ref
        .read(
      memberManagementControllerProvider
          .notifier,
    )
        .assignMembershipPlan(
      uid: memberId,
      planId: selectedPlan.id,
    );

    if (!context.mounted) {
      return;
    }

    final state =
    ref.read(
      memberManagementControllerProvider,
    );

    if (state.hasError) {
      _showMessage(
        context,
        'Failed to assign membership: '
            '${state.error}',
      );
      return;
    }

    _showMessage(
      context,
      '${selectedPlan.name} assigned successfully.',
    );
  }

  // ==========================================================
  // REMOVE MEMBERSHIP
  // ==========================================================

  Future<void> _removeMembership(
      BuildContext context,
      WidgetRef ref,
      ) async {
    final confirmed =
    await _confirmAction(
      context,
      title:
      'Remove membership?',
      message:
      'The member will remain in your gym, but their current membership plan will be removed.',
      confirmText:
      'Remove',
    );

    if (!confirmed) {
      return;
    }

    await ref
        .read(
      memberManagementControllerProvider
          .notifier,
    )
        .removeMembershipPlan(
      uid: memberId,
    );

    if (!context.mounted) {
      return;
    }

    final state =
    ref.read(
      memberManagementControllerProvider,
    );

    if (state.hasError) {
      _showMessage(
        context,
        'Failed to remove membership: '
            '${state.error}',
      );
      return;
    }

    _showMessage(
      context,
      'Membership removed.',
    );
  }

  // ==========================================================
  // CONFIRMATION
  // ==========================================================

  Future<bool> _confirmAction(
      BuildContext context, {
        required String title,
        required String message,
        required String confirmText,
      }) async {
    final result =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content:
          Text(message),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                    dialogContext,
                    false,
                  ),
              child:
              const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                    dialogContext,
                    true,
                  ),
              child:
              Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _showMessage(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
        Text(message),
      ),
    );
  }
}

// ============================================================
// MEMBERSHIP PLAN PICKER
// ============================================================

class _MembershipPlanPicker
    extends StatelessWidget {
  const _MembershipPlanPicker({
    required this.plans,
  });

  final List<MembershipPlan> plans;

  @override
  Widget build(
      BuildContext context,
      ) {
    return SafeArea(
      child: Padding(
        padding:
        const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          24,
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Membership Plan',
              style:
              AppTextStyles
                  .headlineMedium
                  .copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'Select an active plan for this member.',
              style:
              AppTextStyles
                  .bodySmall
                  .copyWith(
                color:
                AppColors
                    .textSecondary,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount:
                plans.length,
                separatorBuilder:
                    (_, _) =>
                const SizedBox(
                  height: 10,
                ),
                itemBuilder:
                    (context, index) {
                  final plan =
                  plans[index];

                  return Material(
                    color:
                    AppColors.surface,
                    borderRadius:
                    AppRadius.radiusMD,
                    child: InkWell(
                      borderRadius:
                      AppRadius.radiusMD,
                      onTap: () =>
                          Navigator.pop(
                            context,
                            plan,
                          ),
                      child: Padding(
                        padding:
                        const EdgeInsets.all(
                          16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration:
                              BoxDecoration(
                                color: AppColors
                                    .owner
                                    .withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  12,
                                ),
                              ),
                              child:
                              const Icon(
                                Icons
                                    .card_membership_rounded,
                                color:
                                AppColors.owner,
                              ),
                            ),

                            const SizedBox(
                              width: 14,
                            ),

                            Expanded(
                              child:
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(
                                    plan.name,
                                    style:
                                    AppTextStyles
                                        .titleMedium
                                        .copyWith(
                                      fontWeight:
                                      FontWeight
                                          .w700,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    '${plan.durationInDays} days',
                                    style:
                                    AppTextStyles
                                        .bodySmall
                                        .copyWith(
                                      color:
                                      AppColors
                                          .textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Text(
                              '₹${plan.price.toStringAsFixed(0)}',
                              style:
                              AppTextStyles
                                  .titleMedium
                                  .copyWith(
                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CURRENT MEMBERSHIP CARD
// ============================================================

class _CurrentMembershipCard
    extends StatelessWidget {
  const _CurrentMembershipCard({
    required this.member,
    required this.plan,
    required this.isBusy,
    required this.onChangePlan,
    required this.onRemovePlan,
  });

  final ManagedMember member;
  final MembershipPlan? plan;
  final bool isBusy;

  final VoidCallback? onChangePlan;
  final VoidCallback onRemovePlan;

  @override
  Widget build(
      BuildContext context,
      ) {
    final status =
        member.effectiveMembershipStatus;

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(18),
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
              const Icon(
                Icons
                    .card_membership_rounded,
                color:
                AppColors.owner,
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Text(
                  'Current Membership',
                  style:
                  AppTextStyles
                      .titleMedium
                      .copyWith(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),

              MemberStatusChip(
                label:
                status
                    .toString()
                    .toUpperCase(),
                selected:
                member
                    .isMembershipActive,
                onTap: () {},
                status:
                status,
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          _MembershipValue(
            title: 'Plan',
            value:
            plan?.name ??
                'Plan unavailable',
          ),

          _MembershipValue(
            title: 'Price',
            value: plan == null
                ? '—'
                : '₹${plan!.price.toStringAsFixed(0)}',
          ),

          _MembershipValue(
            title: 'Duration',
            value: plan == null
                ? '—'
                : '${plan!.durationInDays} days',
          ),

          _MembershipValue(
            title: 'Started',
            value:
            _formatDate(
              member
                  .membershipStartedAt,
            ),
          ),

          _MembershipValue(
            title: 'Expires',
            value:
            _formatDate(
              member
                  .membershipExpiresAt,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child:
                OutlinedButton(
                  onPressed:
                  isBusy
                      ? null
                      : onChangePlan,
                  child:
                  const Text(
                    'Change Plan',
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                ElevatedButton(
                  onPressed:
                  isBusy
                      ? null
                      : onRemovePlan,
                  child:
                  const Text(
                    'Remove',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// NO MEMBERSHIP
// ============================================================

class _NoMembershipCard
    extends StatelessWidget {
  const _NoMembershipCard({
    required this.availablePlans,
    required this.isBusy,
    required this.onAssign,
  });

  final List<MembershipPlan>
  availablePlans;

  final bool isBusy;
  final VoidCallback? onAssign;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons
                .card_membership_outlined,
            color:
            AppColors.owner,
            size: 30,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            'No Membership',
            style:
            AppTextStyles
                .titleMedium
                .copyWith(
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            availablePlans.isEmpty
                ? 'Create an active membership plan before assigning one to this member.'
                : 'Assign an active membership plan to this member.',
            style:
            AppTextStyles
                .bodySmall
                .copyWith(
              color:
              AppColors
                  .textSecondary,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          SizedBox(
            width: double.infinity,
            child:
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.owner,
                foregroundColor: Colors.black,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed:
              isBusy
                  ? null
                  : onAssign,
              icon:
              const Icon(
                Icons.add,
              ),
              label:
              const Text(
                'Assign Membership',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY / WARNING CARD
// ============================================================

class _MembershipEmptyCard
    extends StatelessWidget {
  const _MembershipEmptyCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
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
      child: Column(
        children: [
          Icon(
            icon,
            size: 34,
            color:
            AppColors.textSecondary,
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            title,
            style:
            AppTextStyles
                .titleMedium
                .copyWith(
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            message,
            textAlign:
            TextAlign.center,
            style:
            AppTextStyles
                .bodySmall
                .copyWith(
              color:
              AppColors
                  .textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

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
    return Align(
      alignment:
      Alignment.centerLeft,
      child: Text(
        title,
        style:
        AppTextStyles.labelMedium
            .copyWith(
          color:
          AppColors
              .textSecondary,
          fontWeight:
          FontWeight.w700,
          letterSpacing:
          0.8,
        ),
      ),
    );
  }
}

// ============================================================
// MEMBERSHIP VALUE
// ============================================================

class _MembershipValue
    extends StatelessWidget {
  const _MembershipValue({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style:
              AppTextStyles
                  .labelMedium
                  .copyWith(
                color:
                AppColors
                    .textSecondary,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style:
              AppTextStyles
                  .bodyMedium
                  .copyWith(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFO TILE
// ============================================================

class _InfoTile
    extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
      const EdgeInsets.all(16),
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
            color:
            AppColors.owner,
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                  AppTextStyles
                      .labelMedium
                      .copyWith(
                    color:
                    AppColors
                        .textSecondary,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  value,
                  style:
                  AppTextStyles
                      .bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DATE FORMATTER
// ============================================================

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