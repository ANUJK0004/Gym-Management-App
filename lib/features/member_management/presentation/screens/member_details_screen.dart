import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gym/presentation/providers/gym_provider.dart';
import '../providers/member_management_provider.dart';
import '../widgets/member_status_chip.dart';

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

    return Scaffold(
      backgroundColor:
      AppColors.background,

      appBar: AppBar(
        title:
        const Text(
          'Member Details',
        ),
        backgroundColor:
        AppColors.background,
      ),

      body: memberAsync.when(
        loading: () =>
        const Center(
          child:
          CircularProgressIndicator(),
        ),

        error:
            (error, stackTrace) =>
            Center(
              child:
              Text(
                'Unable to load member.\n$error',
                textAlign:
                TextAlign.center,
              ),
            ),

        data:
            (member) {
          if (member == null) {
            return const Center(
              child:
              Text(
                'Member not found.',
              ),
            );
          }

          final name =
          member.displayName
              ?.trim()
              .isNotEmpty ==
              true
              ? member
              .displayName!
              : 'Unnamed Member';

          return SingleChildScrollView(
            padding:
            const EdgeInsets.all(
              22,
            ),
            child:
            Column(
              children: [
                Container(
                  width:
                  double.infinity,
                  padding:
                  const EdgeInsets.all(
                    24,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    AppColors.surface,
                    borderRadius:
                    AppRadius
                        .radiusLG,
                  ),
                  child:
                  Column(
                    children: [
                      CircleAvatar(
                        radius:
                        42,
                        backgroundColor:
                        AppColors
                            .primary
                            .withOpacity(
                          0.12,
                        ),
                        backgroundImage:
                        member.photoUrl !=
                            null
                            ? NetworkImage(
                          member
                              .photoUrl!,
                        )
                            : null,
                        child:
                        member.photoUrl ==
                            null
                            ? const Icon(
                          Icons
                              .person_rounded,
                          size:
                          40,
                          color:
                          AppColors.primary,
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
                          FontWeight
                              .w700,
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
                        label:
                        'Status',
                        selected:
                        false,
                        onTap:
                            () {},
                        status: member.membershipStatus,
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                _InfoTile(
                  icon:
                  Icons.email_outlined,
                  title:
                  'Email',
                  value:
                  member.email,
                ),

                _InfoTile(
                  icon:
                  Icons.phone_outlined,
                  title:
                  'Phone',
                  value:
                  member.phone ??
                      'Not provided',
                ),

                _InfoTile(
                  icon:
                  Icons
                      .verified_user_outlined,
                  title:
                  'Profile',
                  value:
                  member.profileCompleted
                      ? 'Completed'
                      : 'Incomplete',
                ),

                const SizedBox(
                  height: 24,
                ),

                SizedBox(
                  width:
                  double.infinity,
                  child:
                  ElevatedButton.icon(
                    onPressed:
                    member.isAssignedToGym
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
                    icon:
                    Icon(
                      member
                          .isAssignedToGym
                          ? Icons
                          .person_remove_rounded
                          : Icons
                          .person_add_rounded,
                    ),
                    label:
                    Text(
                      member
                          .isAssignedToGym
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
        'Failed to assign member: ${state.error}',
      );
      return;
    }

    _showMessage(
      context,
      'Member assigned successfully.',
    );
  }

  Future<void> _removeMember(
      BuildContext context,
      WidgetRef ref,
      ) async {
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
        'Failed to remove member: ${state.error}',
      );
      return;
    }

    _showMessage(
      context,
      'Member removed from gym.',
    );
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
      const EdgeInsets.all(
        16,
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
      child:
      Row(
        children: [
          Icon(
            icon,
            color:
            AppColors.primary,
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