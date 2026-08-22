import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';
import '../models/attendance_record_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._remoteDataSource);

  final AttendanceRemoteDataSource _remoteDataSource;

  @override
  Stream<List<AttendanceRecord>> streamGymAttendanceForDate({
    required String gymId,
    required String date,
  }) {
    return _remoteDataSource.streamGymAttendanceForDate(
      gymId: gymId,
      date: date,
    );
  }

  @override
  Stream<List<AttendanceRecord>> streamUserAttendanceHistory({
    required String gymId,
    required String userId,
  }) {
    return _remoteDataSource.streamUserAttendanceHistory(
      gymId: gymId,
      userId: userId,
    );
  }

  @override
  Future<AttendanceRecord?> getTodayUserAttendance({
    required String gymId,
    required String userId,
    required String date,
  }) {
    return _remoteDataSource.getTodayUserAttendance(
      gymId: gymId,
      userId: userId,
      date: date,
    );
  }

  @override
  Future<AttendanceRecord> checkIn({
    required AttendanceRecord record,
  }) {
    return _remoteDataSource.checkIn(
      AttendanceRecordModel.fromEntity(record),
    );
  }

  @override
  Future<AttendanceRecord> checkOut({
    required String gymId,
    required String recordId,
    required DateTime checkOutTime,
  }) {
    return _remoteDataSource.checkOut(
      gymId: gymId,
      recordId: recordId,
      checkOutTime: checkOutTime,
    );
  }

  @override
  Future<void> deleteAttendanceRecord({
    required String gymId,
    required String recordId,
  }) {
    return _remoteDataSource.deleteAttendanceRecord(
      gymId: gymId,
      recordId: recordId,
    );
  }
}
