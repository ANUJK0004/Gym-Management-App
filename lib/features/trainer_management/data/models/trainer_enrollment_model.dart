import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trainer_enrollment.dart';

class TrainerEnrollmentModel
    extends TrainerEnrollment {
  const TrainerEnrollmentModel({
    required super.id,
    required super.gymId,
    required super.email,
    required super.displayName,
    required super.specialization,
    required super.monthlySalary,
    required super.startDate,
    required super.status,
    required super.accountStatus,
    required super.createdAt,
    super.trainerId,
    super.invitationSentAt,
    super.completedAt,
  });

  factory TrainerEnrollmentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'Trainer enrollment does not exist.',
      );
    }

    return TrainerEnrollmentModel(
      id: document.id,
      gymId:
      data['gymId'] as String? ?? '',
      email:
      data['email'] as String? ?? '',
      displayName:
      data['displayName'] as String? ?? '',
      specialization:
      data['specialization'] as String?,
      monthlySalary:
      (data['monthlySalary'] as num?)
          ?.toDouble() ??
          0,
      startDate:
      _parseDate(data['startDate']) ??
          DateTime.now(),
      status:
      _parseStatus(data['status']),
      accountStatus:
      _parseAccountStatus(
        data['accountStatus'],
      ),
      trainerId:
      data['trainerId'] as String?,
      createdAt:
      _parseDate(data['createdAt']) ??
          DateTime.now(),
      invitationSentAt:
      _parseDate(
        data['invitationSentAt'],
      ),
      completedAt:
      _parseDate(
        data['completedAt'],
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gymId': gymId,
      'email': email,
      'displayName': displayName,
      'specialization': specialization,
      'monthlySalary': monthlySalary,
      'startDate':
      Timestamp.fromDate(startDate),
      'status': status.name,
      'accountStatus':
      accountStatus.name,
      'trainerId': trainerId,
      'createdAt':
      Timestamp.fromDate(createdAt),
      'invitationSentAt':
      invitationSentAt != null
          ? Timestamp.fromDate(
        invitationSentAt!,
      )
          : null,
      'completedAt':
      completedAt != null
          ? Timestamp.fromDate(
        completedAt!,
      )
          : null,
    };
  }

  static TrainerEnrollmentStatus _parseStatus(
      dynamic value,
      ) {
    switch (value) {
      case 'completed':
        return TrainerEnrollmentStatus.completed;

      case 'cancelled':
        return TrainerEnrollmentStatus.cancelled;

      default:
        return TrainerEnrollmentStatus.pending;
    }
  }

  static TrainerAccountStatus _parseAccountStatus(
      dynamic value,
      ) {
    if (value == 'existing') {
      return TrainerAccountStatus.existing;
    }

    return TrainerAccountStatus.invitationRequired;
  }

  static DateTime? _parseDate(
      dynamic value,
      ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}