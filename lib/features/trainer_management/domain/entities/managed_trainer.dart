class ManagedTrainer {
  const ManagedTrainer({
    required this.uid,
    required this.email,
    required this.gymId,
    this.displayName,
    this.photoUrl,
    this.phone,
    this.specialization,
    this.bio,
    this.experienceYears,
    this.status = 'active',
    this.joinedAt,
  });

  final String uid;
  final String email;

  /// Gym currently assigned to this trainer.
  final String? gymId;

  final String? displayName;
  final String? photoUrl;
  final String? phone;

  /// Example:
  /// Personal Trainer
  /// Strength Coach
  /// Yoga Instructor
  final String? specialization;

  final String? bio;

  final int? experienceYears;

  /// Example: active, inactive.
  final String status;

  final DateTime? joinedAt;

  bool get isAssignedToGym =>
      gymId != null &&
          gymId!.isNotEmpty;

  bool get isActive =>
      status.toLowerCase() ==
          'active';
}