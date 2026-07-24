import '../models/member_dashboard_model.dart';

class MemberDashboardRemoteDataSource {
  Future<MemberDashboardModel> getMemberDashboard(
      String uid,
      ) async {
    // Temporary mock data.
    //
    // Firestore implementation will be added
    // after the dashboard UI is completed.

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    return MemberDashboardModel(
      userName: 'Alex',
      photoUrl: null,

      fitnessGoal: 'Build Muscle',
      activityLevel: 'High',
      height: 178,
      weight: 72.5,

      gymName: 'SweatZone Fitness',
      membershipStatus: 'Active',
      membershipExpiryDate: DateTime(
        2026,
        8,
        24,
      ),

      workoutName: 'Push Day',
      workoutDescription:
      'Chest • Shoulders • Triceps',
      exerciseCount: 6,
      workoutDuration: 45,

      completedWorkouts: 3,
      totalWorkouts: 5,

      currentWeight: 72.5,
      previousWeight: 74.0,
    );
  }
}