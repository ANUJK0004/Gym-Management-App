import '../../domain/entities/owner_settings.dart';
import '../../domain/repositories/owner_settings_repository.dart';

import '../datasources/owner_settings_remote_datasource.dart';
import '../models/owner_settings_model.dart';

class OwnerSettingsRepositoryImpl
    implements OwnerSettingsRepository {
  OwnerSettingsRepositoryImpl(
      this._dataSource,
      );

  final OwnerSettingsRemoteDataSource
  _dataSource;

  @override
  Future<OwnerSettings?> getOwnerSettings({
    required String ownerId,
    required String gymId,
  }) {
    return _dataSource
        .getOwnerSettings(
      ownerId: ownerId,
      gymId: gymId,
    );
  }

  @override
  Future<void> updateOwnerSettings(
      OwnerSettings settings,
      ) {
    final model =
    OwnerSettingsModel(
      gymId: settings.gymId,
      ownerId: settings.ownerId,
      gymName: settings.gymName,
      address: settings.address,
      phone: settings.phone,
      website: settings.website,
      logoUrl: settings.logoUrl,
      operatingHours:
      settings.operatingHours,
      isVerified:
      settings.isVerified,
    );

    return _dataSource
        .updateOwnerSettings(
      model,
    );
  }
}