import '../../domain/entities/owner_dashboard_stats.dart';

class OwnerDashboardStatsModel
    extends OwnerDashboardStats {
  const OwnerDashboardStatsModel({
    required super.totalMembers,
    required super.activeTrainers,
    required super.newMembersThisMonth,
    super.monthlyRevenue,
  });

  factory OwnerDashboardStatsModel.fromMap(
      Map<String, dynamic> data,
      ) {
    return OwnerDashboardStatsModel(
      totalMembers:
      (data['totalMembers'] as num?)?.toInt() ?? 0,

      activeTrainers:
      (data['activeTrainers'] as num?)?.toInt() ?? 0,

      newMembersThisMonth:
      (data['newMembersThisMonth'] as num?)?.toInt() ?? 0,

      monthlyRevenue:
      (data['monthlyRevenue'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalMembers': totalMembers,
      'activeTrainers': activeTrainers,
      'newMembersThisMonth': newMembersThisMonth,
      'monthlyRevenue': monthlyRevenue,
    };
  }
}