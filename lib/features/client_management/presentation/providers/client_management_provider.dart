import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/client_management_mock_datasource.dart';
import '../../data/repositories/client_management_repository_impl.dart';
import '../../domain/entities/trainer_client.dart';
import '../../domain/repositories/client_management_repository.dart';

enum ClientFilterTab { all, active, inactive }

class ClientManagementState {
  const ClientManagementState({
    this.clients = const [],
    this.selectedFilter = ClientFilterTab.all,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  final List<TrainerClient> clients;
  final ClientFilterTab selectedFilter;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  int get totalCount => clients.length;

  int get activeCount => clients.where((c) => c.isActive).length;

  int get inactiveCount => clients.where((c) => !c.isActive).length;

  int get sessionsPerWeek {
    return 8;
  }

  int get avgProgressPercentage {
    if (clients.isEmpty) return 0;
    final targetList = clients.where((c) => c.isActive).toList();
    if (targetList.isEmpty) return 0;
    final sum = targetList.fold<int>(0, (prev, c) => prev + c.progressPercentage);
    return (sum / targetList.length).round();
  }

  List<TrainerClient> get filteredClients {
    return clients.where((client) {
      if (selectedFilter == ClientFilterTab.active && !client.isActive) {
        return false;
      }
      if (selectedFilter == ClientFilterTab.inactive && client.isActive) {
        return false;
      }

      if (searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final matchName = client.name.toLowerCase().contains(query);
        final matchGoal = client.goal.toLowerCase().contains(query);
        final matchPlan = client.trainingPlan.toLowerCase().contains(query);
        final matchEmail = client.email.toLowerCase().contains(query);
        return matchName || matchGoal || matchPlan || matchEmail;
      }

      return true;
    }).toList();
  }

  ClientManagementState copyWith({
    List<TrainerClient>? clients,
    ClientFilterTab? selectedFilter,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return ClientManagementState(
      clients: clients ?? this.clients,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final clientManagementDatasourceProvider =
    Provider<ClientManagementMockDatasource>((ref) {
  return ClientManagementMockDatasource();
});

final clientManagementRepositoryProvider =
    Provider<ClientManagementRepository>((ref) {
  final datasource = ref.watch(clientManagementDatasourceProvider);
  return ClientManagementRepositoryImpl(datasource);
});

class ClientManagementNotifier extends Notifier<ClientManagementState> {
  static final List<TrainerClient> _defaultClients = [
    const TrainerClient(
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
      attendanceRate: 91,
      attendanceDelta: '+5%',
      avgIntensity: 8.2,
      intensityDelta: '+0.4',
      weightChange: -3.2,
      goalOnTrack: true,
      notes:
          'Responds well to high-intensity intervals. Increase cardio duration by 5 min next session.',
      weeklyActivity: [0.55, 0.75, 0.08, 0.90, 0.72, 0.82, 0.65],
      upcomingSessions: [
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
    const TrainerClient(
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
      attendanceRate: 88,
      attendanceDelta: '+2%',
      avgIntensity: 8.8,
      intensityDelta: '+0.6',
      weightChange: 2.4,
      goalOnTrack: true,
      notes:
          'Focusing on progressive overload for bench press and squats. Form is consistent.',
      weeklyActivity: [0.65, 0.80, 0.70, 0.85, 0.58, 0.40, 0.75],
      upcomingSessions: [
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
    const TrainerClient(
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
      attendanceRate: 96,
      attendanceDelta: '+8%',
      avgIntensity: 7.9,
      intensityDelta: '+0.2',
      weightChange: -1.8,
      goalOnTrack: true,
      notes:
          'Mileage increasing steadily toward half-marathon benchmark. Pacing is very disciplined.',
      weeklyActivity: [0.85, 0.90, 0.60, 0.85, 0.85, 0.95, 0.70],
      upcomingSessions: [
        ClientUpcomingSession(
          id: 'se1',
          dayLabel: 'TOD',
          title: 'Tempo Run & Core',
          time: '3:30 PM',
          durationMinutes: 50,
        ),
      ],
    ),
    const TrainerClient(
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
      attendanceRate: 94,
      attendanceDelta: '+4%',
      avgIntensity: 9.0,
      intensityDelta: '+0.5',
      weightChange: 1.2,
      goalOnTrack: true,
      notes: 'PR deadlift reached last week. Maintaining form on heavy singles.',
      weeklyActivity: [0.70, 0.85, 0.65, 0.90, 0.90, 0.80, 0.50],
      upcomingSessions: [
        ClientUpcomingSession(
          id: 'sj1',
          dayLabel: 'FRI',
          title: 'Heavy Deadlift Session',
          time: '8:00 AM',
          durationMinutes: 60,
        ),
      ],
    ),
    const TrainerClient(
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
      attendanceRate: 65,
      attendanceDelta: '-10%',
      avgIntensity: 6.5,
      intensityDelta: '-0.3',
      weightChange: 0.0,
      goalOnTrack: false,
      notes: 'Currently traveling. Plan to resume regular sessions next month.',
      weeklyActivity: [0.30, 0.40, 0.10, 0.45, 0.45, 0.20, 0.10],
      upcomingSessions: [],
    ),
  ];

  late final ClientManagementRepository _repository;

  @override
  ClientManagementState build() {
    _repository = ref.watch(clientManagementRepositoryProvider);
    return ClientManagementState(
      clients: _defaultClients,
      isLoading: false,
    );
  }

  void setFilter(ClientFilterTab tab) {
    state = state.copyWith(selectedFilter: tab);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<TrainerClient> addClient({
    required String name,
    required String email,
    int? age,
    int? heightCm,
    double? weightKg,
    required String goal,
    required String trainingPlan,
    String? phone,
    String? notes,
  }) async {
    final newClient = TrainerClient(
      id: 'client_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      initials: TrainerClient.generateInitials(name),
      email: email.trim(),
      age: age,
      heightCm: heightCm ?? 170,
      weightKg: weightKg,
      goal: goal.trim(),
      trainingPlan: trainingPlan.trim(),
      sessionsCount: 0,
      progressPercentage: 10,
      streakDays: 1,
      nextSession: 'Upcoming Session',
      isActive: true,
      phone: phone?.trim(),
      notes: notes?.trim(),
      joinedDate: DateTime.now(),
      attendanceRate: 100,
      avgIntensity: 7.5,
      weightChange: 0.0,
      goalOnTrack: true,
      weeklyActivity: const [0.2, 0.4, 0.0, 0.5, 0.6, 0.3, 0.0],
      upcomingSessions: [
        ClientUpcomingSession(
          id: 's_new_1',
          dayLabel: 'TOD',
          title: trainingPlan.trim(),
          time: '11:00 AM',
          durationMinutes: 45,
        ),
      ],
    );

    final saved = await _repository.addClient(newClient);
    final updatedList = [saved, ...state.clients];
    state = state.copyWith(clients: updatedList);
    return saved;
  }

  Future<void> updateNotes(String clientId, String notes) async {
    final client = state.clients.firstWhere((c) => c.id == clientId);
    final updated = client.copyWith(notes: notes);
    await _repository.updateClient(updated);
    final updatedList = state.clients.map((c) {
      if (c.id == clientId) {
        return updated;
      }
      return c;
    }).toList();
    state = state.copyWith(clients: updatedList);
  }

  Future<void> toggleActiveStatus(String clientId) async {
    await _repository.toggleClientActiveStatus(clientId);
    final updatedList = state.clients.map((c) {
      if (c.id == clientId) {
        return c.copyWith(isActive: !c.isActive);
      }
      return c;
    }).toList();
    state = state.copyWith(clients: updatedList);
  }

  Future<void> deleteClient(String clientId) async {
    await _repository.deleteClient(clientId);
    final updatedList = state.clients.where((c) => c.id != clientId).toList();
    state = state.copyWith(clients: updatedList);
  }

  Future<void> refresh() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final list = await _repository.getClients();
      state = state.copyWith(clients: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final clientManagementProvider =
    NotifierProvider<ClientManagementNotifier, ClientManagementState>(
  ClientManagementNotifier.new,
);
