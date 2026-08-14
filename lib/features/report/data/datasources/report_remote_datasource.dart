import 'package:cloud_firestore/cloud_firestore.dart';

class ReportRemoteDataSource {
  ReportRemoteDataSource(
    this._firestore,
  );

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
      get _usersCollection =>
          _firestore.collection('users');

  CollectionReference<Map<String, dynamic>>
      _transactionsCollection(String gymId) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('financeTransactions');
  }

  CollectionReference<Map<String, dynamic>>
      _plansCollection(String gymId) {
    return _firestore
        .collection('gyms')
        .doc(gymId)
        .collection('membershipPlans');
  }

  Future<List<Map<String, dynamic>>> getMembers(
      String gymId) async {
    final snapshot = await _usersCollection
        .where('gymId', isEqualTo: gymId)
        .get();

    return snapshot.docs
        .where((doc) => doc.data()['role'] == 'member')
        .map(_normalizeDocument)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getTrainers(
      String gymId) async {
    final snapshot = await _usersCollection
        .where('gymId', isEqualTo: gymId)
        .get();

    return snapshot.docs
        .where((doc) => doc.data()['role'] == 'trainer')
        .map(_normalizeDocument)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getFinanceTransactions(
      String gymId) async {
    final snapshot = await _transactionsCollection(gymId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map(_normalizeDocument).toList();
  }

  Future<List<Map<String, dynamic>>> getMembershipPlans(
      String gymId) async {
    final snapshot = await _plansCollection(gymId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map(_normalizeDocument).toList();
  }

  /// Attendance is intentionally isolated here so the Reports feature
  /// is ready for the Attendance feature without coupling Report UI to
  /// an attendance implementation that does not exist yet.
  ///
  /// Supported layouts:
  ///   attendance/{id}
  /// and, as a fallback:
  ///   gyms/{gymId}/attendance/{id}
  ///
  /// The parser in the repository accepts checkInAt, checkedInAt,
  /// timestamp, date or checkInTime as the timestamp field.
  Future<List<Map<String, dynamic>>> getAttendance(
      String gymId) async {
    final rootResults = <Map<String, dynamic>>[];

    try {
      final snapshot = await _firestore
          .collection('attendance')
          .where('gymId', isEqualTo: gymId)
          .get();

      rootResults.addAll(
        snapshot.docs.map(_normalizeDocument),
      );
    } catch (_) {
      // The collection may not exist or may not yet be readable.
      // Reports continue to work with zero attendance data.
    }

    try {
      final snapshot = await _firestore
          .collection('gyms')
          .doc(gymId)
          .collection('attendance')
          .get();

      rootResults.addAll(
        snapshot.docs.map(_normalizeDocument),
      );
    } catch (_) {
      // Same compatibility behavior as above.
    }

    final unique = <String, Map<String, dynamic>>{};

    for (final record in rootResults) {
      final id = record['_id']?.toString() ??
          '${record['timestamp']}_${record['memberId']}';
      unique[id] = record;
    }

    return unique.values.toList();
  }

  Future<List<Map<String, dynamic>>> getNpsResponses(
      String gymId) async {
    try {
      final snapshot = await _firestore
          .collection('npsResponses')
          .where('gymId', isEqualTo: gymId)
          .get();

      return snapshot.docs.map(_normalizeDocument).toList();
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> _normalizeDocument(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return {
      '_id': doc.id,
      ...doc.data(),
    };
  }
}
