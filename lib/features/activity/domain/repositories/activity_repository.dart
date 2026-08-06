import '../entities/activity_log.dart';

abstract class ActivityRepository {
  Future<List<ActivityLog>> getRecentActivities({
    required String gymId,
    int limit = 20,
  });

  Future<void> createActivity(
      ActivityLog activity,
      );
}