class OwnerDashboardData {
  const OwnerDashboardData({
    // Owner
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    this.ownerPhotoUrl,

    // Gym
    required this.gymId,
    required this.gymName,
    required this.gymAddress,
    this.gymPhone,
    this.gymEmail,
    this.gymDescription,
    this.gymLogoUrl,

    // Dashboard Stats
    required this.totalMembers,
    required this.activeMembers,
    required this.expiredMembers,
    required this.pendingMembers,
    required this.activeTrainers,
    required this.newMembersThisMonth,
    required this.monthlyRevenue,
  });

  //================ OWNER ================//

  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final String? ownerPhotoUrl;

  //================ GYM =================//

  final String gymId;
  final String gymName;
  final String gymAddress;
  final String? gymPhone;
  final String? gymEmail;
  final String? gymDescription;
  final String? gymLogoUrl;

  //================ STATS ================//

  final int totalMembers;

  final int activeMembers;

  final int expiredMembers;

  final int pendingMembers;

  final int activeTrainers;

  final int newMembersThisMonth;

  final double monthlyRevenue;
}