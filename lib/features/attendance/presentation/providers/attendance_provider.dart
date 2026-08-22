import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../activity/application/activity_actor.dart';
import '../../../activity/application/activity_target.dart';
import '../../../activity/application/activity_type.dart';
import '../../../activity/presentation/providers/activity_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gym/presentation/providers/gym_provider.dart';
import '../../../profile/presentation/providers/current_user_profile_provider.dart';

import '../../data/datasources/attendance_remote_datasource.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/daily_qr_payload.dart';
import '../../domain/repositories/attendance_repository.dart';

// ------------------------------------------------------------
// DATA SOURCE & REPOSITORY
// ------------------------------------------------------------

final attendanceRemoteDataSourceProvider =
    Provider<AttendanceRemoteDataSource>((ref) {
  return AttendanceRemoteDataSource(FirebaseFirestore.instance);
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final dataSource = ref.watch(attendanceRemoteDataSourceProvider);
  return AttendanceRepositoryImpl(dataSource);
});

// ------------------------------------------------------------
// DATE FILTER PROVIDER
// ------------------------------------------------------------

final selectedAttendanceDateProvider =
    NotifierProvider<SelectedAttendanceDateNotifier, String>(
  SelectedAttendanceDateNotifier.new,
);

class SelectedAttendanceDateNotifier extends Notifier<String> {
  @override
  String build() {
    return DailyQRPayload.getTodayKey();
  }

  void setDate(String date) {
    state = date;
  }

  void resetToToday() {
    state = DailyQRPayload.getTodayKey();
  }
}

// ------------------------------------------------------------
// OWNER ATTENDANCE STREAM
// ------------------------------------------------------------

final gymDailyAttendanceProvider =
    StreamProvider.autoDispose.family<List<AttendanceRecord>, String>((ref, date) {
  final gymAsync = ref.watch(ownerGymProvider);
  final gym = gymAsync.value;

  if (gym == null || gym.id.isEmpty) {
    return Stream.value([]);
  }

  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.streamGymAttendanceForDate(
    gymId: gym.id,
    date: date,
  );
});

// ------------------------------------------------------------
// MEMBER TODAY ATTENDANCE
// ------------------------------------------------------------

final memberTodayAttendanceProvider =
    StreamProvider.autoDispose<AttendanceRecord?>((ref) {
  final user = ref.watch(authStateProvider).value;
  final profile = ref.watch(currentUserProfileProvider).value;

  if (user == null || profile == null || profile.gymId == null || profile.gymId!.isEmpty) {
    return Stream.value(null);
  }

  final today = DailyQRPayload.getTodayKey();
  final repository = ref.watch(attendanceRepositoryProvider);

  return repository
      .streamGymAttendanceForDate(
        gymId: profile.gymId!,
        date: today,
      )
      .map((records) {
        for (final r in records) {
          if (r.userId == user.id) {
            return r;
          }
        }
        return null;
      });
});

// ------------------------------------------------------------
// MEMBER ATTENDANCE HISTORY
// ------------------------------------------------------------

final memberAttendanceHistoryProvider =
    StreamProvider.autoDispose<List<AttendanceRecord>>((ref) {
  final user = ref.watch(authStateProvider).value;
  final profile = ref.watch(currentUserProfileProvider).value;

  if (user == null || profile == null || profile.gymId == null || profile.gymId!.isEmpty) {
    return Stream.value([]);
  }

  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.streamUserAttendanceHistory(
    gymId: profile.gymId!,
    userId: user.id,
  );
});

// ------------------------------------------------------------
// ATTENDANCE CONTROLLER
// ------------------------------------------------------------

final attendanceControllerProvider =
    AsyncNotifierProvider<AttendanceController, void>(
  AttendanceController.new,
);

class AttendanceController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Scans the QR code payload and checks the member in or out
  Future<AttendanceCheckInResult> scanAndCheckIn({
    required String rawQrData,
  }) async {
    state = const AsyncValue.loading();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('You must be logged in to mark attendance.');
      }

      final profile = await ref.read(currentUserProfileProvider.future);
      if (profile == null) {
        throw Exception('Unable to load user profile.');
      }

      if (profile.gymId == null || profile.gymId!.isEmpty) {
        throw Exception('You are not assigned to any gym yet. Please contact your gym owner.');
      }

      final payload = DailyQRPayload.tryDecode(rawQrData);
      if (payload == null) {
        throw Exception('Invalid QR code format. Please scan the official SweatSync Gym QR.');
      }

      if (payload.gymId != profile.gymId) {
        throw Exception('This QR code belongs to "${payload.gymName}", which is not your registered gym.');
      }

      final isTodayValid = payload.isValidForToday(targetGymId: profile.gymId);
      if (!isTodayValid) {
        throw Exception('This QR code is expired or invalid for today. Every day has a new QR code generated by the gym.');
      }

      final todayKey = DailyQRPayload.getTodayKey();
      final repository = ref.read(attendanceRepositoryProvider);

      final existingRecord = await repository.getTodayUserAttendance(
        gymId: profile.gymId!,
        userId: user.uid,
        date: todayKey,
      );

      final now = DateTime.now();

      if (existingRecord != null && existingRecord.isCurrentlyInGym) {
        // Check out
        final updatedRecord = await repository.checkOut(
          gymId: profile.gymId!,
          recordId: existingRecord.id,
          checkOutTime: now,
        );

        _logActivitySafely(
          gymId: profile.gymId!,
          type: ActivityType.attendanceChecked,
          actor: ActivityActor(
            id: user.uid,
            name: profile.displayName ?? 'Member',
            role: 'member',
          ),
          target: ActivityTarget(
            id: existingRecord.id,
            name: '${profile.displayName ?? 'Member'} (Checked Out)',
            type: 'attendance',
          ),
        );

        state = const AsyncValue.data(null);
        return AttendanceCheckInResult(
          action: AttendanceAction.checkedOut,
          record: updatedRecord,
          message: 'Goodbye, ${profile.displayName ?? 'Member'}! Checked out successfully.',
        );
      }

      // Check in
      final recordId = '${user.uid}_$todayKey';
      final newRecord = AttendanceRecord(
        id: recordId,
        gymId: profile.gymId!,
        userId: user.uid,
        userName: profile.displayName ?? 'Member',
        userPhotoUrl: profile.photoUrl,
        userRole: profile.role,
        date: todayKey,
        checkInTime: now,
        status: AttendanceStatus.checkedIn,
        method: AttendanceMethod.qrScan,
      );

      final createdRecord = await repository.checkIn(
        record: newRecord,
      );

      _logActivitySafely(
        gymId: profile.gymId!,
        type: ActivityType.attendanceChecked,
        actor: ActivityActor(
          id: user.uid,
          name: profile.displayName ?? 'Member',
          role: 'member',
        ),
        target: ActivityTarget(
          id: createdRecord.id,
          name: '${profile.displayName ?? 'Member'} (Checked In)',
          type: 'attendance',
        ),
      );

      state = const AsyncValue.data(null);
      return AttendanceCheckInResult(
        action: AttendanceAction.checkedIn,
        record: createdRecord,
        message: 'Welcome to ${payload.gymName}! Checked in at ${_formatTime(now)}.',
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Member manual check out
  Future<void> memberCheckOut({
    required AttendanceRecord currentRecord,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(attendanceRepositoryProvider);
      await repository.checkOut(
        gymId: currentRecord.gymId,
        recordId: currentRecord.id,
        checkOutTime: DateTime.now(),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Owner manual check in (for member or trainer)
  Future<void> ownerManualCheckIn({
    required String gymId,
    required String userId,
    required String userName,
    required String userRole,
    String? userPhotoUrl,
    String? planOrSpecialization,
    DateTime? checkInTime,
  }) async {
    state = const AsyncValue.loading();
    try {
      final todayKey = DailyQRPayload.getTodayKey();
      final now = checkInTime ?? DateTime.now();
      final recordId = '${userId}_$todayKey';

      final record = AttendanceRecord(
        id: recordId,
        gymId: gymId,
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        userRole: userRole,
        date: todayKey,
        checkInTime: now,
        status: AttendanceStatus.checkedIn,
        method: AttendanceMethod.manualOwner,
        membershipPlanName: userRole == 'member' ? planOrSpecialization : null,
        specialization: userRole == 'trainer' ? planOrSpecialization : null,
      );

      final repository = ref.read(attendanceRepositoryProvider);
      await repository.checkIn(record: record);

      final currentOwner = FirebaseAuth.instance.currentUser;
      _logActivitySafely(
        gymId: gymId,
        type: ActivityType.attendanceChecked,
        actor: ActivityActor(
          id: currentOwner?.uid ?? 'owner',
          name: 'Owner',
          role: 'owner',
        ),
        target: ActivityTarget(
          id: recordId,
          name: '$userName (Manual Check-In)',
          type: 'attendance',
        ),
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Owner manual check out
  Future<void> ownerManualCheckOut({
    required String gymId,
    required String recordId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(attendanceRepositoryProvider);
      await repository.checkOut(
        gymId: gymId,
        recordId: recordId,
        checkOutTime: DateTime.now(),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  void _logActivitySafely({
    required String gymId,
    required ActivityType type,
    required ActivityActor actor,
    ActivityTarget? target,
  }) {
    try {
      ref.read(activityServiceProvider).log(
            gymId: gymId,
            type: type,
            actor: actor,
            target: target,
          );
    } catch (_) {}
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

enum AttendanceAction {
  checkedIn,
  checkedOut,
}

class AttendanceCheckInResult {
  const AttendanceCheckInResult({
    required this.action,
    required this.record,
    required this.message,
  });

  final AttendanceAction action;
  final AttendanceRecord record;
  final String message;
}
