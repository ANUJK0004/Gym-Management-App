class MemberDashboard {
  const MemberDashboard({
    required this.userName,
    this.photoUrl,
    this.fitnessGoal,
    this.activityLevel,
    this.height,
    this.weight,
    required this.completedWorkouts,
    required this.totalWorkouts,
    required this.currentWeight,
    required this.previousWeight,
    this.weeklyActivity = const [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ],
    this.monthlyWorkouts = 0,
    this.workoutChange = 0,
  });

  final String userName;
  final String? photoUrl;

  final String? fitnessGoal;
  final String? activityLevel;
  final double? height;
  final double? weight;

  final int completedWorkouts;
  final int totalWorkouts;

  final double currentWeight;
  final double previousWeight;

  final List<bool> weeklyActivity;
  final int monthlyWorkouts;
  final int workoutChange;

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