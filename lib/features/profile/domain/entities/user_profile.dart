class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    this.role = 'member',
    this.gymId,
    this.displayName,
    this.photoUrl,
    this.dateOfBirth,
    this.gender,
    this.height,
    this.weight,
    this.fitnessGoal,
    this.activityLevel,
    this.profileCompleted = false,
  });

  final String uid;
  final String email;

  final String role;

  /// ID of the gym this user belongs to or owns.
  ///
  /// Null means the user is not currently connected
  /// to any gym.
  final String? gymId;

  final String? displayName;
  final String? photoUrl;

  final DateTime? dateOfBirth;

  final String? gender;

  final double? height;
  final double? weight;

  final String? fitnessGoal;
  final String? activityLevel;

  final bool profileCompleted;

  UserProfile copyWith({
    String? displayName,
    String? role,
    String? gymId,
    String? photoUrl,
    DateTime? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    String? fitnessGoal,
    String? activityLevel,
    bool? profileCompleted,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      role: role ?? this.role,
      gymId: gymId ?? this.gymId,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      profileCompleted:
      profileCompleted ?? this.profileCompleted,
    );
  }
}