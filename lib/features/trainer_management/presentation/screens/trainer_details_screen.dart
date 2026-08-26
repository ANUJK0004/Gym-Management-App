import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/app/routes/app_routes.dart';
import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';
import 'package:sweatsync/design_system/appbar/app_back_button.dart';

import '../providers/trainer_management_provider.dart';

class TrainerDetailsScreen
    extends ConsumerWidget {
  const TrainerDetailsScreen({
    super.key,
    required this.trainerUid,
  });

  final String trainerUid;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref
      ) {
    final trainerAsync =
    ref.watch(
      trainerDetailsProvider(
        trainerUid,
      ),
    );

    return Scaffold(
      backgroundColor:
      AppColors.background,

      appBar: AppBar(
        leadingWidth: 56,
        leading: const Center(
          child: AppBackButton(
            fallbackRoute: AppRoutes.ownerTrainerManagement,
          ),
        ),
        title:
        const Text(
          'Trainer Details',
        ),
        backgroundColor:
        AppColors.background,
      ),

      body:
      trainerAsync.when(
        loading: () =>
        const Center(
          child:
          CircularProgressIndicator(),
        ),

        error:
            (error, stackTrace) =>
            Center(
              child: Padding(
                padding:
                const EdgeInsets
                    .all(
                  24,
                ),
                child: Text(
                  'Unable to load trainer.\n$error',
                  textAlign:
                  TextAlign.center,
                ),
              ),
            ),

        data: (trainer) {
          if (trainer == null) {
            return const Center(
              child: Text(
                'Trainer not found.',
              ),
            );
          }

          return
            SingleChildScrollView(
              padding:
              const EdgeInsets
                  .all(
                22,
              ),
              child:
              Column(
                children: [
                  _ProfileHeader(
                    name:
                    trainer
                        .displayName,
                    photoUrl:
                    trainer
                        .photoUrl,
                    specialization:
                    trainer
                        .specialization,
                    status:
                    trainer.status,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  _InfoCard(
                    icon:
                    Icons.email_outlined,
                    label:
                    'Email',
                    value:
                    trainer.email,
                  ),

                  _InfoCard(
                    icon:
                    Icons.phone_outlined,
                    label:
                    'Phone',
                    value:
                    trainer.phone ??
                        'Not provided',
                  ),

                  _InfoCard(
                    icon:
                    Icons
                        .fitness_center_outlined,
                    label:
                    'Specialization',
                    value:
                    trainer.specialization ??
                        'Not provided',
                  ),

                  _InfoCard(
                    icon:
                    Icons
                        .workspace_premium_outlined,
                    label:
                    'Experience',
                    value: trainer
                        .experienceYears !=
                        null
                        ? '${trainer.experienceYears} years'
                        : 'Not provided',
                  ),

                  _InfoCard(
                    icon:
                    Icons
                        .calendar_today_outlined,
                    label:
                    'Joined',
                    value:
                    trainer.joinedAt !=
                        null
                        ? _formatDate(
                      trainer
                          .joinedAt!,
                    )
                        : 'Not available',
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  if (trainer.bio !=
                      null &&
                      trainer.bio!
                          .trim()
                          .isNotEmpty)
                    _BioCard(
                      bio:
                      trainer.bio!,
                    ),
                ],
              ),
            );
        },
      ),
    );
  }

  String _formatDate(
      DateTime date,
      ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

// ------------------------------------------------------------
// PROFILE HEADER
// ------------------------------------------------------------

class _ProfileHeader
    extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.photoUrl,
    required this.specialization,
    required this.status,
  });

  final String? name;
  final String? photoUrl;
  final String? specialization;
  final String status;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        22,
      ),
      decoration:
      BoxDecoration(
        color:
        AppColors.surface,
        borderRadius:
        AppRadius.radiusLG,
        border: Border.all(
          color:
          AppColors.border,
          width: 0.5,
        ),
      ),
      child:
      Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor:
            const Color(
              0xFF294725,
            ),
            backgroundImage:
            photoUrl != null &&
                photoUrl!
                    .isNotEmpty
                ? NetworkImage(
              photoUrl!,
            )
                : null,
            child: photoUrl ==
                null ||
                photoUrl!.isEmpty
                ? Text(
              _getInitials(
                name,
              ),
              style:
              const TextStyle(
                color:
                AppColors
                    .primary,
                fontWeight:
                FontWeight
                    .w800,
                fontSize:
                20,
              ),
            )
                : null,
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            name ??
                'Unnamed Trainer',
            style:
            AppTextStyles
                .headlineMedium
                .copyWith(
              fontWeight:
              FontWeight
                  .w800,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            specialization ??
                'Fitness Trainer',
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
            height: 10,
          ),

          Text(
            status
                .toUpperCase(),
            style:
            AppTextStyles
                .labelMedium
                .copyWith(
              color:
              status.toLowerCase() ==
                  'active'
                  ? AppColors
                  .primary
                  : AppColors
                  .textSecondary,
              fontWeight:
              FontWeight
                  .w700,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(
      String? name,
      ) {
    if (name == null ||
        name.trim().isEmpty) {
      return '?';
    }

    final parts =
    name.trim().split(
      RegExp(r'\s+'),
    );

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
// INFO CARD
// ------------------------------------------------------------

class _InfoCard
    extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width:
      double.infinity,
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
        border: Border.all(
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
                  label,
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

// ------------------------------------------------------------
// BIO
// ------------------------------------------------------------

class _BioCard
    extends StatelessWidget {
  const _BioCard({
    required this.bio,
  });

  final String bio;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width:
      double.infinity,
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
        border: Border.all(
          color:
          AppColors.border,
          width: 0.5,
        ),
      ),
      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,
        children: [
          Text(
            'ABOUT',
            style:
            AppTextStyles
                .labelMedium
                .copyWith(
              color:
              AppColors
                  .textSecondary,
              fontWeight:
              FontWeight
                  .w600,
              letterSpacing:
              0.8,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            bio,
            style:
            AppTextStyles
                .bodyMedium,
          ),
        ],
      ),
    );
  }
}