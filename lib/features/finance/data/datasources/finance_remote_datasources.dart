import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/finance_transaction.dart';
import '../models/finance_transaction_model.dart';

class FinanceRemoteDataSource {
  FinanceRemoteDataSource(
      this._firestore,
      );

  final FirebaseFirestore _firestore;

  /// Returns the financeTransactions subcollection
  /// inside a particular gym document.
  CollectionReference<Map<String, dynamic>> _transactionsCollection(
      String gymId,
      ) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('financeTransactions');
  }

  Future<List<FinanceTransactionModel>> getTransactions({
    required String gymId,
    int limit = 20,
  }) async {
    final snapshot = await _transactionsCollection(gymId)
        .orderBy(
      'date',
      descending: true,
    )
        .limit(limit)
        .get();

    return snapshot.docs
        .map(
          (doc) => FinanceTransactionModel.fromFirestore(doc),
    )
        .toList();
  }

  Future<void> createTransaction(
      FinanceTransaction transaction,
      ) async {
    final model =
    FinanceTransactionModel(
      id: transaction.id,
      gymId: transaction.gymId,
      title: transaction.title,
      amount: transaction.amount,
      type: transaction.type,
      date: transaction.date,
      category: transaction.category,
      description: transaction.description,
      memberId: transaction.memberId,
      membershipPlanId:
      transaction.membershipPlanId,
    );

    await _transactionsCollection(
      transaction.gymId,
    ).doc(
      transaction.id.isEmpty
          ? null
          : transaction.id,
    ).set(
      model.toFirestore(),
    );
  }
}