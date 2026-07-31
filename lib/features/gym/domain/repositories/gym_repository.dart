import '../entities/gym.dart';

abstract class GymRepository {
  Future<Gym> createGym(
      Gym gym,
      );

  Future<Gym?> getGym(
      String gymId,
      );

  Future<void> updateGym(
      Gym gym,
      );

  Future<void> deleteGym(
      String gymId,
      );
}