import '../entities/member_enrollment.dart';

abstract class MemberEnrollmentRepository {
  Future<MemberEnrollment> createEnrollment({
    required String gymId,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? fitnessGoal,
    required String membershipPlanId,
    required String membershipPlanName,
    required double amount,
    String? paymentMethod,
    required DateTime startDate,
  });

  Future<MemberEnrollment?> getEnrollment(
      String enrollmentId,
      );

  Future<void> cancelEnrollment(
      String enrollmentId,
      );
}