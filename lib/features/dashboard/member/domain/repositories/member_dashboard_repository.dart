import '../entities/member_dashboard.dart';

abstract class MemberDashboardRepository {
  Future<MemberDashboard> getMemberDashboard(
      String uid,
      );
}