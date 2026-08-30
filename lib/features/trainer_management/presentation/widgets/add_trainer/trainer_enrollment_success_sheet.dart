import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

import '../../../domain/entities/trainer_enrollment.dart';

class TrainerEnrollmentSuccessSheet
    extends StatefulWidget {
  const TrainerEnrollmentSuccessSheet({
    super.key,
    required this.enrollment,
  });

  final TrainerEnrollment enrollment;

  @override
  State<TrainerEnrollmentSuccessSheet>
  createState() =>
      _TrainerEnrollmentSuccessSheetState();
}

class _TrainerEnrollmentSuccessSheetState
    extends State<TrainerEnrollmentSuccessSheet> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      const Duration(seconds: 3),
          () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enrollment =
        widget.enrollment;

    final invitation =
        enrollment.requiresInvitation;

    return SafeArea(
      top: false,
      child: Container(
        padding:
        const EdgeInsets.fromLTRB(
          24,
          28,
          24,
          24,
        ),
        decoration:
        const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
          BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration:
              BoxDecoration(
                color:
                AppColors.owner.withValues(alpha: 0.18),
                borderRadius:
                BorderRadius.circular(
                  20,
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 40,
                color:
                AppColors.owner,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              invitation
                  ? 'Trainer Enrollment Created!'
                  : 'Trainer Added!',
              textAlign:
              TextAlign.center,
              style: AppTextStyles
                  .headlineMedium
                  .copyWith(
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 9,
            ),

            Text(
              invitation
                  ? '${enrollment.displayName} has been added to your gym team. '
                  'An account invitation is required.'
                  : '${enrollment.displayName} has been added to your gym team.',
              textAlign:
              TextAlign.center,
              style: AppTextStyles
                  .bodyMedium
                  .copyWith(
                color:
                AppColors.textSecondary,
                height: 1.4,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(
                14,
              ),
              decoration:
              BoxDecoration(
                color:
                AppColors.background,
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
                children: [
                  _row(
                    'Trainer',
                    enrollment
                        .displayName,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  _row(
                    'Email',
                    enrollment.email,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  _row(
                    'Specialization',
                    enrollment
                        .specialization ??
                        'Not specified',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
      String label,
      String value,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color:
              AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign:
            TextAlign.right,
            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              color:
              AppColors.textPrimary,
              fontSize: 10,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}