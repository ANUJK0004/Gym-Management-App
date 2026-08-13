import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/managed_trainer_model.dart';

class TrainerManagementRemoteDataSource {
  TrainerManagementRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
  get _usersCollection {
    return _firestore.collection('users');
  }

  // ----------------------------------------------------------
  // GET TRAINERS OF A GYM
  // ----------------------------------------------------------

  Future<List<ManagedTrainerModel>> getGymTrainers(
      String gymId,
      ) async {
    final snapshot = await _usersCollection
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
      ManagedTrainerModel.fromFirestore,
    )
        .toList();
  }

  // ----------------------------------------------------------
  // GET SINGLE TRAINER
  // ----------------------------------------------------------

  Future<ManagedTrainerModel?> getTrainer(
      String trainerUid,
      ) async {
    final document =
    await _usersCollection.doc(trainerUid).get();

    if (!document.exists) {
      return null;
    }

    final data = document.data();

    if (data == null ||
        data['role'] != 'trainer') {
      return null;
    }

    return ManagedTrainerModel.fromFirestore(
      document,
    );
  }

  // ----------------------------------------------------------
  // SEARCH ELIGIBLE TRAINERS
  // ----------------------------------------------------------

  Future<List<ManagedTrainerModel>> searchTrainers({
    required String gymId,
    required String query,
  }) async {
    final normalizedQuery =
    query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    final currentGymSnapshot =
    await _usersCollection
        .where(
      'role',
      isEqualTo: 'trainer',
    )
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .get();

    final allTrainerSnapshot =
    await _usersCollection
        .where(
      'role',
      isEqualTo: 'trainer',
    )
        .get();

    final Map<String, ManagedTrainerModel>
    trainers = {};

    for (final document
    in currentGymSnapshot.docs) {
      final trainer =
      ManagedTrainerModel.fromFirestore(
        document,
      );

      trainers[trainer.uid] = trainer;
    }

    for (final document
    in allTrainerSnapshot.docs) {
      final trainer =
      ManagedTrainerModel.fromFirestore(
        document,
      );

      // Only add unassigned trainers.
      if (!trainer.isAssignedToGym) {
        trainers[trainer.uid] = trainer;
      }
    }

    return trainers.values.where(
          (trainer) {
        final name =
            trainer.displayName?.toLowerCase() ?? '';

        final email =
        trainer.email.toLowerCase();

        final specialization =
            trainer.specialization?.toLowerCase() ?? '';

        final phone =
            trainer.phone?.toLowerCase() ?? '';

        return name.contains(normalizedQuery) ||
            email.contains(normalizedQuery) ||
            specialization.contains(normalizedQuery) ||
            phone.contains(normalizedQuery);
      },
    ).toList();
  }

  // ----------------------------------------------------------
  // EXACT EMAIL LOOKUP
  // ----------------------------------------------------------

  Future<ManagedTrainerModel?>
  findEligibleTrainerByEmail({
    required String email,
    required String gymId,
  }) async {
    final normalizedEmail =
    email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      return null;
    }

    // First check trainer belonging to this gym.
    final currentGymSnapshot =
    await _usersCollection
        .where(
      'role',
      isEqualTo: 'trainer',
    )
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .where(
      'email',
      isEqualTo: normalizedEmail,
    )
        .limit(1)
        .get();

    if (currentGymSnapshot.docs.isNotEmpty) {
      return ManagedTrainerModel.fromFirestore(
        currentGymSnapshot.docs.first,
      );
    }

    // Then check unassigned trainer accounts.
    final unassignedSnapshot =
    await _usersCollection
        .where(
      'role',
      isEqualTo: 'trainer',
    )
        .where(
      'gymId',
      isNull: true,
    )
        .where(
      'email',
      isEqualTo: normalizedEmail,
    )
        .limit(1)
        .get();

    if (unassignedSnapshot.docs.isNotEmpty) {
      return ManagedTrainerModel.fromFirestore(
        unassignedSnapshot.docs.first,
      );
    }

    return null;
  }

  // ----------------------------------------------------------
  // ASSIGN TRAINER
  // ----------------------------------------------------------

  Future<void> assignTrainerToGym({
    required String trainerUid,
    required String gymId,
  }) async {
    final trainerReference =
    _usersCollection.doc(trainerUid);

    await _firestore.runTransaction(
          (transaction) async {
        final snapshot =
        await transaction.get(
          trainerReference,
        );

        if (!snapshot.exists) {
          throw Exception(
            'Trainer account not found.',
          );
        }

        final data = snapshot.data();

        if (data == null) {
          throw Exception(
            'Trainer profile not found.',
          );
        }

        if (data['role'] != 'trainer') {
          throw Exception(
            'This account is not a trainer account.',
          );
        }

        final existingGymId =
        data['gymId'] as String?;

        if (existingGymId != null &&
            existingGymId.isNotEmpty) {
          if (existingGymId == gymId) {
            throw Exception(
              'This trainer is already assigned to your gym.',
            );
          }

          throw Exception(
            'This trainer belongs to another gym.',
          );
        }

        transaction.update(
          trainerReference,
          {
            'gymId': gymId,
            'status': 'active',
            'joinedAt':
            FieldValue.serverTimestamp(),
            'updatedAt':
            FieldValue.serverTimestamp(),
          },
        );
      },
    );
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
      SetOptions(merge: true),
    );
  }

  // ----------------------------------------------------------
  // REMOVE FROM GYM
  // ----------------------------------------------------------

  Future<void> removeTrainerFromGym(
      String trainerUid,
      ) async {
    await _usersCollection.doc(trainerUid).update({
      'gymId': FieldValue.delete(),
      'status': 'inactive',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}