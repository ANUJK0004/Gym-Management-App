import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/managed_trainer.dart';

class ManagedTrainerModel extends ManagedTrainer {
  const ManagedTrainerModel({
    required super.uid,
    required super.email,
    super.gymId,
    super.displayName,
    super.photoUrl,
    super.phone,
    super.specialization,
    super.bio,
    super.experienceYears,
    super.monthlySalary,
    super.clientCount,
    super.sessionCount,
    super.rating,
    super.status,
    super.joinedAt,
  });

  factory ManagedTrainerModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'Trainer document does not exist.',
      );
    }

    return ManagedTrainerModel(
      uid: data['uid'] as String? ?? document.id,
      email: data['email'] as String? ?? '',
      gymId: data['gymId'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      phone: data['phone'] as String?,
      specialization:
      data['specialization'] as String?,
      bio: data['bio'] as String?,
      experienceYears:
      (data['experienceYears'] as num?)?.toInt(),
      monthlySalary:
      (data['monthlySalary'] as num?)?.toDouble(),
      clientCount:
      (data['clientCount'] as num?)?.toInt() ?? 0,
      sessionCount:
      (data['sessionCount'] as num?)?.toInt() ?? 0,
      rating:
      (data['rating'] as num?)?.toDouble() ?? 0,
      status:
      data['status'] as String? ?? 'active',
      joinedAt:
      _parseDate(data['joinedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'gymId': gymId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phone': phone,
      'specialization': specialization,
      'bio': bio,
      'experienceYears': experienceYears,
      'monthlySalary': monthlySalary,
      'clientCount': clientCount,
      'sessionCount': sessionCount,
      'rating': rating,
      'status': status,
      'joinedAt': joinedAt != null
          ? Timestamp.fromDate(joinedAt!)
          : null,
    };
  }

  static DateTime? _parseDate(dynamic value) {
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