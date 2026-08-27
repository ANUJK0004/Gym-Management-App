import '../entities/trainer_dashboard_data.dart';

abstract class TrainerDashboardRepository {
  Future<TrainerDashboardData> getDashboard({
    required String trainerId,
  });
}
