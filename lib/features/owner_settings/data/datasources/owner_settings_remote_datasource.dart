import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/owner_settings_model.dart';

class OwnerSettingsRemoteDataSource {
  OwnerSettingsRemoteDataSource(
    this._firestore,
  );

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _settingsCollection {
    return _firestore.collection(
      'owner_settings',
    );
  }

  Stream<OwnerSettingsModel?> streamOwnerSettings({
    required String ownerId,
    required String gymId,
  }) {
    return _settingsCollection
        .where('ownerId', isEqualTo: ownerId)
        .where('gymId', isEqualTo: gymId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      return OwnerSettingsModel.fromFirestore(snapshot.docs.first);
    });
  }

  Future<OwnerSettingsModel?> getOwnerSettings({
    required String ownerId,
    required String gymId,
  }) async {
    final snapshot = await _settingsCollection
        .where(
          'ownerId',
          isEqualTo: ownerId,
        )
        .where(
          'gymId',
          isEqualTo: gymId,
        )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return OwnerSettingsModel.fromFirestore(
      snapshot.docs.first,
    );
  }

  Future<void> updateOwnerSettings(
    OwnerSettingsModel settings,
  ) async {
    final snapshot = await _settingsCollection
        .where(
          'ownerId',
          isEqualTo: settings.ownerId,
        )
        .where(
          'gymId',
          isEqualTo: settings.gymId,
        )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      final document = _settingsCollection.doc();
      await document.set(
        settings.toFirestore(),
      );
      return;
    }

    await snapshot.docs.first.reference.set(
      settings.toFirestore(),
      SetOptions(
        merge: true,
      ),
    );
  }
}