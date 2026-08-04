import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/owner_settings.dart';

class OwnerSettingsModel extends OwnerSettings {
  const OwnerSettingsModel({
    required super.gymId,
    required super.ownerId,
    super.gymName,
    super.address,
    super.phone,
    super.website,
    super.logoUrl,
    super.operatingHours,
    super.isVerified,
  });

  factory OwnerSettingsModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'Owner settings document does not exist.',
      );
    }

    final rawHours =
    data['operatingHours'] as Map<String, dynamic>?;

    return OwnerSettingsModel(
      gymId:
      data['gymId'] as String? ?? '',
      ownerId:
      data['ownerId'] as String? ?? '',
      gymName:
      data['gymName'] as String?,
      address:
      data['address'] as String?,
      phone:
      data['phone'] as String?,
      website:
      data['website'] as String?,
      logoUrl:
      data['logoUrl'] as String?,
      operatingHours:
      rawHours?.map(
            (key, value) =>
            MapEntry(
              key,
              value.toString(),
            ),
      ),
      isVerified:
      data['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gymId': gymId,
      'ownerId': ownerId,
      'gymName': gymName,
      'address': address,
      'phone': phone,
      'website': website,
      'logoUrl': logoUrl,
      'operatingHours': operatingHours,
      'isVerified': isVerified,
    };
  }
}