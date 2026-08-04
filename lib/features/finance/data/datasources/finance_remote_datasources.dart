import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/finance_transaction_model.dart';

class FinanceRemoteDataSource {
  FinanceRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  CollectionReference<
      Map<String, dynamic>>
  get _transactionsCollection {
    return _firestore.collection(
      'finance_transactions',
    );
  }

  Future<List<FinanceTransactionModel>>
  getTransactions({
    required String gymId,
    int limit = 20,
  }) async {
    final snapshot =
    await _transactionsCollection
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .orderBy(
      'date',
      descending: true,
    )
        .limit(limit)
        .get();

    return snapshot.docs
        .map(
      FinanceTransactionModel
          .fromFirestore,
    )
        .toList();
  }
}