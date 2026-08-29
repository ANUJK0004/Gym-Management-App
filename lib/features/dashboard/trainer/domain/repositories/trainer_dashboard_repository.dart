import '../entities/trainer_dashboard_data.dart';

abstract class TrainerDashboardRepository {
  Future<TrainerDashboardData> getDashboard({
    required String trainerId,
  });

  Future<void> startSession({
    required String trainerId,
    required String sessionId,
  });

  Future<void> completeSession({
    required String trainerId,
    required String sessionId,
    String? clientId,
  });

  Future<void> addSession({
    required String trainerId,
    required TrainerSession session,
  });

  Future<void> addClient({
    required String trainerId,
    required TrainerClientProgress client,
  });

  Future<void> updateClientProgress({
    required String trainerId,
    required String clientId,
    required int progressPercentage,
    int? sessionsCount,
  });
}
