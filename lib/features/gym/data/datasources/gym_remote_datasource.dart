import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/gym_model.dart';

class GymRemoteDataSource {
  GymRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _gymsCollection {
    return _firestore.collection('gyms');
  }

  Future<GymModel> createGym(GymModel gym) async {
    await _gymsCollection.doc(gym.id).set(gym.toFirestore());

    return gym;
  }

  Future<GymModel?> getGym(String gymId) async {
    final document = await _gymsCollection.doc(gymId).get();

    if (!document.exists) {
      return null;
    }

    return GymModel.fromFirestore(document);
  }

  Future<void> updateGym(GymModel gym) async {
    await _gymsCollection
        .doc(gym.id)
        .set(gym.toFirestore(), SetOptions(merge: true));
  }

  Future<void> deleteGym(String gymId) async {
    await _gymsCollection.doc(gymId).delete();
  }
}
