import '../../domain/entities/trainer_enrollment.dart';
import '../../domain/repositories/trainer_enrollment_repository.dart';

import '../datasources/trainer_enrollment_remote_datasource.dart';

class TrainerEnrollmentRepositoryImpl
    implements TrainerEnrollmentRepository {
  TrainerEnrollmentRepositoryImpl(
      this._dataSource,
      );

  final TrainerEnrollmentRemoteDataSource
  _dataSource;

  @override
  Future<TrainerEnrollment> createEnrollment({
    required String gymId,
    required String displayName,
    required String email,
    required double monthlySalary,
    required DateTime startDate,
    String? specialization,
  }) {
    return _dataSource.createEnrollment(
      gymId: gymId,
      displayName: displayName,
      email: email,
      monthlySalary: monthlySalary,
      startDate: startDate,
      specialization: specialization,
    );
  }

  @override
  Future<TrainerEnrollment?> getEnrollment(
      String enrollmentId,
      ) {
    return _dataSource.getEnrollment(
      enrollmentId,
    );
  }

  @override
  Future<void> cancelEnrollment(
      String enrollmentId,
      ) {
    return _dataSource.cancelEnrollment(
      enrollmentId,
    );
  }
}