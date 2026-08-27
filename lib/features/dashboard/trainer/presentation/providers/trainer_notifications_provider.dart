import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrainerNotification {
  const TrainerNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final bool isRead;
}

final trainerNotificationsProvider = Provider<List<TrainerNotification>>((ref) {
  return const [
    TrainerNotification(
      id: 'notif_1',
      title: 'Session Reminder',
      message: 'Sarah Chen has a HIIT training session starting in 35 minutes.',
      timeAgo: '5m ago',
      isRead: false,
    ),
    TrainerNotification(
      id: 'notif_2',
      title: 'Progress Milestone',
      message: 'Marcus King reached 58% of his Muscle Gain goal target.',
      timeAgo: '1h ago',
      isRead: false,
    ),
    TrainerNotification(
      id: 'notif_3',
      title: 'New Client Assigned',
      message: 'David Miller was assigned to you by Gym Admin.',
      timeAgo: '3h ago',
      isRead: true,
    ),
  ];
});

final trainerUnreadNotificationCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(trainerNotificationsProvider);
  return notifs.where((n) => !n.isRead).length;
});
