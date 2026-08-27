import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/trainer_dashboard_data.dart';
import '../providers/trainer_notifications_provider.dart';
import '../providers/trainer_shell_provider.dart';
import 'trainer_notification_sheet.dart';

class TrainerHeader extends ConsumerWidget {
  const TrainerHeader({
    super.key,
    required this.dashboard,
  });

  final TrainerDashboardData dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(trainerUnreadNotificationCountProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ------------------------------------------------
        // TRAINER TITLE & SUBTITLE
        // ------------------------------------------------
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TRAINER PORTAL',
                style: AppTextStyles.labelMedium.copyWith(
                  color: const Color(0xFF8E9DAE),
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                dashboard.trainerName.isNotEmpty
                    ? dashboard.trainerName
                    : 'Coach Mike',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // ------------------------------------------------
        // NOTIFICATIONS BUTTON
        // ------------------------------------------------
        Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: const Color(0xFF181C26),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () {
                  TrainerNotificationSheet.show(context);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF181C26),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF2A3040),
                      width: 0.8,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.notifications_rounded,
                    size: 22,
                    color: Color(0xFFFBBF24), // Amber bell
                  ),
                ),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF38BDF8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 10),

        // ------------------------------------------------
        // TRAINER AVATAR (MT)
        // ------------------------------------------------
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () {
              ref.read(trainerNavIndexProvider.notifier).setIndex(3);
            },
            customBorder: const CircleBorder(),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFF38BDF8), // Cyan circle
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                dashboard.initials.isNotEmpty ? dashboard.initials : 'MT',
                style: const TextStyle(
                  color: Color(0xFF0B132B),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
