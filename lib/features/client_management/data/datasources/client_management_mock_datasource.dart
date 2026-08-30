import 'dart:async';

import '../../domain/entities/trainer_client.dart';
import '../models/trainer_client_model.dart';
import 'client_management_datasource.dart';

class ClientManagementMockDatasource implements ClientManagementDatasource {
  ClientManagementMockDatasource() {
    _clients = List<TrainerClientModel>.from(_initialMockClients);
    _streamController = StreamController<List<TrainerClientModel>>.broadcast(
      onListen: () {
        _streamController.add(List<TrainerClientModel>.unmodifiable(_clients));
      },
    );
  }

  late List<TrainerClientModel> _clients;
  late final StreamController<List<TrainerClientModel>> _streamController;

  static final List<TrainerClientModel> _initialMockClients = [
    TrainerClientModel(
      id: 'client_sarah_chen',
      name: 'Sarah Chen',
      initials: 'SC',
      email: 'sarah.chen@email.com',
      age: 28,
      heightCm: 163,
      weightKg: 62.0,
      goal: 'Weight Loss',
      trainingPlan: 'HIIT + Cardio',
      sessionsCount: 12,
      progressPercentage: 72,
      streakDays: 8,
      nextSession: 'Today 11:00 AM',
      isActive: true,
      phone: '+1 (555) 234-5678',
      joinedDate: DateTime(2025, 2, 10),
      attendanceRate: 91,
      attendanceDelta: '+5%',
      avgIntensity: 8.2,
      intensityDelta: '+0.4',
      weightChange: -3.2,
      goalOnTrack: true,
      notes:
          'Responds well to high-intensity intervals. Increase cardio duration by 5 min next session.',
      weeklyActivity: const [0.55, 0.75, 0.08, 0.90, 0.72, 0.82, 0.65],
      upcomingSessions: const [
        ClientUpcomingSession(
          id: 's1',
          dayLabel: 'TOD',
          title: 'HIIT + Cardio',
          time: '11:00 AM',
          durationMinutes: 45,
        ),
        ClientUpcomingSession(
          id: 's2',
          dayLabel: 'THU',
          title: 'HIIT + Cardio',
          time: '11:00 AM',
          durationMinutes: 45,
        ),
        ClientUpcomingSession(
          id: 's3',
          dayLabel: 'SAT',
          title: 'Assessment',
          time: '9:00 AM',
          durationMinutes: 30,
        ),
      ],
    ),
    TrainerClientModel(
      id: 'client_marcus_king',
      name: 'Marcus King',
      initials: 'MK',
      email: 'marcus.king@email.com',
      age: 31,
      heightCm: 182,
      weightKg: 84.0,
      goal: 'Muscle Gain',
      trainingPlan: 'Hypertrophy',
      sessionsCount: 8,
      progressPercentage: 58,
      streakDays: 5,
      nextSession: 'Tomorrow 9:00 AM',
      isActive: true,
      phone: '+1 (555) 345-6789',
      joinedDate: DateTime(2025, 3, 1),
      attendanceRate: 88,
      attendanceDelta: '+2%',
      avgIntensity: 8.8,
      intensityDelta: '+0.6',
      weightChange: 2.4,
      goalOnTrack: true,
      notes:
          'Focusing on progressive overload for bench press and squats. Form is consistent.',
      weeklyActivity: const [0.65, 0.80, 0.70, 0.85, 0.58, 0.40, 0.75],
      upcomingSessions: const [
        ClientUpcomingSession(
          id: 'sm1',
          dayLabel: 'TOM',
          title: 'Hypertrophy Upper Body',
          time: '9:00 AM',
          durationMinutes: 60,
        ),
        ClientUpcomingSession(
          id: 'sm2',
          dayLabel: 'FRI',
          title: 'Hypertrophy Lower Body',
          time: '10:30 AM',
          durationMinutes: 60,
        ),
      ],
    ),
    TrainerClientModel(
      id: 'client_emma_davis',
      name: 'Emma Davis',
      initials: 'ED',
      email: 'emma.davis@email.com',
      age: 25,
      heightCm: 168,
      weightKg: 57.0,
      goal: 'Marathon Prep',
      trainingPlan: 'Endurance',
      sessionsCount: 20,
      progressPercentage: 85,
      streakDays: 14,
      nextSession: 'Today 3:30 PM',
      isActive: true,
      phone: '+1 (555) 456-7890',
      joinedDate: DateTime(2025, 1, 15),
      attendanceRate: 96,
      attendanceDelta: '+8%',
      avgIntensity: 7.9,
      intensityDelta: '+0.2',
      weightChange: -1.8,
      goalOnTrack: true,
      notes:
          'Mileage increasing steadily toward half-marathon benchmark. Pacing is very disciplined.',
      weeklyActivity: const [0.85, 0.90, 0.60, 0.85, 0.85, 0.95, 0.70],
      upcomingSessions: const [
        ClientUpcomingSession(
          id: 'se1',
          dayLabel: 'TOD',
          title: 'Tempo Run & Core',
          time: '3:30 PM',
          durationMinutes: 50,
        ),
      ],
    ),
    TrainerClientModel(
      id: 'client_jake_wilson',
      name: 'Jake Wilson',
      initials: 'JW',
      email: 'jake.wilson@email.com',
      age: 29,
      heightCm: 178,
      weightKg: 78.0,
      goal: 'Strength',
      trainingPlan: 'Powerlifting',
      sessionsCount: 15,
      progressPercentage: 90,
      streakDays: 6,
      nextSession: 'Friday 8:00 AM',
      isActive: true,
      phone: '+1 (555) 567-8901',
      joinedDate: DateTime(2025, 2, 20),
      attendanceRate: 94,
      attendanceDelta: '+4%',
      avgIntensity: 9.0,
      intensityDelta: '+0.5',
      weightChange: 1.2,
      goalOnTrack: true,
      notes: 'PR deadlift reached last week. Maintaining form on heavy singles.',
      weeklyActivity: const [0.70, 0.85, 0.65, 0.90, 0.90, 0.80, 0.50],
      upcomingSessions: const [
        ClientUpcomingSession(
          id: 'sj1',
          dayLabel: 'FRI',
          title: 'Heavy Deadlift Session',
          time: '8:00 AM',
          durationMinutes: 60,
        ),
      ],
    ),
    TrainerClientModel(
      id: 'client_lisa_park',
      name: 'Lisa Park',
      initials: 'LP',
      email: 'lisa.park@email.com',
      age: 33,
      heightCm: 160,
      weightKg: 52.0,
      goal: 'Flexibility',
      trainingPlan: 'Yoga & Mobility',
      sessionsCount: 6,
      progressPercentage: 45,
      streakDays: 0,
      nextSession: 'Not scheduled',
      isActive: false,
      phone: '+1 (555) 678-9012',
      joinedDate: DateTime(2024, 11, 5),
      attendanceRate: 65,
      attendanceDelta: '-10%',
      avgIntensity: 6.5,
      intensityDelta: '-0.3',
      weightChange: 0.0,
      goalOnTrack: false,
      notes: 'Currently traveling. Plan to resume regular sessions next month.',
      weeklyActivity: const [0.30, 0.40, 0.10, 0.45, 0.45, 0.20, 0.10],
      upcomingSessions: const [],
    ),
  ];

  @override
  Stream<List<TrainerClientModel>> watchClients({String? trainerId}) {
    return _streamController.stream;
  }

  @override
  Future<List<TrainerClientModel>> getClients({String? trainerId}) async {
    return List<TrainerClientModel>.unmodifiable(_clients);
  }

  @override
  Future<TrainerClientModel> addClient(
    TrainerClientModel client, {
    String? trainerId,
  }) async {
    _clients.insert(0, client);
    _streamController.add(List<TrainerClientModel>.unmodifiable(_clients));
    return client;
  }

  @override
  Future<TrainerClientModel> updateClient(
    TrainerClientModel client, {
    String? trainerId,
  }) async {
    final index = _clients.indexWhere((c) => c.id == client.id);
    if (index != -1) {
      _clients[index] = client;
      _streamController.add(List<TrainerClientModel>.unmodifiable(_clients));
    }
    return client;
  }

  @override
  Future<void> updateNotes(
    String clientId,
    String notes, {
    String? trainerId,
  }) async {
    final index = _clients.indexWhere((c) => c.id == clientId);
    if (index != -1) {
      final current = _clients[index];
      _clients[index] = TrainerClientModel(
        id: current.id,
        name: current.name,
        initials: current.initials,
        email: current.email,
        age: current.age,
        heightCm: current.heightCm,
        weightKg: current.weightKg,
        goal: current.goal,
        trainingPlan: current.trainingPlan,
        sessionsCount: current.sessionsCount,
        progressPercentage: current.progressPercentage,
        streakDays: current.streakDays,
        nextSession: current.nextSession,
        isActive: current.isActive,
        avatarUrl: current.avatarUrl,
        joinedDate: current.joinedDate,
        phone: current.phone,
        notes: notes,
        attendanceRate: current.attendanceRate,
        attendanceDelta: current.attendanceDelta,
        avgIntensity: current.avgIntensity,
        intensityDelta: current.intensityDelta,
        weightChange: current.weightChange,
        goalOnTrack: current.goalOnTrack,
        weeklyActivity: current.weeklyActivity,
        upcomingSessions: current.upcomingSessions,
      );
      _streamController.add(List<TrainerClientModel>.unmodifiable(_clients));
    }
  }

  @override
  Future<void> deleteClient(String clientId, {String? trainerId}) async {
    _clients.removeWhere((c) => c.id == clientId);
    _streamController.add(List<TrainerClientModel>.unmodifiable(_clients));
  }

  @override
  Future<void> toggleClientActiveStatus(
    String clientId, {
    String? trainerId,
  }) async {
    final index = _clients.indexWhere((c) => c.id == clientId);
    if (index != -1) {
      final current = _clients[index];
      _clients[index] = TrainerClientModel(
        id: current.id,
        name: current.name,
        initials: current.initials,
        email: current.email,
        age: current.age,
        heightCm: current.heightCm,
        weightKg: current.weightKg,
        goal: current.goal,
        trainingPlan: current.trainingPlan,
        sessionsCount: current.sessionsCount,
        progressPercentage: current.progressPercentage,
        streakDays: current.streakDays,
        nextSession: current.nextSession,
        isActive: !current.isActive,
        avatarUrl: current.avatarUrl,
        joinedDate: current.joinedDate,
        phone: current.phone,
        notes: current.notes,
        attendanceRate: current.attendanceRate,
        attendanceDelta: current.attendanceDelta,
        avgIntensity: current.avgIntensity,
        intensityDelta: current.intensityDelta,
        weightChange: current.weightChange,
        goalOnTrack: current.goalOnTrack,
        weeklyActivity: current.weeklyActivity,
        upcomingSessions: current.upcomingSessions,
      );
      _streamController.add(List<TrainerClientModel>.unmodifiable(_clients));
    }
  }
}
