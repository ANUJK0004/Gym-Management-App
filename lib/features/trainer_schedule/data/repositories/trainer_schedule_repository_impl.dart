import '../../domain/entities/trainer_schedule_session.dart';
import '../../domain/repositories/trainer_schedule_repository.dart';
import '../datasources/trainer_schedule_remote_datasource.dart';
import '../models/trainer_schedule_session_model.dart';

class TrainerScheduleRepositoryImpl implements TrainerScheduleRepository {
  const TrainerScheduleRepositoryImpl(this._remoteDataSource);

  final TrainerScheduleRemoteDataSource _remoteDataSource;

  @override
  Stream<List<TrainerScheduleSession>> watchSessions({
    required String trainerId,
  }) {
    return _remoteDataSource.watchSessions(trainerId: trainerId);
  }

  @override
  Future<List<TrainerScheduleSession>> getSessions({
    required String trainerId,
    DateTime? date,
  }) async {
    return _remoteDataSource.getSessions(trainerId: trainerId, date: date);
  }

  @override
  Future<TrainerScheduleSession> addSession({
    required String trainerId,
    required TrainerScheduleSession session,
  }) async {
    final model = TrainerScheduleSessionModel.fromDomain(session);
    return _remoteDataSource.addSession(trainerId: trainerId, session: model);
  }

  @override
  Future<void> updateSession({
    required String trainerId,
    required TrainerScheduleSession session,
  }) async {
    final model = TrainerScheduleSessionModel.fromDomain(session);
    return _remoteDataSource.updateSession(trainerId: trainerId, session: model);
  }

  @override
  Future<void> toggleSessionCompleted({
    required String trainerId,
    required String sessionId,
    required bool isCompleted,
  }) async {
    return _remoteDataSource.toggleSessionCompleted(
      trainerId: trainerId,
      sessionId: sessionId,
      isCompleted: isCompleted,
    );
  }

  @override
  Future<void> deleteSession({
    required String trainerId,
    required String sessionId,
  }) async {
    return _remoteDataSource.deleteSession(
      trainerId: trainerId,
      sessionId: sessionId,
    );
  }
}
