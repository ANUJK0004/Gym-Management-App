import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/trainer_profile_remote_datasource.dart';
import '../../data/repositories/trainer_profile_repository_impl.dart';
import '../../domain/entities/trainer_profile.dart';
import '../../domain/repositories/trainer_profile_repository.dart';

final trainerProfileRemoteDataSourceProvider =
    Provider<TrainerProfileRemoteDataSource>((ref) {
  return TrainerProfileRemoteDataSource();
});

final trainerProfileRepositoryProvider =
    Provider<TrainerProfileRepository>((ref) {
  return TrainerProfileRepositoryImpl(
    ref.watch(trainerProfileRemoteDataSourceProvider),
  );
});

class TrainerProfileController extends AsyncNotifier<TrainerProfile> {
  late final TrainerProfileRepository _repository;

  @override
  Future<TrainerProfile> build() async {
    _repository = ref.watch(trainerProfileRepositoryProvider);
    return _repository.getProfile(trainerId: 'trainer_001');
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.getProfile(trainerId: 'trainer_001');
    });
  }

  Future<void> updateProfile(TrainerProfile updatedProfile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.updateProfile(updatedProfile);
    });
  }

  Future<void> toggleNotifications(bool enabled) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(
      accountSettings: current.accountSettings.copyWith(
        notificationsEnabled: enabled,
      ),
    );
    await updateProfile(updated);
  }

  Future<void> toggleClientMessaging(bool enabled) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(
      accountSettings: current.accountSettings.copyWith(
        clientMessagingEnabled: enabled,
      ),
    );
    await updateProfile(updated);
  }

  Future<void> updateAvailability({
    String? workingHours,
    String? daysAvailable,
    String? sessionDuration,
  }) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(
      availability: current.availability.copyWith(
        workingHours: workingHours,
        daysAvailable: daysAvailable,
        sessionDuration: sessionDuration,
      ),
    );
    await updateProfile(updated);
  }
}

final trainerProfileControllerProvider =
    AsyncNotifierProvider<TrainerProfileController, TrainerProfile>(
  TrainerProfileController.new,
);

final trainerProfileProvider = Provider<AsyncValue<TrainerProfile>>((ref) {
  return ref.watch(trainerProfileControllerProvider);
});
