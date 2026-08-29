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

  @override
  Future<void> startSession({
    required String trainerId,
    required String sessionId,
  }) async {
    return _dataSource.startSession(
      trainerId: trainerId,
      sessionId: sessionId,
    );
  }

  @override
  Future<void> completeSession({
    required String trainerId,
    required String sessionId,
    String? clientId,
  }) async {
    return _dataSource.completeSession(
      trainerId: trainerId,
      sessionId: sessionId,
      clientId: clientId,
    );
  }

  @override
  Future<void> addSession({
    required String trainerId,
    required TrainerSession session,
  }) async {
    return _dataSource.addSession(
      trainerId: trainerId,
      session: session,
    );
  }

  @override
  Future<void> addClient({
    required String trainerId,
    required TrainerClientProgress client,
  }) async {
    return _dataSource.addClient(
      trainerId: trainerId,
      client: client,
    );
  }

  @override
  Future<void> updateClientProgress({
    required String trainerId,
    required String clientId,
    required int progressPercentage,
    int? sessionsCount,
  }) async {
    return _dataSource.updateClientProgress(
      trainerId: trainerId,
      clientId: clientId,
      progressPercentage: progressPercentage,
      sessionsCount: sessionsCount,
    );
  }
}
