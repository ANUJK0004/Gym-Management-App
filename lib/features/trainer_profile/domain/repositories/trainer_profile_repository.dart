import '../entities/trainer_profile.dart';

abstract class TrainerProfileRepository {
  Stream<TrainerProfile> watchProfile({String? trainerId});
  Future<TrainerProfile> getProfile({String? trainerId});
  Future<TrainerProfile> updateProfile(TrainerProfile profile);
  Future<void> updateAvailability({
    required String trainerId,
    required TrainerAvailability availability,
  });
  Future<void> updateAccountSettings({
    required String trainerId,
    required TrainerAccountSettings settings,
  });
}
