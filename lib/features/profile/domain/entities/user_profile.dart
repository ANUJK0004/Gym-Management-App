class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
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

  final String? displayName;
  final String? photoUrl;

  final DateTime? dateOfBirth;

  final String? gender;

  final double? height;
  final double? weight;

  final String? fitnessGoal;
  final String? activityLevel;

  final bool profileCompleted;
}