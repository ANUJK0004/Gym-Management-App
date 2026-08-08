import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/member_enrollment_remote_datasource.dart';
import '../../data/repositories/member_enrollment_repository_impl.dart';

import '../../domain/entities/member_enrollment.dart';
import '../../domain/repositories/member_enrollment_repository.dart';

final memberEnrollmentRemoteDataSourceProvider =
Provider<MemberEnrollmentRemoteDataSource>(
      (ref) {
    return MemberEnrollmentRemoteDataSource();
  },
);

final memberEnrollmentRepositoryProvider =
Provider<MemberEnrollmentRepository>(
      (ref) {
    return MemberEnrollmentRepositoryImpl(
      ref.watch(
        memberEnrollmentRemoteDataSourceProvider,
      ),
    );
  },
);

final memberEnrollmentControllerProvider =
AsyncNotifierProvider<
    MemberEnrollmentController,
    MemberEnrollment?>(
  MemberEnrollmentController.new,
);

class MemberEnrollmentController
    extends AsyncNotifier<MemberEnrollment?> {
  @override
  Future<MemberEnrollment?> build() async {
    return null;
  }

  Future<MemberEnrollment> enroll({
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
    required String paymentMethod,
    required DateTime startDate,
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
          () {
        return ref
            .read(
          memberEnrollmentRepositoryProvider,
        )
            .createEnrollment(
          gymId: gymId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
          dateOfBirth: dateOfBirth,
          gender: gender,
          fitnessGoal: fitnessGoal,
          membershipPlanId:
          membershipPlanId,
          membershipPlanName:
          membershipPlanName,
          amount: amount,
          paymentMethod:
          paymentMethod,
          startDate:
          startDate,
        );
      },
    );

    state = result;

    if (result.hasError) {
      throw result.error!;
    }

    return result.requireValue;
  }
}