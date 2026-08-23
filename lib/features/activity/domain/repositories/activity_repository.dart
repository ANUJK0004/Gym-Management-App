import '../entities/activity_log.dart';

abstract class ActivityRepository {
  Stream<List<ActivityLog>> streamRecentActivities({
    required String gymId,
    int limit = 20,
  });

  Future<List<ActivityLog>> getRecentActivities({
    required String gymId,
    int limit = 20,
  });

  Future<void> createActivity(
      ActivityLog activity,
      );
}