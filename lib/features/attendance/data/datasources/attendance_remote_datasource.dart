import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_record.dart';
import '../models/attendance_record_model.dart';

class AttendanceRemoteDataSource {
  AttendanceRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _attendanceCollection(String gymId) {
    return _firestore.collection('gyms').doc(gymId).collection('attendance');
  }

  Stream<List<AttendanceRecordModel>> streamGymAttendanceForDate({
    required String gymId,
    required String date,
  }) {
    return _attendanceCollection(gymId)
        .where('date', isEqualTo: date)
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs
          .map((doc) => AttendanceRecordModel.fromFirestore(doc))
          .toList();
      // Sort newest check-in first in-memory
      records.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
      return records;
    });
  }

  Stream<List<AttendanceRecordModel>> streamUserAttendanceHistory({
    required String gymId,
    required String userId,
  }) {
    return _attendanceCollection(gymId)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs
          .map((doc) => AttendanceRecordModel.fromFirestore(doc))
          .toList();
      records.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
      return records;
    });
  }

  Future<AttendanceRecordModel?> getTodayUserAttendance({
    required String gymId,
    required String userId,
    required String date,
  }) async {
    final query = await _attendanceCollection(gymId)
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: date)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    return AttendanceRecordModel.fromFirestore(query.docs.first);
  }

  Future<AttendanceRecordModel> checkIn(AttendanceRecordModel model) async {
    final docRef = _attendanceCollection(model.gymId).doc(model.id);
    final data = model.toFirestore();
    data['createdAt'] = FieldValue.serverTimestamp();

    await docRef.set(data, SetOptions(merge: true));
    return model;
  }

  Future<AttendanceRecordModel> checkOut({
    required String gymId,
    required String recordId,
    required DateTime checkOutTime,
  }) async {
    final docRef = _attendanceCollection(gymId).doc(recordId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      throw Exception('Attendance record not found.');
    }

    final currentRecord = AttendanceRecordModel.fromFirestore(snapshot);
    final duration = checkOutTime.difference(currentRecord.checkInTime).inMinutes;

    final updateData = <String, dynamic>{
      'checkOutTime': Timestamp.fromDate(checkOutTime),
      'status': 'checkedOut',
      'durationMinutes': duration > 0 ? duration : 0,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await docRef.update(updateData);

    return AttendanceRecordModel.fromEntity(
      currentRecord.copyWith(
        checkOutTime: checkOutTime,
        status: AttendanceStatus.checkedOut,
        durationMinutes: duration > 0 ? duration : 0,
      ),
    );
  }

  Future<void> deleteAttendanceRecord({
    required String gymId,
    required String recordId,
  }) async {
    await _attendanceCollection(gymId).doc(recordId).delete();
  }
}
