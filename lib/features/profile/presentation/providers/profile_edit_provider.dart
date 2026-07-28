import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import 'user_profile_provider.dart';

class ProfileEditState {
  const ProfileEditState({
    this.displayName = '',
    this.gender,
    this.height,
    this.weight,
    this.fitnessGoal,
    this.activityLevel,
    this.isSaving = false,
  });

  final String displayName;
  final String? gender;

  final double? height;
  final double? weight;

  final String? fitnessGoal;
  final String? activityLevel;

  final bool isSaving;

  ProfileEditState copyWith({
    String? displayName,
    String? gender,
    double? height,
    double? weight,
    String? fitnessGoal,
    String? activityLevel,
    bool? isSaving,
  }) {
    return ProfileEditState(
      displayName:
      displayName ??
          this.displayName,

      gender:
      gender ??
          this.gender,

      height:
      height ??
          this.height,

      weight:
      weight ??
          this.weight,

      fitnessGoal:
      fitnessGoal ??
          this.fitnessGoal,

      activityLevel:
      activityLevel ??
          this.activityLevel,

      isSaving:
      isSaving ??
          this.isSaving,
    );
  }
}

class ProfileEditNotifier
    extends Notifier<ProfileEditState> {

  late final UserProfileRepository
  _repository;

  UserProfile? _originalProfile;

  @override
  ProfileEditState build() {
    _repository =
        ref.watch(
          userProfileRepositoryProvider,
        );

    return const ProfileEditState();
  }

  void initialize(
      UserProfile profile,
      ) {
    _originalProfile = profile;

    state = ProfileEditState(
      displayName:
      profile.displayName ??
          '',

      gender:
      profile.gender,

      height:
      profile.height,

      weight:
      profile.weight,

      fitnessGoal:
      profile.fitnessGoal,

      activityLevel:
      profile.activityLevel,
    );
  }

  void setDisplayName(
      String value,
      ) {
    state = state.copyWith(
      displayName: value,
    );
  }

  void setGender(
      String value,
      ) {
    state = state.copyWith(
      gender: value,
    );
  }

  void setHeight(
      double? value,
      ) {
    state = state.copyWith(
      height: value,
    );
  }

  void setWeight(
      double? value,
      ) {
    state = state.copyWith(
      weight: value,
    );
  }

  void setFitnessGoal(
      String value,
      ) {
    state = state.copyWith(
      fitnessGoal: value,
    );
  }

  void setActivityLevel(
      String value,
      ) {
    state = state.copyWith(
      activityLevel: value,
    );
  }

  Future<void> saveProfile() async {
    final profile =
        _originalProfile;

    if (profile == null) {
      throw Exception(
        'Profile has not been initialized.',
      );
    }

    if (state.displayName
        .trim()
        .isEmpty) {
      throw Exception(
        'Display name cannot be empty.',
      );
    }

    if (state.height == null ||
        state.height! <= 0) {
      throw Exception(
        'Please enter a valid height.',
      );
    }

    if (state.weight == null ||
        state.weight! <= 0) {
      throw Exception(
        'Please enter a valid weight.',
      );
    }

    state = state.copyWith(
      isSaving: true,
    );

    try {
      final updatedProfile =
      profile.copyWith(
        displayName:
        state.displayName.trim(),

        gender:
        state.gender,

        height:
        state.height,

        weight:
        state.weight,

        fitnessGoal:
        state.fitnessGoal,

        activityLevel:
        state.activityLevel,
      );

      await _repository
          .updateUserProfile(
        updatedProfile,
      );
    } finally {
      state = state.copyWith(
        isSaving: false,
      );
    }
  }
}

final profileEditProvider =
NotifierProvider<
    ProfileEditNotifier,
    ProfileEditState>(
  ProfileEditNotifier.new,
);