import '../../domain/entities/owner_dashboard_data.dart';

class OwnerDashboardDataModel extends OwnerDashboardData {
  const OwnerDashboardDataModel({
    required super.ownerId,
    required super.ownerName,
    required super.ownerEmail,
    super.ownerPhotoUrl,

    required super.gymId,
    required super.gymName,
    required super.gymAddress,
    required super.gymPhone,
    required super.gymEmail,
    required super.gymDescription,
    super.gymLogoUrl,

    required super.totalMembers,
    required super.activeMembers,
    required super.expiredMembers,
    required super.pendingMembers,
    required super.activeTrainers,
    required super.newMembersThisMonth,
    required super.monthlyRevenue,
    super.monthlyRevenueTrend,
  });
}