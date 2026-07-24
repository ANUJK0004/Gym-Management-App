class MemberDashboard {
  const MemberDashboard({
    required this.userName,
    this.photoUrl,

    this.fitnessGoal,
    this.activityLevel,
    this.height,
    this.weight,

    required this.gymName,
    required this.membershipStatus,
    this.membershipExpiryDate,

    required this.workoutName,
    required this.workoutDescription,
    required this.exerciseCount,
    required this.workoutDuration,

    required this.completedWorkouts,
    required this.totalWorkouts,

    required this.currentWeight,
    required this.previousWeight,
  });

  final String userName;
  final String? photoUrl;

  final String? fitnessGoal;
  final String? activityLevel;
  final double? height;
  final double? weight;

  final String gymName;
  final String membershipStatus;
  final DateTime? membershipExpiryDate;

  final String workoutName;
  final String workoutDescription;
  final int exerciseCount;
  final int workoutDuration;

  final int completedWorkouts;
  final int totalWorkouts;

  final double currentWeight;
  final double previousWeight;

  double get weeklyProgress {
    if (totalWorkouts == 0) {
      return 0;
    }

    return completedWorkouts / totalWorkouts;
  }

  double get weightChange {
    return currentWeight - previousWeight;
  }
}