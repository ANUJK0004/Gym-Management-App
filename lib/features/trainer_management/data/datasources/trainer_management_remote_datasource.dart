import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/managed_trainer_model.dart';

class TrainerManagementRemoteDataSource {
  TrainerManagementRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  CollectionReference<
      Map<String, dynamic>> get _usersCollection {
    return _firestore.collection(
      'users',
    );
  }

  // ----------------------------------------------------------
  // GET ALL TRAINERS OF A GYM
  // ----------------------------------------------------------

  Future<List<ManagedTrainerModel>>
  getGymTrainers(
      String gymId,
      ) async {
    final snapshot =
    await _usersCollection
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .where(
      'role',
      isEqualTo: 'trainer',
    )
        .get();

    return snapshot.docs
        .map(
      ManagedTrainerModel
          .fromFirestore,
    )
        .toList();
  }

  // ----------------------------------------------------------
  // GET SINGLE TRAINER
  // ----------------------------------------------------------

  Future<ManagedTrainerModel?>
  getTrainer(
      String trainerUid,
      ) async {
    final document =
    await _usersCollection
        .doc(trainerUid)
        .get();

    if (!document.exists) {
      return null;
    }

    final data =
    document.data();

    if (data == null) {
      return null;
    }

    if (data['role'] !=
        'trainer') {
      return null;
    }

    return ManagedTrainerModel
        .fromFirestore(
      document,
    );
  }

  // ----------------------------------------------------------
  // SEARCH TRAINERS
  // ----------------------------------------------------------

  Future<List<ManagedTrainerModel>>
  searchTrainers(
      String gymId,
      String query,
      ) async {
    final snapshot =
    await _usersCollection
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .where(
      'role',
      isEqualTo: 'trainer',
    )
        .get();

    final normalizedQuery =
    query
        .trim()
        .toLowerCase();

    return snapshot.docs
        .map(
      ManagedTrainerModel
          .fromFirestore,
    )
        .where(
          (trainer) {
        final name =
            trainer.displayName
                ?.toLowerCase() ??
                '';

        final email =
        trainer.email
            .toLowerCase();

        final specialization =
            trainer.specialization
                ?.toLowerCase() ??
                '';

        return name.contains(
          normalizedQuery,
        ) ||
            email.contains(
              normalizedQuery,
            ) ||
            specialization
                .contains(
              normalizedQuery,
            );
      },
    )
        .toList();
  }

  // ----------------------------------------------------------
  // ASSIGN TRAINER
  // ----------------------------------------------------------

  Future<void>
  assignTrainerToGym({
    required String trainerUid,
    required String gymId,
  }) async {
    await _usersCollection
        .doc(trainerUid)
        .update({
      'gymId': gymId,
      'role': 'trainer',
    });
  }

  // ----------------------------------------------------------
  // UPDATE TRAINER
  // ----------------------------------------------------------

  Future<void> updateTrainer(
      ManagedTrainerModel trainer,
      ) async {
    await _usersCollection
        .doc(trainer.uid)
        .set(
      trainer.toFirestore(),
      SetOptions(
        merge: true,
      ),
    );
  }

  // ----------------------------------------------------------
  // REMOVE FROM GYM
  // ----------------------------------------------------------

  Future<void>
  removeTrainerFromGym(
      String trainerUid,
      ) async {
    await _usersCollection
        .doc(trainerUid)
        .update({
      'gymId':
      FieldValue.delete(),
    });
  }
}