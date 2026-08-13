import '../entities/trainer_enrollment.dart';

abstract class TrainerEnrollmentRepository {
  Future<TrainerEnrollment> createEnrollment({
    required String gymId,
    required String displayName,
    required String email,
    required double monthlySalary,
    required DateTime startDate,
    String? specialization,
  });

  Future<TrainerEnrollment?> getEnrollment(
      String enrollmentId,
      );

  Future<void> cancelEnrollment(
      String enrollmentId,
      );
}