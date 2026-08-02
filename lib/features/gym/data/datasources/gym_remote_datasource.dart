import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/gym_model.dart';

class GymRemoteDataSource {
  GymRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
  get _gymsCollection {
    return _firestore.collection('gyms');
  }

  Future<GymModel> createGym(
      GymModel gym,
      ) async {
    // Firestore generates a unique document ID.
    final documentReference =
    _gymsCollection.doc();

    await documentReference.set(
      gym.toFirestore(),
    );

    // Return the actual Firestore document ID.
    return GymModel(
      id: documentReference.id,
      ownerId: gym.ownerId,
      name: gym.name,
      description: gym.description,
      address: gym.address,
      phone: gym.phone,
      email: gym.email,
      logoUrl: gym.logoUrl,
      createdAt: gym.createdAt,
    );
  }

  Future<GymModel?> getGym(
      String gymId,
      ) async {
    final document =
    await _gymsCollection
        .doc(gymId)
        .get();

    if (!document.exists) {
      return null;
    }

    return GymModel.fromFirestore(
      document,
    );
  }

  Future<GymModel?> getGymByOwnerId(
      String ownerId,
      ) async {
    final querySnapshot =
    await _gymsCollection
        .where(
      'ownerId',
      isEqualTo: ownerId,
    )
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    return GymModel.fromFirestore(
      querySnapshot.docs.first,
    );
  }

  Future<void> updateGym(
      GymModel gym,
      ) async {
    await _gymsCollection
        .doc(gym.id)
        .set(
      gym.toFirestore(),
      SetOptions(
        merge: true,
      ),
    );
  }

  Future<void> deleteGym(
      String gymId,
      ) async {
    await _gymsCollection
        .doc(gymId)
        .delete();
  }
}