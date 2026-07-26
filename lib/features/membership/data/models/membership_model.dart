import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/membership.dart';

class MembershipModel extends Membership {
  const MembershipModel({
    required super.id,
    required super.userId,
    required super.gymName,
    required super.status,
    super.gymId,
    super.membershipType,
    super.startDate,
    super.expiryDate,
    super.price,
    super.paymentStatus,
    super.autoRenew,
  });

  factory MembershipModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'Membership document does not exist.',
      );
    }

    return MembershipModel(
      id: document.id,
      userId: data['userId'] as String? ?? '',
      gymId: data['gymId'] as String?,
      gymName: data['gymName'] as String? ?? '',
      status: data['status'] as String? ?? 'Inactive',
      membershipType:
      data['membershipType'] as String?,
      startDate: _parseDate(
        data['startDate'],
      ),
      expiryDate: _parseDate(
        data['expiryDate'],
      ),
      price: (data['price'] as num?)?.toDouble(),
      paymentStatus:
      data['paymentStatus'] as String?,
      autoRenew:
      data['autoRenew'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'gymId': gymId,
      'gymName': gymName,
      'status': status,
      'membershipType': membershipType,
      'startDate': startDate != null
          ? Timestamp.fromDate(startDate!)
          : null,
      'expiryDate': expiryDate != null
          ? Timestamp.fromDate(expiryDate!)
          : null,
      'price': price,
      'paymentStatus': paymentStatus,
      'autoRenew': autoRenew,
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