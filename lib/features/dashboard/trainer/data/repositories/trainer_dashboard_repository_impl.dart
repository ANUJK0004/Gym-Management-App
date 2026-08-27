import '../../domain/entities/trainer_dashboard_data.dart';
import '../../domain/repositories/trainer_dashboard_repository.dart';
import '../datasources/trainer_dashboard_remote_datasource.dart';

class TrainerDashboardRepositoryImpl implements TrainerDashboardRepository {
  const TrainerDashboardRepositoryImpl(this._dataSource);

  final TrainerDashboardRemoteDataSource _dataSource;

  @override
  Future<TrainerDashboardData> getDashboard({
    required String trainerId,
  }) async {
    return _dataSource.getDashboard(trainerId: trainerId);
  }
}
