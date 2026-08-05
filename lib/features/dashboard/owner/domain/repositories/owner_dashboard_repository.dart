import '../entities/owner_dashboard_data.dart';

abstract class OwnerDashboardRepository {
  Future<OwnerDashboardData> getDashboard({
    required String ownerId,
  });
}