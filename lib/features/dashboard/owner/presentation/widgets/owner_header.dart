import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/owner_dashboard_data.dart';
import '../providers/owner_notifications_provider.dart';
import 'owner_notification_sheet.dart';

class OwnerHeader extends ConsumerWidget {
  const OwnerHeader({
    super.key,
    required this.dashboard,
  });

  final OwnerDashboardData dashboard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(ownerUnreadNotificationCountProvider);

    return Row(
      children: [
        // ------------------------------------------------
        // GYM & OWNER INFO
        // ------------------------------------------------
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ADMIN CONSOLE',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                dashboard.gymName.isNotEmpty ? dashboard.gymName : 'My Gym',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Welcome, ${dashboard.ownerName.isNotEmpty ? dashboard.ownerName : 'Owner'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // ------------------------------------------------
        // NOTIFICATIONS BUTTON (WITH BADGE)
        // ------------------------------------------------
        Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: AppColors.surface,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () {
                  OwnerNotificationSheet.show(context);
                },
                customBorder: const CircleBorder(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.border,
                      width: 0.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    size: 21,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.owner,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 10),

        // ------------------------------------------------
        // OWNER PROFILE AVATAR BUTTON
        // ------------------------------------------------
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () {
              context.push(AppRoutes.ownerGymManagement);
            },
            customBorder: const CircleBorder(),
            child: dashboard.ownerPhotoUrl != null &&
                    dashboard.ownerPhotoUrl!.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.owner.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        dashboard.ownerPhotoUrl!,
                      ),
                    ),
                  )
                : Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.owner,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.owner.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getInitials(dashboard.ownerName),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'O';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
