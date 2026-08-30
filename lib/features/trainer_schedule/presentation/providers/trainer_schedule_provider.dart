import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:sweatsync/features/profile/presentation/providers/user_profile_provider.dart';
import '../../data/datasources/trainer_schedule_remote_datasource.dart';
import '../../data/repositories/trainer_schedule_repository_impl.dart';
import '../../domain/entities/trainer_schedule_session.dart';
import '../../domain/repositories/trainer_schedule_repository.dart';

// =============================================================================
// BACKEND DATA SOURCE & REPOSITORY PROVIDERS
// =============================================================================

final trainerScheduleDataSourceProvider =
    Provider<TrainerScheduleRemoteDataSource>((ref) {
  return TrainerScheduleRemoteDataSource(ref.watch(firestoreProvider));
});

final trainerScheduleRepositoryProvider =
    Provider<TrainerScheduleRepository>((ref) {
  return TrainerScheduleRepositoryImpl(
    ref.watch(trainerScheduleDataSourceProvider),
  );
});

final trainerScheduleTrainerIdProvider = Provider<String>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  return user?.uid ?? 'trainer_001';
});

final trainerScheduleSessionsStreamProvider =
    StreamProvider<List<TrainerScheduleSession>>((ref) {
  final repo = ref.watch(trainerScheduleRepositoryProvider);
  final trainerId = ref.watch(trainerScheduleTrainerIdProvider);
  return repo.watchSessions(trainerId: trainerId);
});

// =============================================================================
// STATE & NOTIFIER
// =============================================================================

class TrainerScheduleState {
  const TrainerScheduleState({
    required this.selectedDate,
    required this.weekStartDate,
    required this.sessions,
    this.isLoading = false,
    this.errorMessage,
  });

  final DateTime selectedDate;
  final DateTime weekStartDate;
  final List<TrainerScheduleSession> sessions;
  final bool isLoading;
  final String? errorMessage;

  bool get isSelectedDateInPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return target.isBefore(today);
  }

  bool get isSelectedDateToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  List<TrainerScheduleSession> get sessionsForSelectedDate {
    return sessions.where((s) {
      return s.date.year == selectedDate.year &&
          s.date.month == selectedDate.month &&
          s.date.day == selectedDate.day;
    }).toList();
  }

  TrainerScheduleState copyWith({
    DateTime? selectedDate,
    DateTime? weekStartDate,
    List<TrainerScheduleSession>? sessions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TrainerScheduleState(
      selectedDate: selectedDate ?? this.selectedDate,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class TrainerScheduleNotifier extends Notifier<TrainerScheduleState> {
  static DateTime _getMondayOfCurrentWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  static DateTime _getTodayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  StreamSubscription<List<TrainerScheduleSession>>? _streamSubscription;

  @override
  TrainerScheduleState build() {
    ref.onDispose(() {
      _streamSubscription?.cancel();
    });

    _initStream();

    final today = _getTodayDate();
    final monday = _getMondayOfCurrentWeek();

    return TrainerScheduleState(
      selectedDate: today,
      weekStartDate: monday,
      sessions: _generateDynamicMockSessions(today, monday),
      isLoading: true,
    );
  }

  void _initStream() {
    final repo = ref.read(trainerScheduleRepositoryProvider);
    final trainerId = ref.read(trainerScheduleTrainerIdProvider);

    _streamSubscription?.cancel();
    _streamSubscription = repo.watchSessions(trainerId: trainerId).listen(
      (liveSessions) {
        if (liveSessions.isNotEmpty) {
          state = state.copyWith(
            sessions: liveSessions,
            isLoading: false,
          );
        } else {
          // If Firestore is empty, fetch one-time (which triggers starter seeding)
          _seedAndFetch(repo, trainerId);
        }
      },
      onError: (e) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        );
      },
    );
  }

  Future<void> _seedAndFetch(
    TrainerScheduleRepository repo,
    String trainerId,
  ) async {
    try {
      final fetched = await repo.getSessions(trainerId: trainerId);
      if (fetched.isNotEmpty) {
        state = state.copyWith(sessions: fetched, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  Future<void> addSession({
    required String clientName,
    String? clientId,
    String? clientAvatar,
    required String workoutType,
    required String timeSlot,
    required int durationMinutes,
    String? notes,
    DateTime? date,
  }) async {
    final targetDate = date ?? state.selectedDate;
    final trainerId = ref.read(trainerScheduleTrainerIdProvider);
    final repo = ref.read(trainerScheduleRepositoryProvider);

    final newSession = TrainerScheduleSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      trainerId: trainerId,
      clientId: clientId,
      clientName: clientName,
      clientAvatar: clientAvatar,
      clientInitials: _getInitials(clientName),
      workoutType: workoutType,
      durationMinutes: durationMinutes,
      timeSlot: timeSlot,
      startTime: timeSlot,
      startsIn: 'Upcoming',
      date: targetDate,
      notes: notes,
      isCompleted: false,
      isNext: false,
      status: 'upcoming',
      scheduledOrder: targetDate.millisecondsSinceEpoch,
    );

    // Optimistic local state update
    final optimisticList = List<TrainerScheduleSession>.from(state.sessions)
      ..add(newSession);
    state = state.copyWith(sessions: optimisticList);

    // Async write to Firestore backend
    try {
      await repo.addSession(trainerId: trainerId, session: newSession);
    } catch (e) {
      // Stream will automatically resync or error handled
    }
  }

  Future<void> toggleSessionCompleted(String id) async {
    final trainerId = ref.read(trainerScheduleTrainerIdProvider);
    final repo = ref.read(trainerScheduleRepositoryProvider);

    TrainerScheduleSession? targetSession;
    for (final s in state.sessions) {
      if (s.id == id) {
        targetSession = s;
        break;
      }
    }
    if (targetSession == null) return;

    final newStatus = !targetSession.isCompleted;

    // Optimistic local update
    final updatedList = state.sessions.map((s) {
      if (s.id == id) {
        return s.copyWith(isCompleted: newStatus, isNext: false);
      }
      return s;
    }).toList();
    state = state.copyWith(sessions: updatedList);

    // Async write to Firestore backend
    try {
      await repo.toggleSessionCompleted(
        trainerId: trainerId,
        sessionId: id,
        isCompleted: newStatus,
      );
    } catch (_) {}
  }

  Future<void> deleteSession(String id) async {
    final trainerId = ref.read(trainerScheduleTrainerIdProvider);
    final repo = ref.read(trainerScheduleRepositoryProvider);

    // Optimistic local update
    final updatedList = state.sessions.where((s) => s.id != id).toList();
    state = state.copyWith(sessions: updatedList);

    // Async write to Firestore backend
    try {
      await repo.deleteSession(trainerId: trainerId, sessionId: id);
    } catch (_) {}
  }

  static String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'CL';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  static List<TrainerScheduleSession> _generateDynamicMockSessions(
    DateTime today,
    DateTime monday,
  ) {
    final list = <TrainerScheduleSession>[];

    // 1. Sessions for Today
    list.addAll([
      TrainerScheduleSession(
        id: 'session_today_1',
        clientName: 'Emma Davis',
        clientInitials: 'ED',
        workoutType: 'Strength Training',
        durationMinutes: 45,
        timeSlot: '8:00 AM',
        date: today,
        isCompleted: true,
      ),
      TrainerScheduleSession(
        id: 'session_today_2',
        clientName: 'Jake Wilson',
        clientInitials: 'JW',
        workoutType: 'Cardio & Core',
        durationMinutes: 45,
        timeSlot: '9:30 AM',
        date: today,
        isCompleted: true,
      ),
      TrainerScheduleSession(
        id: 'session_today_3',
        clientName: 'Sarah Chen',
        clientInitials: 'SC',
        workoutType: 'HIIT Training',
        durationMinutes: 45,
        timeSlot: '11:00 AM',
        date: today,
        isNext: true,
      ),
      TrainerScheduleSession(
        id: 'session_today_4',
        clientName: 'Marcus King',
        clientInitials: 'MK',
        workoutType: 'Hypertrophy',
        durationMinutes: 60,
        timeSlot: '1:00 PM',
        date: today,
      ),
      TrainerScheduleSession(
        id: 'session_today_5',
        clientName: 'Emma Davis',
        clientInitials: 'ED',
        workoutType: 'Flexibility & Mobility',
        durationMinutes: 30,
        timeSlot: '3:30 PM',
        date: today,
      ),
      TrainerScheduleSession(
        id: 'session_today_6',
        clientName: 'New Client',
        clientInitials: 'NC',
        workoutType: 'Assessment',
        durationMinutes: 45,
        timeSlot: '5:00 PM',
        date: today,
      ),
    ]);

    // 2. Sessions for other days of the current week
    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      if (day.year == today.year &&
          day.month == today.month &&
          day.day == today.day) {
        continue; // Already added for today
      }

      final isPast = day.isBefore(today);

      list.addAll([
        TrainerScheduleSession(
          id: 'session_day_${i}_1',
          clientName: i % 2 == 0 ? 'Sarah Chen' : 'Marcus King',
          clientInitials: i % 2 == 0 ? 'SC' : 'MK',
          workoutType: i % 2 == 0 ? 'HIIT Training' : 'Strength Training',
          durationMinutes: 45,
          timeSlot: '9:00 AM',
          date: day,
          isCompleted: isPast,
        ),
        TrainerScheduleSession(
          id: 'session_day_${i}_2',
          clientName: i % 2 == 0 ? 'Jake Wilson' : 'Lisa Park',
          clientInitials: i % 2 == 0 ? 'JW' : 'LP',
          workoutType: i % 2 == 0 ? 'Cardio & Core' : 'Assessment',
          durationMinutes: 60,
          timeSlot: '2:00 PM',
          date: day,
          isCompleted: isPast,
        ),
      ]);
    }

    return list;
  }
}

final trainerScheduleProvider =
    NotifierProvider<TrainerScheduleNotifier, TrainerScheduleState>(
  TrainerScheduleNotifier.new,
);
