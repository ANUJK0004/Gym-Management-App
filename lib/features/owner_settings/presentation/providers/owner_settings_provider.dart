import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:sweatsync/features/gym/domain/entities/gym.dart';
import 'package:sweatsync/features/gym/presentation/providers/gym_provider.dart';

import '../../data/datasources/owner_settings_remote_datasource.dart';
import '../../data/repositories/owner_settings_repository_impl.dart';
import '../../domain/entities/owner_settings.dart';
import '../../domain/repositories/owner_settings_repository.dart';

final ownerSettingsFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final ownerSettingsRemoteDataSourceProvider =
    Provider<OwnerSettingsRemoteDataSource>((ref) {
  return OwnerSettingsRemoteDataSource(
    ref.watch(ownerSettingsFirestoreProvider),
  );
});

final ownerSettingsRepositoryProvider =
    Provider<OwnerSettingsRepository>((ref) {
  return OwnerSettingsRepositoryImpl(
    ref.watch(ownerSettingsRemoteDataSourceProvider),
  );
});

final ownerSettingsStreamProvider =
    StreamProvider.autoDispose<OwnerSettings?>((ref) async* {
  final user = ref.watch(firebaseAuthProvider).currentUser;

  if (user == null) {
    yield null;
    return;
  }

  final gym = await ref.watch(ownerGymProvider.future);

  if (gym == null) {
    yield null;
    return;
  }

  final repository = ref.watch(ownerSettingsRepositoryProvider);

  yield* repository
      .streamOwnerSettings(
    ownerId: user.uid,
    gymId: gym.id,
  )
      .map((settings) {
    if (settings != null) {
      return settings.copyWith(
        gymName: settings.gymName ?? gym.name,
        address: settings.address ?? gym.address,
        phone: settings.phone ?? gym.phone,
        logoUrl: settings.logoUrl ?? gym.logoUrl,
      );
    }

    return OwnerSettings(
      gymId: gym.id,
      ownerId: user.uid,
      gymName: gym.name,
      address: gym.address,
      phone: gym.phone,
      website: 'https://sweatsync.app',
      logoUrl: gym.logoUrl,
      operatingHours: const {'display': '5:00 AM - 11:00 PM'},
      isVerified: true,
      pushNotifications: true,
      autoRenew: true,
      darkMode: true,
      maintenanceMode: false,
    );
  });
});

final ownerSettingsProvider = Provider<AsyncValue<OwnerSettings?>>((ref) {
  return ref.watch(ownerSettingsStreamProvider);
});

final ownerSettingsControllerProvider =
    AsyncNotifierProvider<OwnerSettingsController, void>(
  OwnerSettingsController.new,
);

class OwnerSettingsController extends AsyncNotifier<void> {
  late final OwnerSettingsRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.watch(ownerSettingsRepositoryProvider);
  }

  Future<OwnerSettings?> _getCurrentOrFallbackSettings() async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    final gym = await ref.read(ownerGymProvider.future);

    if (user == null || gym == null) return null;

    final existing = await _repository.getOwnerSettings(
      ownerId: user.uid,
      gymId: gym.id,
    );

    if (existing != null) {
      return existing;
    }

    return OwnerSettings(
      gymId: gym.id,
      ownerId: user.uid,
      gymName: gym.name,
      address: gym.address,
      phone: gym.phone,
      website: 'https://sweatsync.app',
      logoUrl: gym.logoUrl,
      operatingHours: const {'display': '5:00 AM - 11:00 PM'},
      isVerified: true,
      pushNotifications: true,
      autoRenew: true,
      darkMode: true,
      maintenanceMode: false,
    );
  }

  Future<bool> togglePushNotifications(bool value) async {
    final current = await _getCurrentOrFallbackSettings();
    if (current == null) return false;

    final updated = current.copyWith(pushNotifications: value);
    await _repository.updateOwnerSettings(updated);
    return true;
  }

  Future<bool> toggleAutoRenew(bool value) async {
    final current = await _getCurrentOrFallbackSettings();
    if (current == null) return false;

    final updated = current.copyWith(autoRenew: value);
    await _repository.updateOwnerSettings(updated);
    return true;
  }

  Future<bool> toggleDarkMode(bool value) async {
    final current = await _getCurrentOrFallbackSettings();
    if (current == null) return false;

    final updated = current.copyWith(darkMode: value);
    await _repository.updateOwnerSettings(updated);
    return true;
  }

  Future<bool> toggleMaintenanceMode(bool value) async {
    final current = await _getCurrentOrFallbackSettings();
    if (current == null) return false;

    final updated = current.copyWith(maintenanceMode: value);
    await _repository.updateOwnerSettings(updated);
    return true;
  }

  Future<bool> updateOperatingHours(String hoursDisplay) async {
    final current = await _getCurrentOrFallbackSettings();
    if (current == null) return false;

    final updated = current.copyWith(
      operatingHours: {
        'display': hoursDisplay.trim(),
      },
    );
    await _repository.updateOwnerSettings(updated);
    return true;
  }

  Future<bool> updateContactInfo({
    String? phone,
    String? website,
    String? address,
  }) async {
    final current = await _getCurrentOrFallbackSettings();
    if (current == null) return false;

    final updated = current.copyWith(
      phone: phone != null ? phone.trim() : current.phone,
      website: website != null ? website.trim() : current.website,
      address: address != null ? address.trim() : current.address,
    );
    await _repository.updateOwnerSettings(updated);

    final gym = await ref.read(ownerGymProvider.future);
    if (gym != null && (phone != null || address != null)) {
      final updatedGym = Gym(
        id: gym.id,
        ownerId: gym.ownerId,
        name: gym.name,
        description: gym.description,
        address: address != null ? address.trim() : gym.address,
        phone: phone != null ? phone.trim() : gym.phone,
        email: gym.email,
        logoUrl: gym.logoUrl,
        createdAt: gym.createdAt,
      );
      await ref.read(gymRepositoryProvider).updateGym(updatedGym);
      ref.invalidate(ownerGymProvider);
    }

    return true;
  }

  Future<DateTime?> recordBackup() async {
    final current = await _getCurrentOrFallbackSettings();
    if (current == null) return null;

    final now = DateTime.now();
    final updated = current.copyWith(lastBackupAt: now);
    await _repository.updateOwnerSettings(updated);
    return now;
  }
}