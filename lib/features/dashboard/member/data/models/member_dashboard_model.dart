import '../../domain/entities/member_dashboard.dart';

class MemberDashboardModel extends MemberDashboard {
  const MemberDashboardModel({
    required super.userName,
    super.photoUrl,
    super.fitnessGoal,
    super.activityLevel,
    super.height,
    super.weight,
    required super.completedWorkouts,
    required super.totalWorkouts,
    required super.currentWeight,
    required super.previousWeight,
    super.weeklyActivity,
    super.monthlyWorkouts,
    super.workoutChange,
  });

  factory MemberDashboardModel.fromMap(
      Map<String, dynamic> data,
      ) {
    final rawWeekly = data['weeklyActivity'];
    List<bool> parsedWeekly = const [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ];
    if (rawWeekly is List) {
      parsedWeekly = rawWeekly.map((e) => e == true).toList();
      if (parsedWeekly.length < 7) {
        parsedWeekly = [
          ...parsedWeekly,
          ...List.filled(7 - parsedWeekly.length, false),
        ];
      }
    }

    return MemberDashboardModel(
      userName:
      data['userName'] as String? ?? '',

      photoUrl:
      data['photoUrl'] as String?,

      fitnessGoal:
      data['fitnessGoal'] as String?,

      activityLevel:
      data['activityLevel'] as String?,

      height:
      (data['height'] as num?)?.toDouble(),

      weight:
      (data['weight'] as num?)?.toDouble(),

      completedWorkouts:
      (data['completedWorkouts'] as num?)?.toInt() ??
          0,

      totalWorkouts:
      (data['totalWorkouts'] as num?)?.toInt() ??
          0,

      currentWeight:
      (data['currentWeight'] as num?)?.toDouble() ??
          0,

      previousWeight:
      (data['previousWeight'] as num?)?.toDouble() ??
          0,

      weeklyActivity: parsedWeekly,

      monthlyWorkouts:
      (data['monthlyWorkouts'] as num?)?.toInt() ?? 0,

      workoutChange:
      (data['workoutChange'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'photoUrl': photoUrl,
      'fitnessGoal': fitnessGoal,
      'activityLevel': activityLevel,
      'height': height,
      'weight': weight,
      'completedWorkouts':
      completedWorkouts,
      'totalWorkouts':
      totalWorkouts,
      'currentWeight':
      currentWeight,
      'previousWeight':
      previousWeight,
      'weeklyActivity': weeklyActivity,
      'monthlyWorkouts': monthlyWorkouts,
      'workoutChange': workoutChange,
    };
  }

}