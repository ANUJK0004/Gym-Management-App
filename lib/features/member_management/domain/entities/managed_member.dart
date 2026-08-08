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

/// ID of the membership plan currently
/// assigned to the member.
final String? membershipPlanId;

/// Examples:
/// pending
/// active
/// expired
final String? membershipStatus;

/// Date on which the member was assigned
/// to the gym.
final DateTime? joinedAt;

bool get isAssignedToGym =>
gymId != null &&
gymId!.isNotEmpty;

bool get hasMembership =>
membershipPlanId != null &&
membershipPlanId!.isNotEmpty;

bool get isMembershipActive =>
membershipStatus == 'active';
}