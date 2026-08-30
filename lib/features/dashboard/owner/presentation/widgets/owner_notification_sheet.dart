import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../providers/owner_notifications_provider.dart';

class OwnerNotificationSheet extends ConsumerStatefulWidget {
  const OwnerNotificationSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.70),
      useSafeArea: true,
      builder: (context) => const OwnerNotificationSheet(),
    );
  }

  @override
  ConsumerState<OwnerNotificationSheet> createState() =>
      _OwnerNotificationSheetState();
}

class _OwnerNotificationSheetState
    extends ConsumerState<OwnerNotificationSheet> {
  String _selectedCategory = 'all'; // all, members, attendance, finance, plans

  @override
  Widget build(BuildContext context) {
    final allNotifications = ref.watch(ownerNotificationsListProvider);
    final unreadCount = ref.watch(ownerUnreadNotificationCountProvider);

    final filtered = _filterNotifications(allNotifications, _selectedCategory);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ------------------------------------------------
          // HANDLE
          // ------------------------------------------------
          const SizedBox(height: 12),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // ------------------------------------------------
          // HEADER
          // ------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Notifications',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.owner.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.owner.withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '$unreadCount new',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.owner,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (unreadCount > 0)
                  TextButton(
                    onPressed: () {
                      final ids = allNotifications.map((n) => n.id).toList();
                      ref
                          .read(ownerNotificationStateProvider.notifier)
                          .markAllAsRead(ids);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Mark all read',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.owner,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (allNotifications.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: () {
                      final ids = allNotifications.map((n) => n.id).toList();
                      ref
                          .read(ownerNotificationStateProvider.notifier)
                          .clearAll(ids);
                    },
                    icon: const Icon(
                      Icons.clear_all_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: 'Clear all',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ------------------------------------------------
          // CATEGORY FILTER CHIPS
          // ------------------------------------------------
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                _CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == 'all',
                  count: allNotifications.length,
                  onTap: () => setState(() => _selectedCategory = 'all'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Members',
                  isSelected: _selectedCategory == 'members',
                  count: _countCategory(allNotifications, 'members'),
                  onTap: () => setState(() => _selectedCategory = 'members'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Attendance',
                  isSelected: _selectedCategory == 'attendance',
                  count: _countCategory(allNotifications, 'attendance'),
                  onTap: () => setState(() => _selectedCategory = 'attendance'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Payments',
                  isSelected: _selectedCategory == 'finance',
                  count: _countCategory(allNotifications, 'finance'),
                  onTap: () => setState(() => _selectedCategory = 'finance'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Gym & Plans',
                  isSelected: _selectedCategory == 'plans',
                  count: _countCategory(allNotifications, 'plans'),
                  onTap: () => setState(() => _selectedCategory = 'plans'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),

          // ------------------------------------------------
          // NOTIFICATIONS LIST
          // ------------------------------------------------
          Expanded(
            child: filtered.isEmpty
                ? _EmptyNotificationsView(
                    isFiltered: _selectedCategory != 'all',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final notif = filtered[index];
                      return _NotificationTile(
                        item: notif,
                        onTap: () {
                          ref
                              .read(ownerNotificationStateProvider.notifier)
                              .markAsRead(notif.id);
                          _handleNotificationTap(context, notif);
                        },
                        onDismiss: () {
                          ref
                              .read(ownerNotificationStateProvider.notifier)
                              .deleteNotification(notif.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<OwnerNotificationItem> _filterNotifications(
    List<OwnerNotificationItem> items,
    String category,
  ) {
    if (category == 'all') return items;

    return items.where((item) {
      final t = item.type.toLowerCase();
      switch (category) {
        case 'members':
          return t.contains('member') || t.contains('trainer');
        case 'attendance':
          return t.contains('attendance');
        case 'finance':
          return t.contains('payment') || t.contains('membership');
        case 'plans':
          return t.contains('plan') || t.contains('gym') || t.contains('profile');
        default:
          return true;
      }
    }).toList();
  }

  int _countCategory(List<OwnerNotificationItem> items, String category) {
    return _filterNotifications(items, category).length;
  }

  void _handleNotificationTap(
    BuildContext context,
    OwnerNotificationItem notif,
  ) {
    final t = notif.type.toLowerCase();

    Navigator.of(context).pop();

    if (t.contains('attendance')) {
      context.push(AppRoutes.ownerAttendance);
    } else if (t.contains('member') && !t.contains('plan')) {
      if (notif.targetId != null && notif.targetId!.isNotEmpty) {
        context.push(AppRoutes.memberDetails, extra: notif.targetId);
      } else {
        context.push(AppRoutes.memberManagement);
      }
    } else if (t.contains('trainer')) {
      if (notif.targetId != null && notif.targetId!.isNotEmpty) {
        context.push(AppRoutes.trainerDetails, extra: notif.targetId);
      } else {
        context.push(AppRoutes.ownerTrainerManagement);
      }
    } else if (t.contains('plan')) {
      context.push(AppRoutes.ownerMembershipPlans);
    } else if (t.contains('gym') || t.contains('profile')) {
      context.push(AppRoutes.ownerGymManagement);
    } else if (t.contains('payment') || t.contains('finance')) {
      // Navigate to reports/finance
      context.push(AppRoutes.ownerReports);
    }
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.count,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.owner.withValues(alpha: 0.16)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.owner : AppColors.border,
              width: isSelected ? 1.0 : 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.owner
                      : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 5),
                Text(
                  '($count)',
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.owner
                        : AppColors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.onTap,
    required this.onDismiss,
  });

  final OwnerNotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor) = _getIconAndColor(item.type);
    final timeStr = _formatTimeAgo(item.createdAt);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: AppRadius.radiusMD,
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.error,
          size: 22,
        ),
      ),
      child: Material(
        color: item.isRead ? AppColors.surface : const Color(0xFF241D14),
        borderRadius: AppRadius.radiusMD,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.radiusMD,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.radiusMD,
              border: Border.all(
                color: item.isRead
                    ? AppColors.border
                    : AppColors.owner.withValues(alpha: 0.35),
                width: item.isRead ? 0.5 : 0.8,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 19,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: item.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!item.isRead) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.owner,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (item.description.isNotEmpty &&
                          item.description != item.title) ...[
                        const SizedBox(height: 3),
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeStr,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (IconData, Color) _getIconAndColor(String type) {
    switch (type) {
      case 'memberJoined':
      case 'memberAssigned':
      case 'memberEnrollmentCreated':
      case 'memberInvitationSent':
        return (Icons.person_add_alt_1_rounded, AppColors.owner);

      case 'memberRemoved':
        return (Icons.person_remove_rounded, AppColors.error);

      case 'trainerAdded':
      case 'trainerAssigned':
        return (Icons.directions_run_rounded, const Color(0xFF4A9EFF));

      case 'trainerRemoved':
        return (Icons.person_off_rounded, AppColors.error);

      case 'membershipPurchased':
      case 'membershipRenewed':
      case 'paymentReceived':
        return (Icons.payments_rounded, AppColors.owner);

      case 'paymentRefunded':
        return (Icons.money_off_rounded, AppColors.warning);

      case 'membershipPlanCreated':
      case 'membershipPlanUpdated':
      case 'membershipPlanActivated':
        return (Icons.workspace_premium_rounded, AppColors.premium);

      case 'membershipPlanDeleted':
      case 'membershipPlanDeactivated':
        return (Icons.remove_circle_outline_rounded, AppColors.textSecondary);

      case 'attendanceChecked':
        return (Icons.qr_code_scanner_rounded, AppColors.info);

      case 'workoutCreated':
      case 'workoutAssigned':
        return (Icons.fitness_center_rounded, AppColors.workout);

      case 'profileUpdated':
      case 'gymUpdated':
        return (Icons.edit_note_rounded, AppColors.textSecondary);

      default:
        return (Icons.notifications_active_rounded, AppColors.owner);
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative || difference.inSeconds < 45) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'min' : 'mins'} ago';
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hr' : 'hrs'} ago';
    }

    if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _EmptyNotificationsView extends StatelessWidget {
  const _EmptyNotificationsView({required this.isFiltered});

  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.owner.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.notifications_off_rounded,
                size: 32,
                color: AppColors.owner,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? 'No Matching Notifications' : 'All Caught Up!',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isFiltered
                  ? 'There are no notifications in this category.'
                  : 'You have no new gym alerts or activity notifications.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
