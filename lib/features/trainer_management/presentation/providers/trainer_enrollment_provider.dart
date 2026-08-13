import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/trainer_enrollment_remote_datasource.dart';
import '../../data/repositories/trainer_enrollment_repository_impl.dart';

import '../../domain/entities/trainer_enrollment.dart';
import '../../domain/repositories/trainer_enrollment_repository.dart';

final trainerEnrollmentRemoteDataSourceProvider =
Provider<TrainerEnrollmentRemoteDataSource>(
      (ref) {
    return TrainerEnrollmentRemoteDataSource();
  },
);

final trainerEnrollmentRepositoryProvider =
Provider<TrainerEnrollmentRepository>(
      (ref) {
    return TrainerEnrollmentRepositoryImpl(
      ref.watch(
        trainerEnrollmentRemoteDataSourceProvider,
      ),
    );
  },
);

final trainerEnrollmentControllerProvider =
AsyncNotifierProvider<
    TrainerEnrollmentController,
    TrainerEnrollment?>(
  TrainerEnrollmentController.new,
);

class TrainerEnrollmentController
    extends AsyncNotifier<TrainerEnrollment?> {
  @override
  Future<TrainerEnrollment?> build() async {
    return null;
  }

  Future<TrainerEnrollment> enroll({
    required String gymId,
    required String displayName,
    required String email,
    required double monthlySalary,
    required DateTime startDate,
    String? specialization,
  }) async {
    state = const AsyncLoading();

    final result =
    await AsyncValue.guard(
          () {
        return ref
            .read(
          trainerEnrollmentRepositoryProvider,
        )
            .createEnrollment(
          gymId: gymId,
          displayName: displayName,
          email: email,
          monthlySalary: monthlySalary,
          startDate: startDate,
          specialization: specialization,
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