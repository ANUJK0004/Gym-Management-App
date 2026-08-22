class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.gymId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.date,
    required this.checkInTime,
    this.userPhotoUrl,
    this.checkOutTime,
    this.status = AttendanceStatus.checkedIn,
    this.method = AttendanceMethod.qrScan,
    this.membershipPlanName,
    this.specialization,
    this.durationMinutes,
  });

  final String id;
  final String gymId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String userRole; // 'member' | 'trainer'
  final String date; // 'YYYY-MM-DD'
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final AttendanceStatus status;
  final AttendanceMethod method;
  final String? membershipPlanName; // for members
  final String? specialization; // for trainers
  final int? durationMinutes;

  bool get isCurrentlyInGym => status == AttendanceStatus.checkedIn && checkOutTime == null;
  bool get isCheckedOut => status == AttendanceStatus.checkedOut || checkOutTime != null;
  bool get isMember => userRole.toLowerCase() == 'member';
  bool get isTrainer => userRole.toLowerCase() == 'trainer';

  AttendanceRecord copyWith({
    String? id,
    String? gymId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? userRole,
    String? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    AttendanceStatus? status,
    AttendanceMethod? method,
    String? membershipPlanName,
    String? specialization,
    int? durationMinutes,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      userRole: userRole ?? this.userRole,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      method: method ?? this.method,
      membershipPlanName: membershipPlanName ?? this.membershipPlanName,
      specialization: specialization ?? this.specialization,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}

enum AttendanceStatus {
  checkedIn,
  checkedOut,
}

enum AttendanceMethod {
  qrScan,
  manualOwner,
}
