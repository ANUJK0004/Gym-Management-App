import '../../domain/entities/owner_dashboard_stats.dart';
import '../../domain/repositories/owner_dashboard_repository.dart';

import '../datasources/owner_dashboard_remote_datasource.dart';

class OwnerDashboardRepositoryImpl
    implements OwnerDashboardRepository {
  OwnerDashboardRepositoryImpl(
      this._dataSource,
      );

  final OwnerDashboardRemoteDataSource _dataSource;

  @override
  Future<OwnerDashboardStats> getDashboardStats({
    required String gymId,
  }) {
    return _dataSource.getDashboardStats(
      gymId: gymId,
    );
  }
}