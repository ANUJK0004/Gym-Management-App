import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/member_enrollment.dart';

class MemberEnrollmentModel extends MemberEnrollment {
  const MemberEnrollmentModel({
    required super.id,
    required super.gymId,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.status,
    required super.accountStatus,
    required super.membershipPlanId,
    required super.membershipPlanName,
    required super.amount,
    required super.paymentMethod,
    required super.createdAt,
    super.memberId,
    super.phone,
    super.dateOfBirth,
    super.gender,
    super.fitnessGoal,
    super.startDate,
    super.invitationSentAt,
    super.completedAt,
  });

  factory MemberEnrollmentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();

    if (data == null) {
      throw Exception('Enrollment does not exist.');
    }

    return MemberEnrollmentModel(
      id: document.id,
      gymId: data['gymId'] as String? ?? '',
      email: data['email'] as String? ?? '',
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      phone: data['phone'] as String?,
      dateOfBirth: _parseDate(data['dateOfBirth']),
      gender: data['gender'] as String?,
      fitnessGoal: data['fitnessGoal'] as String?,
      membershipPlanId:
      data['membershipPlanId'] as String? ?? '',
      membershipPlanName:
      data['membershipPlanName'] as String? ?? '',
      amount:
      (data['amount'] as num?)?.toDouble() ?? 0,
      paymentMethod:
      data['paymentMethod'] as String? ?? '',
      startDate:
      _parseDate(data['startDate']),
      status:
      _parseStatus(data['status']),
      accountStatus:
      _parseAccountStatus(data['accountStatus']),
      memberId:
      data['memberId'] as String?,
      createdAt:
      _parseDate(data['createdAt']) ??
          DateTime.now(),
      invitationSentAt:
      _parseDate(data['invitationSentAt']),
      completedAt:
      _parseDate(data['completedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gymId': gymId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'gender': gender,
      'fitnessGoal': fitnessGoal,
      'membershipPlanId': membershipPlanId,
      'membershipPlanName': membershipPlanName,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'startDate': startDate != null
          ? Timestamp.fromDate(startDate!)
          : null,
      'status': status.name,
      'accountStatus': accountStatus.name,
      'memberId': memberId,
      'createdAt': Timestamp.fromDate(createdAt),
      'invitationSentAt': invitationSentAt != null
          ? Timestamp.fromDate(invitationSentAt!)
          : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }

  static MemberEnrollmentStatus _parseStatus(
      dynamic value,
      ) {
    switch (value) {
      case 'completed':
        return MemberEnrollmentStatus.completed;

      case 'cancelled':
        return MemberEnrollmentStatus.cancelled;

      default:
        return MemberEnrollmentStatus.pending;
    }
  }

  static MemberAccountStatus _parseAccountStatus(
      dynamic value,
      ) {
    if (value == 'existing') {
      return MemberAccountStatus.existing;
    }

    return MemberAccountStatus.invitationRequired;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}