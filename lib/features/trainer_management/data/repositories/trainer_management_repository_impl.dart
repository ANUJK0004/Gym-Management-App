import '../../domain/entities/managed_trainer.dart';
import '../../domain/repositories/trainer_management_repository.dart';

import '../datasources/trainer_management_remote_datasource.dart';
import '../models/managed_trainer_model.dart';

class TrainerManagementRepositoryImpl
    implements TrainerManagementRepository {
  TrainerManagementRepositoryImpl(
      this._dataSource,
      );

  final TrainerManagementRemoteDataSource
  _dataSource;

  @override
  Future<List<ManagedTrainer>>
  getGymTrainers(
      String gymId,
      ) {
    return _dataSource
        .getGymTrainers(
      gymId,
    );
  }

  @override
  Future<ManagedTrainer?>
  getTrainer(
      String trainerUid,
      ) {
    return _dataSource
        .getTrainer(
      trainerUid,
    );
  }

  @override
  Future<List<ManagedTrainer>>
  searchTrainers(
      String gymId,
      String query,
      ) {
    return _dataSource
        .searchTrainers(
      gymId,
      query,
    );
  }

  @override
  Future<void>
  assignTrainerToGym({
    required String trainerUid,
    required String gymId,
  }) {
    return _dataSource
        .assignTrainerToGym(
      trainerUid: trainerUid,
      gymId: gymId,
    );
  }

  @override
  Future<void> updateTrainer(
      ManagedTrainer trainer,
      ) {
    final model =
    ManagedTrainerModel(
      uid: trainer.uid,
      email: trainer.email,
      gymId: trainer.gymId,
      displayName:
      trainer.displayName,
      photoUrl:
      trainer.photoUrl,
      phone:
      trainer.phone,
      specialization:
      trainer.specialization,
      bio: trainer.bio,
      experienceYears:
      trainer.experienceYears,
      status:
      trainer.status,
      joinedAt:
      trainer.joinedAt,
    );

    return _dataSource
        .updateTrainer(
      model,
    );
  }

  @override
  Future<void>
  removeTrainerFromGym(
      String trainerUid,
      ) {
    return _dataSource
        .removeTrainerFromGym(
      trainerUid,
    );
  }
}