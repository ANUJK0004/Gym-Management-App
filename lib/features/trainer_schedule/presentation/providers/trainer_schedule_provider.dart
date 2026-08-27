import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/trainer_schedule_session.dart';

class TrainerScheduleState {
  const TrainerScheduleState({
    required this.selectedDate,
    required this.weekStartDate,
    required this.sessions,
  });

  final DateTime selectedDate;
  final DateTime weekStartDate;
  final List<TrainerScheduleSession> sessions;

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
  }) {
    return TrainerScheduleState(
      selectedDate: selectedDate ?? this.selectedDate,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      sessions: sessions ?? this.sessions,
    );
  }
}

class TrainerScheduleNotifier extends Notifier<TrainerScheduleState> {
  static final DateTime _baseFriday = DateTime(2025, 7, 18);
  static final DateTime _baseMonday = DateTime(2025, 7, 14);

  @override
  TrainerScheduleState build() {
    return TrainerScheduleState(
      selectedDate: _baseFriday,
      weekStartDate: _baseMonday,
      sessions: _defaultMockSessions,
    );
  }

  static final List<TrainerScheduleSession> _defaultMockSessions = [
    // Friday, July 18 Sessions (matching screenshot exactly)
    TrainerScheduleSession(
      id: 'session_fri_1',
      clientName: 'Emma Davis',
      workoutType: 'Strength Training',
      durationMinutes: 45,
      timeSlot: '8:00 AM',
      date: DateTime(2025, 7, 18),
      isCompleted: true,
    ),
    TrainerScheduleSession(
      id: 'session_fri_2',
      clientName: 'Jake Wilson',
      workoutType: 'Cardio & Core',
      durationMinutes: 45,
      timeSlot: '9:30 AM',
      date: DateTime(2025, 7, 18),
      isCompleted: true,
    ),
    TrainerScheduleSession(
      id: 'session_fri_3',
      clientName: 'Sarah Chen',
      workoutType: 'HIIT Training',
      durationMinutes: 45,
      timeSlot: '11:00 AM',
      date: DateTime(2025, 7, 18),
      isNext: true,
    ),
    TrainerScheduleSession(
      id: 'session_fri_4',
      clientName: 'Marcus King',
      workoutType: 'Hypertrophy',
      durationMinutes: 60,
      timeSlot: '1:00 PM',
      date: DateTime(2025, 7, 18),
    ),
    TrainerScheduleSession(
      id: 'session_fri_5',
      clientName: 'Emma Davis',
      workoutType: 'Flexibility & Mobility',
      durationMinutes: 30,
      timeSlot: '3:30 PM',
      date: DateTime(2025, 7, 18),
    ),
    TrainerScheduleSession(
      id: 'session_fri_6',
      clientName: 'New Client',
      workoutType: 'Assessment',
      durationMinutes: 45,
      timeSlot: '5:00 PM',
      date: DateTime(2025, 7, 18),
    ),

    // Mon, July 14 Sessions
    TrainerScheduleSession(
      id: 'session_mon_1',
      clientName: 'Sarah Chen',
      workoutType: 'HIIT Training',
      durationMinutes: 45,
      timeSlot: '9:00 AM',
      date: DateTime(2025, 7, 14),
      isCompleted: true,
    ),
    TrainerScheduleSession(
      id: 'session_mon_2',
      clientName: 'Marcus King',
      workoutType: 'Strength Training',
      durationMinutes: 60,
      timeSlot: '11:30 AM',
      date: DateTime(2025, 7, 14),
      isCompleted: true,
    ),

    // Tue, July 15 Sessions
    TrainerScheduleSession(
      id: 'session_tue_1',
      clientName: 'Jake Wilson',
      workoutType: 'Cardio & Core',
      durationMinutes: 45,
      timeSlot: '8:30 AM',
      date: DateTime(2025, 7, 15),
      isCompleted: true,
    ),
    TrainerScheduleSession(
      id: 'session_tue_2',
      clientName: 'Lisa Park',
      workoutType: 'Flexibility & Mobility',
      durationMinutes: 45,
      timeSlot: '2:00 PM',
      date: DateTime(2025, 7, 15),
      isCompleted: true,
    ),

    // Wed, July 16 Sessions
    TrainerScheduleSession(
      id: 'session_wed_1',
      clientName: 'Emma Davis',
      workoutType: 'Powerlifting',
      durationMinutes: 60,
      timeSlot: '10:00 AM',
      date: DateTime(2025, 7, 16),
      isCompleted: true,
    ),
    TrainerScheduleSession(
      id: 'session_wed_2',
      clientName: 'Sarah Chen',
      workoutType: 'Circuit Training',
      durationMinutes: 45,
      timeSlot: '4:00 PM',
      date: DateTime(2025, 7, 16),
      isCompleted: true,
    ),

    // Thu, July 17 Sessions
    TrainerScheduleSession(
      id: 'session_thu_1',
      clientName: 'Marcus King',
      workoutType: 'Hypertrophy',
      durationMinutes: 60,
      timeSlot: '9:00 AM',
      date: DateTime(2025, 7, 17),
      isCompleted: true,
    ),
    TrainerScheduleSession(
      id: 'session_thu_2',
      clientName: 'Lisa Park',
      workoutType: 'Assessment',
      durationMinutes: 45,
      timeSlot: '1:30 PM',
      date: DateTime(2025, 7, 17),
      isCompleted: true,
    ),

    // Sat, July 19 Sessions
    TrainerScheduleSession(
      id: 'session_sat_1',
      clientName: 'Jake Wilson',
      workoutType: 'Cardio & Core',
      durationMinutes: 45,
      timeSlot: '9:00 AM',
      date: DateTime(2025, 7, 19),
    ),
    TrainerScheduleSession(
      id: 'session_sat_2',
      clientName: 'Lisa Park',
      workoutType: 'Strength Training',
      durationMinutes: 60,
      timeSlot: '11:00 AM',
      date: DateTime(2025, 7, 19),
    ),
  ];

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void previousWeek() {
    final newWeekStart = state.weekStartDate.subtract(const Duration(days: 7));
    state = state.copyWith(
      weekStartDate: newWeekStart,
      selectedDate: newWeekStart,
    );
  }

  void nextWeek() {
    final newWeekStart = state.weekStartDate.add(const Duration(days: 7));
    state = state.copyWith(
      weekStartDate: newWeekStart,
      selectedDate: newWeekStart,
    );
  }

  void addSession({
    required String clientName,
    required String workoutType,
    required String timeSlot,
    required int durationMinutes,
    String? notes,
    DateTime? date,
  }) {
    final targetDate = date ?? state.selectedDate;
    final newSession = TrainerScheduleSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      clientName: clientName,
      workoutType: workoutType,
      durationMinutes: durationMinutes,
      timeSlot: timeSlot,
      date: targetDate,
      notes: notes,
      isCompleted: false,
      isNext: false,
    );

    final updatedList = List<TrainerScheduleSession>.from(state.sessions)
      ..add(newSession);

    state = state.copyWith(sessions: updatedList);
  }

  void toggleSessionCompleted(String id) {
    final updatedList = state.sessions.map((s) {
      if (s.id == id) {
        return s.copyWith(isCompleted: !s.isCompleted, isNext: false);
      }
      return s;
    }).toList();

    state = state.copyWith(sessions: updatedList);
  }
}

final trainerScheduleProvider =
    NotifierProvider<TrainerScheduleNotifier, TrainerScheduleState>(
  TrainerScheduleNotifier.new,
);
