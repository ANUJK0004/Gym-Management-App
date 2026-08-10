enum MemberEnrollmentStatus {
  pending,
  completed,
  cancelled,
}

enum MemberAccountStatus {
  existing,
  invitationRequired,
}

class MemberEnrollment {
  const MemberEnrollment({
    required this.id,
    required this.gymId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.accountStatus,
    required this.membershipPlanId,
    required this.membershipPlanName,
    required this.amount,
    required this.paymentMethod,
    required this.createdAt,
    this.memberId,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.fitnessGoal,
    this.startDate,
    this.invitationSentAt,
    this.completedAt,
  });

  final String id;
  final String gymId;
  final String email;
  final String firstName;
  final String lastName;

  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? fitnessGoal;

  final String membershipPlanId;
  final String membershipPlanName;
  final double amount;

  /// null means payment is pending.
  final String? paymentMethod;

  final DateTime? startDate;

  final MemberEnrollmentStatus status;
  final MemberAccountStatus accountStatus;

  final String? memberId;

  final DateTime createdAt;
  final DateTime? invitationSentAt;
  final DateTime? completedAt;

  String get fullName {
    return '$firstName $lastName'.trim();
  }

  bool get requiresInvitation {
    return accountStatus ==
        MemberAccountStatus.invitationRequired;
  }

  bool get isPaymentPending {
    return paymentMethod == null ||
        paymentMethod!.trim().isEmpty;
  }
}