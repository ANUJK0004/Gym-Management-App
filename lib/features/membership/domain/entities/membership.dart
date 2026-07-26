class Membership {
  const Membership({
    required this.id,
    required this.userId,
    required this.gymName,
    required this.status,
    this.gymId,
    this.membershipType,
    this.startDate,
    this.expiryDate,
    this.price,
    this.paymentStatus,
    this.autoRenew = false,
  });

  final String id;
  final String userId;

  final String? gymId;
  final String gymName;

  final String status;
  final String? membershipType;

  final DateTime? startDate;
  final DateTime? expiryDate;

  final double? price;
  final String? paymentStatus;

  final bool autoRenew;

  bool get isActive {
    return status.toLowerCase() == 'active';
  }

  bool get isExpired {
    if (expiryDate == null) {
      return false;
    }

    return DateTime.now().isAfter(expiryDate!);
  }

  int get remainingDays {
    if (expiryDate == null) {
      return 0;
    }

    final difference =
        expiryDate!.difference(DateTime.now()).inDays;

    return difference < 0 ? 0 : difference;
  }

  bool get isExpiringSoon {
    return isActive &&
        remainingDays <= 7 &&
        remainingDays > 0;
  }
}