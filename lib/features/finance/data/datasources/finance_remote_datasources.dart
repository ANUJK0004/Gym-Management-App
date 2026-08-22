import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/entities/finance_export_request.dart';
import '../../domain/entities/finance_transaction.dart';

import '../models/finance_export_result_model.dart';
import '../models/finance_transaction_model.dart';

class FinanceRemoteDataSource {
  FinanceRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _firestore =
      firestore ?? FirebaseFirestore.instance,
        _functions =
            functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>>
  _transactionsCollection(
      String gymId,
      ) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('financeTransactions');
  }

  Future<List<FinanceTransactionModel>>
  getTransactions({
    required String gymId,
    int limit = 20,
  }) async {
    final snapshot =
    await _transactionsCollection(gymId)
        .orderBy(
      'date',
      descending: true,
    )
        .limit(limit)
        .get();

    return snapshot.docs
        .map(
          (doc) =>
          FinanceTransactionModel
              .fromFirestore(doc),
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
    )
        .doc(
      transaction.id.isEmpty
          ? null
          : transaction.id,
    )
        .set(
      model.toFirestore(),
    );
  }

  Future<FinanceExportResultModel>
  exportFinanceReport(
      FinanceExportRequest request,
      ) async {
    final callable =
    _functions.httpsCallable(
      'exportFinanceReport',
    );

    final result =
    await callable.call({
      'gymId': request.gymId,

      'format':
      request.format.name,

      'period':
      request.period.name,

      'sections': request.sections
          .map(
            (section) =>
        section.name,
      )
          .toList(),

      'email':
      request.hasEmail
          ? request.email!
          .trim()
          .toLowerCase()
          : null,
    });

    final data =
    Map<String, dynamic>.from(
      result.data as Map,
    );

    return FinanceExportResultModel
        .fromMap(data);
  }
}