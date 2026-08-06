import '../../domain/entities/activity_log.dart';
import '../../domain/repositories/activity_repository.dart';

import '../datasources/activity_remote_datasource.dart';

class ActivityRepositoryImpl
    implements ActivityRepository {
  ActivityRepositoryImpl(
      this._datasource,
      );

  final ActivityRemoteDataSource _datasource;

  @override
  Future<List<ActivityLog>>
  getRecentActivities({
    required String gymId,
    int limit = 20,
  }) {
    return _datasource.getRecentActivities(
      gymId: gymId,
      limit: limit,
    );
  }

  @override
  Future<void> createActivity(
      ActivityLog activity,
      ) {
    return _datasource.createActivity(
      activity,
    );
  }
}