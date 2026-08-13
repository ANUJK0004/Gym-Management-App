import '../entities/managed_trainer.dart';

abstract class TrainerManagementRepository {
  Future<List<ManagedTrainer>> getGymTrainers(
      String gymId,
      );

  Future<ManagedTrainer?> getTrainer(
      String trainerUid,
      );

  /// Returns:
  /// - trainers belonging to this gym
  /// - trainers not assigned to any gym
  ///
  /// It must never return trainers belonging
  /// to another gym.
  Future<List<ManagedTrainer>> searchTrainers({
    required String gymId,
    required String query,
  });

  /// Exact email lookup using the same eligibility
  /// rules as search.
  Future<ManagedTrainer?> findEligibleTrainerByEmail({
    required String email,
    required String gymId,
  });

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