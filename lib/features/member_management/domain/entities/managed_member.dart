class ManagedMember {
  const ManagedMember({
    required this.uid,
    required this.email,
    this.gymId,
    this.displayName,
    this.photoUrl,
    this.phone,
    this.profileCompleted = false,
    this.membershipPlanId,
    this.membershipStatus,
    this.membershipStartedAt,
    this.membershipExpiresAt,
    this.joinedAt,
  });

  final String uid;
  final String email;

  /// Gym currently assigned to this member.
  ///
  /// Null means the member is not currently
  /// assigned to any gym.
  final String? gymId;

  final String? displayName;
  final String? photoUrl;
  final String? phone;

  final bool profileCompleted;

  /// Currently assigned membership plan.
  final String? membershipPlanId;

  /// Examples:
  /// pending
  /// active
  /// expired
  /// inactive
  final String? membershipStatus;

  /// Date on which the current membership started.
  final DateTime? membershipStartedAt;

  /// Date on which the current membership expires.
  final DateTime? membershipExpiresAt;

  /// Date on which the member was assigned to the gym.
  final DateTime? joinedAt;

  bool get isAssignedToGym =>
      gymId != null &&
          gymId!.isNotEmpty;

  bool get hasMembership =>
      membershipPlanId != null &&
          membershipPlanId!.isNotEmpty;

  bool get isMembershipExpired {
    if (membershipExpiresAt == null) {
      return membershipStatus == 'expired';
    }

    return membershipExpiresAt!.isBefore(
      DateTime.now(),
    );
  }

  bool get isMembershipActive =>
      membershipStatus == 'active' &&
          !isMembershipExpired;

  String get effectiveMembershipStatus {
    if (isMembershipExpired) {
      return 'expired';
    }

    return membershipStatus ?? 'inactive';
  }
}