import '../entities/trainer_schedule_session.dart';

abstract class TrainerScheduleRepository {
  Stream<List<TrainerScheduleSession>> watchSessions({
    required String trainerId,
  });

  Future<List<TrainerScheduleSession>> getSessions({
    required String trainerId,
    DateTime? date,
  });

  Future<TrainerScheduleSession> addSession({
    required String trainerId,
    required TrainerScheduleSession session,
  });

  Future<void> updateSession({
    required String trainerId,
    required TrainerScheduleSession session,
  });

  Future<void> toggleSessionCompleted({
    required String trainerId,
    required String sessionId,
    required bool isCompleted,
  });

  Future<void> deleteSession({
    required String trainerId,
    required String sessionId,
  });
}
