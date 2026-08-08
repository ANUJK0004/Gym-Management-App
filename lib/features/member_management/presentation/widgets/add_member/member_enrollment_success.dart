import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

import '../../../domain/entities/member_enrollment.dart';

class MemberEnrollmentSuccess extends StatelessWidget {
  const MemberEnrollmentSuccess({
    super.key,
    required this.enrollment,
    required this.onDone,
  });

  final MemberEnrollment enrollment;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final invitation =
        enrollment.requiresInvitation;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          24,
          28,
          24,
          24,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
          const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color:
                const Color(0xFF294725),
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              invitation
                  ? 'Enrollment Created!'
                  : 'Member Added!',
              style: AppTextStyles.headlineMedium
                  .copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 9),

            Text(
              invitation
                  ? '${enrollment.fullName} has been enrolled on the '
                  '${enrollment.membershipPlanName} plan. '
                  'An account invitation is required.'
                  : '${enrollment.fullName} has been enrolled on the '
                  '${enrollment.membershipPlanName} plan.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  AppColors.primary,
                  foregroundColor: Colors.black,
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    AppRadius.radiusMD,
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}