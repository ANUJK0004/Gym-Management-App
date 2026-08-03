import '../entities/managed_trainer.dart';

abstract class TrainerManagementRepository {
  Future<List<ManagedTrainer>>
  getGymTrainers(
      String gymId,
      );

  Future<ManagedTrainer?>
  getTrainer(
      String trainerUid,
      );

  Future<List<ManagedTrainer>>
  searchTrainers(
      String gymId,
      String query,
      );

  Future<void> assignTrainerToGym({
    required String trainerUid,
    required String gymId,
  });

  Future<void> updateTrainer(
      ManagedTrainer trainer,
      );

  Future<void> removeTrainerFromGym(
      String trainerUid,
      );
}