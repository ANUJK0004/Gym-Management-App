import '../../domain/entities/member_enrollment.dart';
import '../../domain/repositories/member_enrollment_repository.dart';

import '../datasources/member_enrollment_remote_datasource.dart';

class MemberEnrollmentRepositoryImpl
    implements MemberEnrollmentRepository {
  MemberEnrollmentRepositoryImpl(
      this._dataSource,
      );

  final MemberEnrollmentRemoteDataSource _dataSource;

  @override
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
  }) {
    return _dataSource.createEnrollment(
      gymId: gymId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      dateOfBirth: dateOfBirth,
      gender: gender,
      fitnessGoal: fitnessGoal,
      membershipPlanId: membershipPlanId,
      membershipPlanName: membershipPlanName,
      amount: amount,
      paymentMethod: paymentMethod,
      startDate: startDate,
    );
  }

  @override
  Future<MemberEnrollment?> getEnrollment(
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