import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.dateOfBirth,
    super.gender,
    super.height,
    super.weight,
    super.fitnessGoal,
    super.activityLevel,
    super.profileCompleted,
  });

  factory UserProfileModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'User profile document does not exist.',
      );
    }

    return UserProfileModel(
      uid: data['uid'] as String? ?? document.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      dateOfBirth: _parseDate(data['dateOfBirth']),
      gender: data['gender'] as String?,
      height: (data['height'] as num?)?.toDouble(),
      weight: (data['weight'] as num?)?.toDouble(),
      fitnessGoal: data['fitnessGoal'] as String?,
      activityLevel: data['activityLevel'] as String?,
      profileCompleted:
      data['profileCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'gender': gender,
      'height': height,
      'weight': weight,
      'fitnessGoal': fitnessGoal,
      'activityLevel': activityLevel,
      'profileCompleted': profileCompleted,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }
}