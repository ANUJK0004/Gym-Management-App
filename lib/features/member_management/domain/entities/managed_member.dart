class ManagedMember {
  const ManagedMember({
    required this.uid,
    required this.email,
    required this.gymId,
    this.displayName,
    this.photoUrl,
    this.phone,
    this.profileCompleted = false,
    this.membershipPlanId,
    this.membershipStatus,
    this.joinedAt,
  });

  final String uid;
  final String email;

  /// Gym currently assigned to this member.
  final String? gymId;

  final String? displayName;
  final String? photoUrl;
  final String? phone;

  final bool profileCompleted;

  /// Will be used when Membership Assignment is connected.
  final String? membershipPlanId;

  /// Example: active, expired, pending.
  final String? membershipStatus;

  final DateTime? joinedAt;

  bool get isAssignedToGym =>
      gymId != null && gymId!.isNotEmpty;
}