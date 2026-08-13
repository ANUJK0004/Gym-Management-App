class ManagedTrainer {
  const ManagedTrainer({
    required this.uid,
    required this.email,
    this.gymId,
    this.displayName,
    this.photoUrl,
    this.phone,
    this.specialization,
    this.bio,
    this.experienceYears,
    this.monthlySalary,
    this.clientCount = 0,
    this.sessionCount = 0,
    this.rating = 0,
    this.status = 'active',
    this.joinedAt,
  });

  final String uid;
  final String email;

  /// Gym currently assigned to this trainer.
  ///
  /// Null means the trainer is not assigned
  /// to any gym.
  final String? gymId;

  final String? displayName;
  final String? photoUrl;
  final String? phone;

  final String? specialization;
  final String? bio;

  final int? experienceYears;

  final double? monthlySalary;

  final int clientCount;
  final int sessionCount;
  final double rating;

  /// active / inactive
  final String status;

  final DateTime? joinedAt;

  bool get isAssignedToGym =>
      gymId != null && gymId!.isNotEmpty;

  bool get isActive =>
      status.toLowerCase() == 'active';
}