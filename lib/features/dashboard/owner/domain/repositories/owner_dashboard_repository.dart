import '../entities/owner_dashboard_stats.dart';

abstract class OwnerDashboardRepository {
  Future<OwnerDashboardStats> getDashboardStats({
    required String gymId,
  });
}