import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

import '../../../domain/entities/member_enrollment.dart';

class MemberEnrollmentSuccess extends StatefulWidget {
  const MemberEnrollmentSuccess({
    super.key,
    required this.enrollment,
    required this.onDone,
  });

  final MemberEnrollment enrollment;
  final VoidCallback onDone;

  @override
  State<MemberEnrollmentSuccess> createState() =>
      _MemberEnrollmentSuccessState();
}

class _MemberEnrollmentSuccessState
    extends State<MemberEnrollmentSuccess> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      const Duration(seconds: 3),
          () {
        if (mounted) {
          widget.onDone();
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
    final invitation =
        widget.enrollment.requiresInvitation;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          24,
          28,
          24,
          24,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
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
                color: AppColors.owner.withValues(alpha: 0.18),
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 40,
                color: AppColors.owner,
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
                  ? '${widget.enrollment.fullName} has been enrolled on the '
                  '${widget.enrollment.membershipPlanName} plan. '
                  'An account invitation is required.'
                  : '${widget.enrollment.fullName} has been enrolled on the '
                  '${widget.enrollment.membershipPlanName} plan.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}