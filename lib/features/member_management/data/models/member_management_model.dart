import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/managed_member.dart';

class MemberManagementModel extends ManagedMember {
  const MemberManagementModel({
    required super.uid,
    required super.email,
    super.gymId,
    super.displayName,
    super.photoUrl,
    super.phone,
    super.profileCompleted,
    super.membershipPlanId,
    super.membershipStatus,
    super.joinedAt,
  });

  factory MemberManagementModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'Member document does not exist.',
      );
    }

    return MemberManagementModel(
      uid: document.id,

      email: data['email'] as String? ?? '',

      gymId: data['gymId'] as String?,

      displayName:
      data['displayName'] as String?,

      photoUrl:
      data['photoUrl'] as String?,

      phone:
      data['phone'] as String?,

      profileCompleted:
      data['profileCompleted'] as bool? ?? false,

      membershipPlanId:
      data['membershipPlanId'] as String?,

      membershipStatus:
      data['membershipStatus'] as String?,

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
      'profileCompleted': profileCompleted,
      'membershipPlanId': membershipPlanId,
      'membershipStatus': membershipStatus,
      'joinedAt': joinedAt != null
          ? Timestamp.fromDate(joinedAt!)
          : null,
    };
  }

  static DateTime? _parseDate(
      dynamic value,
      ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}