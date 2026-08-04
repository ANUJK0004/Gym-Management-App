class OwnerDashboardStats {
  const OwnerDashboardStats({
    required this.totalMembers,
    required this.activeTrainers,
    required this.newMembersThisMonth,
    this.monthlyRevenue = 0,
  });

  final int totalMembers;

  final int activeTrainers;

  final int newMembersThisMonth;

  final double monthlyRevenue;
}