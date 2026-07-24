import '../../domain/entities/member_dashboard.dart';
import '../../domain/repositories/member_dashboard_repository.dart';
import '../datasources/member_dashboard_remote_datasource.dart';

class MemberDashboardRepositoryImpl
    implements MemberDashboardRepository {
  MemberDashboardRepositoryImpl(
      this._dataSource,
      );

  final MemberDashboardRemoteDataSource _dataSource;

  @override
  Future<MemberDashboard> getMemberDashboard(
      String uid,
      ) {
    return _dataSource.getMemberDashboard(uid);
  }
}