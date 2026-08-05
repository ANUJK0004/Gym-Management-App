import '../../domain/entities/owner_dashboard_data.dart';
import '../../domain/repositories/owner_dashboard_repository.dart';

import '../datasources/owner_dashboard_remote_datasource.dart';

class OwnerDashboardRepositoryImpl
    implements OwnerDashboardRepository {
  OwnerDashboardRepositoryImpl(
      this._remoteDatasource,
      );

  final OwnerDashboardRemoteDataSource
  _remoteDatasource;

  @override
  Future<OwnerDashboardData> getDashboard({
    required String ownerId,
  }) {
    return _remoteDatasource.getDashboard(
      ownerId: ownerId,
    );
  }
}