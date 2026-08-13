enum TrainerEnrollmentStatus {
  pending,
  completed,
  cancelled,
}

enum TrainerAccountStatus {
  existing,
  invitationRequired,
}

class TrainerEnrollment {
  const TrainerEnrollment({
    required this.id,
    required this.gymId,
    required this.email,
    required this.displayName,
    required this.specialization,
    required this.monthlySalary,
    required this.startDate,
    required this.status,
    required this.accountStatus,
    required this.createdAt,
    this.trainerId,
    this.invitationSentAt,
    this.completedAt,
  });

  final String id;
  final String gymId;
  final String email;
  final String displayName;
  final String? specialization;
  final double monthlySalary;
  final DateTime startDate;

  final TrainerEnrollmentStatus status;
  final TrainerAccountStatus accountStatus;

  final String? trainerId;

  final DateTime createdAt;
  final DateTime? invitationSentAt;
  final DateTime? completedAt;

  bool get requiresInvitation =>
      accountStatus ==
          TrainerAccountStatus.invitationRequired;

  bool get isCompleted =>
      status == TrainerEnrollmentStatus.completed;
}