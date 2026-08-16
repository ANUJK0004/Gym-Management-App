import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/entities/report_export_request.dart';
import '../models/report_export_result_model.dart';

class ReportRemoteDataSource {
  ReportRemoteDataSource(
      this._firestore, {
        FirebaseFunctions? functions,
      }) : _functions =
      functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>>
  get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>>
  _transactionsCollection(
      String gymId,
      ) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('financeTransactions');
  }

  CollectionReference<Map<String, dynamic>>
  _plansCollection(
      String gymId,
      ) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('membershipPlans');
  }

  Future<List<Map<String, dynamic>>> getMembers(
      String gymId,
      ) async {
    final snapshot =
    await _usersCollection
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .get();

    return snapshot.docs
        .where(
          (doc) => doc.data()['role'] == 'member',
    )
        .map(_normalizeDocument)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getTrainers(
      String gymId,
      ) async {
    final snapshot =
    await _usersCollection
        .where(
      'gymId',
      isEqualTo: gymId,
    )
        .get();

    return snapshot.docs
        .where(
          (doc) => doc.data()['role'] == 'trainer',
    )
        .map(_normalizeDocument)
        .toList();
  }

  Future<List<Map<String, dynamic>>>
  getFinanceTransactions(
      String gymId,
      ) async {
    final snapshot =
    await _transactionsCollection(gymId)
        .orderBy(
      'date',
      descending: true,
    )
        .get();

    return snapshot.docs
        .map(_normalizeDocument)
        .toList();
  }

  Future<List<Map<String, dynamic>>>
  getMembershipPlans(
      String gymId,
      ) async {
    final snapshot =
    await _plansCollection(gymId)
        .orderBy(
      'createdAt',
      descending: true,
    )
        .get();

    return snapshot.docs
        .map(_normalizeDocument)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAttendance(
      String gymId,
      ) async {
    final rootResults =
    <Map<String, dynamic>>[];

    try {
      final snapshot =
      await _firestore
          .collection('attendance')
          .where(
        'gymId',
        isEqualTo: gymId,
      )
          .get();

      rootResults.addAll(
        snapshot.docs.map(_normalizeDocument),
      );
    } catch (_) {}

    try {
      final snapshot =
      await _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('attendance')
          .get();

      rootResults.addAll(
        snapshot.docs.map(_normalizeDocument),
      );
    } catch (_) {}

    final unique =
    <String, Map<String, dynamic>>{};

    for (final record in rootResults) {
      final id =
          record['_id']?.toString() ??
              '${record['timestamp']}_${record['memberId']}';

      unique[id] = record;
    }

    return unique.values.toList();
  }

  Future<List<Map<String, dynamic>>>
  getNpsResponses(
      String gymId,
      ) async {
    try {
      final snapshot =
      await _firestore
          .collection('npsResponses')
          .where(
        'gymId',
        isEqualTo: gymId,
      )
          .get();

      return snapshot.docs
          .map(_normalizeDocument)
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ------------------------------------------------------------
  // REAL REPORT EXPORT
  // ------------------------------------------------------------

  Future<ReportExportResultModel> exportReport({
    required ReportExportRequest request,
  }) async {
    final callable =
    _functions.httpsCallable(
      'exportReport',
    );

    final result =
    await callable.call({
      'reportType':
      request.type.name,

      'sections':
      request.sections,

      'format':
      request.format.name,

      'period':
      request.period.name,

      'email':
      request.email,
    });

    final data =
    Map<String, dynamic>.from(
      result.data as Map,
    );

    return ReportExportResultModel.fromMap(
      data,
    );
  }

  Map<String, dynamic> _normalizeDocument(
      QueryDocumentSnapshot<
          Map<String, dynamic>> doc,
      ) {
    return {
      '_id': doc.id,
      ...doc.data(),
    };
  }
}