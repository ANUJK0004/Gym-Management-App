import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../activity/domain/entities/activity_log.dart';
import '../../../../activity/presentation/providers/activity_provider.dart';

class OwnerNotificationItem {
  const OwnerNotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    this.targetId,
    this.targetType,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime createdAt;
  final String? targetId;
  final String? targetType;
  final bool isRead;

  OwnerNotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    DateTime? createdAt,
    String? targetId,
    String? targetType,
    bool? isRead,
  }) {
    return OwnerNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      isRead: isRead ?? this.isRead,
    );
  }
}

class OwnerNotificationState {
  const OwnerNotificationState({
    this.readIds = const {},
    this.deletedIds = const {},
  });

  final Set<String> readIds;
  final Set<String> deletedIds;

  OwnerNotificationState copyWith({
    Set<String>? readIds,
    Set<String>? deletedIds,
  }) {
    return OwnerNotificationState(
      readIds: readIds ?? this.readIds,
      deletedIds: deletedIds ?? this.deletedIds,
    );
  }
}

class OwnerNotificationNotifier extends Notifier<OwnerNotificationState> {
  @override
  OwnerNotificationState build() {
    return const OwnerNotificationState();
  }

  void markAsRead(String id) {
    state = state.copyWith(
      readIds: {...state.readIds, id},
    );
  }

  void markAllAsRead(List<String> ids) {
    state = state.copyWith(
      readIds: {...state.readIds, ...ids},
    );
  }

  void deleteNotification(String id) {
    state = state.copyWith(
      deletedIds: {...state.deletedIds, id},
    );
  }

  void clearAll(List<String> ids) {
    state = state.copyWith(
      deletedIds: {...state.deletedIds, ...ids},
    );
  }
}

final ownerNotificationStateProvider =
    NotifierProvider<OwnerNotificationNotifier, OwnerNotificationState>(
  OwnerNotificationNotifier.new,
);

final ownerNotificationsListProvider =
    Provider.autoDispose<List<OwnerNotificationItem>>((ref) {
  final activityAsync = ref.watch(recentActivityProvider);
  final notifState = ref.watch(ownerNotificationStateProvider);

  final activities = activityAsync.value ?? <ActivityLog>[];

  final items = activities
      .where((a) => !notifState.deletedIds.contains(a.id))
      .map((a) {
    final isRead = notifState.readIds.contains(a.id);
    return OwnerNotificationItem(
      id: a.id,
      title: a.title.isNotEmpty ? a.title : a.description,
      description: a.description,
      type: a.type,
      createdAt: a.createdAt,
      targetId: a.targetId,
      targetType: a.targetType,
      isRead: isRead,
    );
  }).toList();

  return items;
});

final ownerUnreadNotificationCountProvider =
    Provider.autoDispose<int>((ref) {
  final items = ref.watch(ownerNotificationsListProvider);
  return items.where((i) => !i.isRead).length;
});
