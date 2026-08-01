import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../gym/domain/entities/gym.dart';
import '../../../gym/presentation/providers/gym_provider.dart';

import '../../../profile/domain/repositories/user_profile_repository.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';

final ownerSetupProvider =
AsyncNotifierProvider<OwnerSetupController, void>(
  OwnerSetupController.new,
);

class OwnerSetupController
    extends AsyncNotifier<void> {
  late final UserProfileRepository
  _profileRepository;

  @override
  Future<void> build() async {
    _profileRepository =
        ref.watch(
          userProfileRepositoryProvider,
        );
  }

  Future<void> completeOwnerSetup({
    required String uid,
    required String gymName,
    String? description,
    String? address,
    String? phone,
    String? email,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () async {
        final gymRepository =
        ref.read(
          gymRepositoryProvider,
        );

        final gymId =
        const Uuid().v4();

        final gym = Gym(
          id: gymId,
          ownerId: uid,
          name: gymName.trim(),
          description:
          _cleanValue(description),
          address:
          _cleanValue(address),
          phone:
          _cleanValue(phone),
          email:
          _cleanValue(email),
          createdAt:
          DateTime.now(),
        );

        // 1. Create gym
        await gymRepository.createGym(
          gym,
        );

        // 2. Get current user profile
        final profile =
        await _profileRepository
            .getUserProfile(uid);

        if (profile == null) {
          throw Exception(
            'Owner profile not found.',
          );
        }

        // 3. Update owner profile
        final updatedProfile =
        profile.copyWith(
          gymId: gymId,
          profileCompleted: true,
        );

        await _profileRepository
            .updateUserProfile(
          updatedProfile,
        );
      },
    );
  }

  String? _cleanValue(
      String? value,
      ) {
    if (value == null) {
      return null;
    }

    final trimmed =
    value.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}