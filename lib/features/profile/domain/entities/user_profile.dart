class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    this.role = 'member',
    this.gymId,
    this.displayName,
    this.photoUrl,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.height,
    this.weight,
    this.fitnessGoal,
    this.activityLevel,
    this.profileCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String email;

  /// Current application role.
  ///
  /// Expected values:
  /// owner
  /// trainer
  /// member
  final String role;

  /// ID of the gym currently associated
  /// with this user.
  ///
  /// Null means the user is not currently
  /// associated with a gym.
  final String? gymId;

  final String? displayName;
  final String? photoUrl;

  /// Member phone number.
  final String? phone;

  final DateTime? dateOfBirth;

  final String? gender;

  final double? height;
  final double? weight;

  final String? fitnessGoal;
  final String? activityLevel;

  final bool profileCompleted;

  /// When the user profile was created.
  final DateTime? createdAt;

  /// Last time the profile was modified.
  final DateTime? updatedAt;

  UserProfile copyWith({
    String? displayName,
    String? role,
    String? gymId,
    String? photoUrl,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    String? fitnessGoal,
    String? activityLevel,
    bool? profileCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      email: email,

      role: role ?? this.role,

      gymId: gymId ?? this.gymId,

      displayName:
      displayName ?? this.displayName,

      photoUrl:
      photoUrl ?? this.photoUrl,

      phone:
      phone ?? this.phone,

      dateOfBirth:
      dateOfBirth ?? this.dateOfBirth,

      gender:
      gender ?? this.gender,

      height:
      height ?? this.height,

      weight:
      weight ?? this.weight,

      fitnessGoal:
      fitnessGoal ?? this.fitnessGoal,

      activityLevel:
      activityLevel ?? this.activityLevel,

      profileCompleted:
      profileCompleted ?? this.profileCompleted,

      createdAt:
      createdAt ?? this.createdAt,

      updatedAt:
      updatedAt ?? this.updatedAt,
    );
  }
}