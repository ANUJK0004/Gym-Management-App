import '../entities/attendance_record.dart';

abstract class AttendanceRepository {
  Stream<List<AttendanceRecord>> streamGymAttendanceForDate({
    required String gymId,
    required String date,
  });

  Stream<List<AttendanceRecord>> streamUserAttendanceHistory({
    required String gymId,
    required String userId,
  });

  Future<AttendanceRecord?> getTodayUserAttendance({
    required String gymId,
    required String userId,
    required String date,
  });

  Future<AttendanceRecord> checkIn({
    required AttendanceRecord record,
  });

  Future<AttendanceRecord> checkOut({
    required String gymId,
    required String recordId,
    required DateTime checkOutTime,
  });

  Future<void> deleteAttendanceRecord({
    required String gymId,
    required String recordId,
  });
}
