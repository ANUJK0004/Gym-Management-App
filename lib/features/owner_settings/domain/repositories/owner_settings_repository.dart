import '../entities/owner_settings.dart';

abstract class OwnerSettingsRepository {
  Stream<OwnerSettings?> streamOwnerSettings({
    required String ownerId,
    required String gymId,
  });

  Future<OwnerSettings?> getOwnerSettings({
    required String ownerId,
    required String gymId,
  });

  Future<void> updateOwnerSettings(
    OwnerSettings settings,
  );
}