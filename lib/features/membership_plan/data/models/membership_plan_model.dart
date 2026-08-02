import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/membership_plan.dart';

class MembershipPlanModel extends MembershipPlan {
  const MembershipPlanModel({
    required super.id,
    required super.gymId,
    required super.name,
    required super.price,
    required super.durationInDays,
    super.description,
    super.isActive,
    super.createdAt,
  });

  factory MembershipPlanModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'Membership plan document does not exist.',
      );
    }

    return MembershipPlanModel(
      id: document.id,
      gymId:
      data['gymId'] as String? ?? '',
      name:
      data['name'] as String? ?? '',
      price:
      (data['price'] as num?)?.toDouble() ?? 0,
      durationInDays:
      data['durationInDays'] as int? ?? 0,
      description:
      data['description'] as String?,
      isActive:
      data['isActive'] as bool? ?? true,
      createdAt:
      _parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gymId': gymId,
      'name': name,
      'price': price,
      'durationInDays': durationInDays,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
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