import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_record.dart';

class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.id,
    required super.gymId,
    required super.userId,
    required super.userName,
    required super.userRole,
    required super.date,
    required super.checkInTime,
    super.userPhotoUrl,
    super.checkOutTime,
    super.status,
    super.method,
    super.membershipPlanName,
    super.specialization,
    super.durationMinutes,
  });

  factory AttendanceRecordModel.fromEntity(AttendanceRecord entity) {
    return AttendanceRecordModel(
      id: entity.id,
      gymId: entity.gymId,
      userId: entity.userId,
      userName: entity.userName,
      userPhotoUrl: entity.userPhotoUrl,
      userRole: entity.userRole,
      date: entity.date,
      checkInTime: entity.checkInTime,
      checkOutTime: entity.checkOutTime,
      status: entity.status,
      method: entity.method,
      membershipPlanName: entity.membershipPlanName,
      specialization: entity.specialization,
      durationMinutes: entity.durationMinutes,
    );
  }

  factory AttendanceRecordModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};

    DateTime checkIn = DateTime.now();
    if (data['checkInTime'] is Timestamp) {
      checkIn = (data['checkInTime'] as Timestamp).toDate();
    } else if (data['checkInTime'] is String) {
      checkIn = DateTime.tryParse(data['checkInTime'] as String) ?? DateTime.now();
    }

    DateTime? checkOut;
    if (data['checkOutTime'] is Timestamp) {
      checkOut = (data['checkOutTime'] as Timestamp).toDate();
    } else if (data['checkOutTime'] is String) {
      checkOut = DateTime.tryParse(data['checkOutTime'] as String);
    }

    AttendanceStatus status = AttendanceStatus.checkedIn;
    if (data['status'] == 'checkedOut' || data['status'] == 'checked_out') {
      status = AttendanceStatus.checkedOut;
    }

    AttendanceMethod method = AttendanceMethod.qrScan;
    if (data['method'] == 'manualOwner' || data['method'] == 'manual_owner') {
      method = AttendanceMethod.manualOwner;
    }

    int? duration = (data['durationMinutes'] as num?)?.toInt();
    if (duration == null && checkOut != null) {
      duration = checkOut.difference(checkIn).inMinutes;
    }

    return AttendanceRecordModel(
      id: snapshot.id,
      gymId: data['gymId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Member',
      userPhotoUrl: data['userPhotoUrl'] as String?,
      userRole: data['userRole'] as String? ?? 'member',
      date: data['date'] as String? ?? '',
      checkInTime: checkIn,
      checkOutTime: checkOut,
      status: status,
      method: method,
      membershipPlanName: data['membershipPlanName'] as String?,
      specialization: data['specialization'] as String?,
      durationMinutes: duration,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gymId': gymId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'userRole': userRole,
      'date': date,
      'checkInTime': Timestamp.fromDate(checkInTime),
      'checkOutTime': checkOutTime != null ? Timestamp.fromDate(checkOutTime!) : null,
      'status': status == AttendanceStatus.checkedOut ? 'checkedOut' : 'checkedIn',
      'method': method == AttendanceMethod.manualOwner ? 'manualOwner' : 'qrScan',
      'membershipPlanName': membershipPlanName,
      'specialization': specialization,
      'durationMinutes': durationMinutes,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
