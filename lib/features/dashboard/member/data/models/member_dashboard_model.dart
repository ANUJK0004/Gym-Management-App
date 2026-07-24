import '../../domain/entities/member_dashboard.dart';

class MemberDashboardModel extends MemberDashboard {
  const MemberDashboardModel({
    required super.userName,
    super.photoUrl,
    super.fitnessGoal,
    super.activityLevel,
    super.height,
    super.weight,
    required super.gymName,
    required super.membershipStatus,
    super.membershipExpiryDate,
    required super.workoutName,
    required super.workoutDescription,
    required super.exerciseCount,
    required super.workoutDuration,
    required super.completedWorkouts,
    required super.totalWorkouts,
    required super.currentWeight,
    required super.previousWeight,
  });

  factory MemberDashboardModel.fromMap(
      Map<String, dynamic> data,
      ) {
    return MemberDashboardModel(
      userName: data['userName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      fitnessGoal: data['fitnessGoal'] as String?,
      activityLevel: data['activityLevel'] as String?,
      height: (data['height'] as num?)?.toDouble(),
      weight: (data['weight'] as num?)?.toDouble(),
      gymName: data['gymName'] as String? ?? '',
      membershipStatus:
      data['membershipStatus'] as String? ?? 'Inactive',
      membershipExpiryDate: data['membershipExpiryDate'],
      workoutName:
      data['workoutName'] as String? ?? 'No workout',
      workoutDescription:
      data['workoutDescription'] as String? ?? '',
      exerciseCount:
      data['exerciseCount'] as int? ?? 0,
      workoutDuration:
      data['workoutDuration'] as int? ?? 0,
      completedWorkouts:
      data['completedWorkouts'] as int? ?? 0,
      totalWorkouts:
      data['totalWorkouts'] as int? ?? 0,
      currentWeight:
      (data['currentWeight'] as num?)?.toDouble() ?? 0,
      previousWeight:
      (data['previousWeight'] as num?)?.toDouble() ?? 0,
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
      'gymName': gymName,
      'membershipStatus': membershipStatus,
      'membershipExpiryDate': membershipExpiryDate,
      'workoutName': workoutName,
      'workoutDescription': workoutDescription,
      'exerciseCount': exerciseCount,
      'workoutDuration': workoutDuration,
      'completedWorkouts': completedWorkouts,
      'totalWorkouts': totalWorkouts,
      'currentWeight': currentWeight,
      'previousWeight': previousWeight,
    };
  }
}