import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sweatsync/features/client_management/data/datasources/client_management_mock_datasource.dart';
import 'package:sweatsync/features/client_management/data/repositories/client_management_repository_impl.dart';
import 'package:sweatsync/features/client_management/presentation/providers/client_management_provider.dart';
import 'package:sweatsync/features/client_management/presentation/screens/client_details_screen.dart';
import 'package:sweatsync/features/client_management/presentation/screens/trainer_clients_screen.dart';

void main() {
  group('ClientManagementProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      final mockDatasource = ClientManagementMockDatasource();
      final repository = ClientManagementRepositoryImpl(mockDatasource);

      container = ProviderContainer(
        overrides: [
          trainerClientTrainerIdProvider.overrideWithValue('trainer_001'),
          clientManagementRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state loads mock clients correctly', () async {
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(clientManagementProvider);
      expect(state.clients.length, equals(5));
      expect(state.totalCount, equals(5));
      expect(state.activeCount, equals(4));
      expect(state.inactiveCount, equals(1));
      expect(state.sessionsPerWeek, equals(8));
      expect(state.avgProgressPercentage, equals(76));
    });

    test('Filter tab switches work properly', () async {
      final notifier = container.read(clientManagementProvider.notifier);

      // Filter active
      notifier.setFilter(ClientFilterTab.active);
      var state = container.read(clientManagementProvider);
      expect(state.filteredClients.length, equals(4));
      expect(state.filteredClients.every((c) => c.isActive), isTrue);

      // Filter inactive
      notifier.setFilter(ClientFilterTab.inactive);
      state = container.read(clientManagementProvider);
      expect(state.filteredClients.length, equals(1));
      expect(state.filteredClients.first.name, equals('Lisa Park'));

      // Filter all
      notifier.setFilter(ClientFilterTab.all);
      state = container.read(clientManagementProvider);
      expect(state.filteredClients.length, equals(5));
    });

    test('Search query filters clients by name or goal', () async {
      final notifier = container.read(clientManagementProvider.notifier);

      // Search by name
      notifier.setSearchQuery('sarah');
      var state = container.read(clientManagementProvider);
      expect(state.filteredClients.length, equals(1));
      expect(state.filteredClients.first.name, equals('Sarah Chen'));

      // Search by goal
      notifier.setSearchQuery('muscle gain');
      state = container.read(clientManagementProvider);
      expect(state.filteredClients.length, equals(1));
      expect(state.filteredClients.first.name, equals('Marcus King'));

      // Search non-existent
      notifier.setSearchQuery('non-existent-xyz');
      state = container.read(clientManagementProvider);
      expect(state.filteredClients.isEmpty, isTrue);
    });

    test('Add client dynamically inserts client at the top', () async {
      final notifier = container.read(clientManagementProvider.notifier);

      final newClient = await notifier.addClient(
        name: 'Jane Doe',
        email: 'jane@email.com',
        age: 28,
        weightKg: 65,
        goal: 'Muscle Gain',
        trainingPlan: 'HIIT + Cardio',
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(newClient.name, equals('Jane Doe'));
      final state = container.read(clientManagementProvider);
      expect(state.totalCount, equals(6));
      expect(state.clients.first.name, equals('Jane Doe'));
      expect(state.clients.first.initials, equals('JD'));
      expect(state.clients.first.formattedWeight, equals('65kg'));
    });

    test('Update notes updates state correctly', () async {
      final notifier = container.read(clientManagementProvider.notifier);
      await notifier.updateNotes('client_sarah_chen', 'Updated notes test.');
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final state = container.read(clientManagementProvider);
      final sarah = state.clients.firstWhere((c) => c.id == 'client_sarah_chen');
      expect(sarah.notes, equals('Updated notes test.'));
    });
  });

  group('TrainerClientsScreen Widget Tests', () {
    testWidgets('Renders all elements from screenshot 1 correctly',
        (tester) async {
      final mockDatasource = ClientManagementMockDatasource();
      final repository = ClientManagementRepositoryImpl(mockDatasource);

      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            trainerClientTrainerIdProvider.overrideWithValue('trainer_001'),
            clientManagementRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: TrainerClientsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Title & Subtitle
      expect(find.text('My Clients'), findsOneWidget);
      expect(find.text('5 total · 4 active'), findsOneWidget);
      expect(find.text('Add Client'), findsOneWidget);

      // Verify Summary Metric Cards
      expect(find.text('Clients'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Sessions/wk'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('Avg Progress'), findsOneWidget);
      expect(find.text('76%'), findsOneWidget);

      // Verify Search Bar
      expect(find.text('Search clients...'), findsOneWidget);

      // Verify Filter Tabs
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Inactive'), findsOneWidget);

      // Verify Client Cards
      expect(find.text('Sarah Chen'), findsOneWidget);
      expect(find.text('Marcus King'), findsOneWidget);
      expect(find.text('Emma Davis'), findsOneWidget);
      expect(find.text('12 sessions'), findsOneWidget);
      expect(find.text('Today 11:00 AM'), findsOneWidget);
      expect(find.text('62kg'), findsOneWidget);
    });

    testWidgets('AddClientSheet starts disabled and enables when all required fields filled',
        (tester) async {
      final mockDatasource = ClientManagementMockDatasource();
      final repository = ClientManagementRepositoryImpl(mockDatasource);

      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            trainerClientTrainerIdProvider.overrideWithValue('trainer_001'),
            clientManagementRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: TrainerClientsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap + Add Client button
      await tester.tap(find.text('Add Client'));
      await tester.pumpAndSettle();

      // Verify Add New Client sheet is displayed
      expect(find.text('Add New Client'), findsOneWidget);
      expect(find.text('FULL NAME'), findsOneWidget);
      expect(find.text('EMAIL'), findsOneWidget);
      expect(find.text('AGE'), findsOneWidget);
      expect(find.text('CURRENT WEIGHT (kg)'), findsOneWidget);
      expect(find.text('FITNESS GOAL'), findsOneWidget);
      expect(find.text('TRAINING PLAN'), findsOneWidget);

      final nameField = find.widgetWithText(TextField, 'e.g. Jane Doe');
      final emailField = find.widgetWithText(TextField, 'jane@email.com');
      final ageField = find.widgetWithText(TextField, 'e.g. 28');
      final weightField = find.widgetWithText(TextField, 'e.g. 65');

      // Enter name only first
      await tester.enterText(nameField, 'Jane Doe');
      await tester.pump();

      // Tap disabled button at the bottom -> nothing submitted
      final submitButtonFinder = find.byKey(const Key('add_client_submit_button'));
      final sheetScrollable = find.byType(Scrollable).last;

      await tester.scrollUntilVisible(submitButtonFinder, 100, scrollable: sheetScrollable);
      await tester.tap(submitButtonFinder);
      await tester.pump();
      expect(find.text('Add New Client'), findsOneWidget); // still open

      // Scroll back up and fill remaining fields
      await tester.scrollUntilVisible(nameField, -100, scrollable: sheetScrollable);
      await tester.enterText(emailField, 'jane@email.com');
      await tester.enterText(ageField, '28');
      await tester.enterText(weightField, '65');
      await tester.pump();

      // Scroll down to select Muscle Gain goal
      final goalChip = find.text('Muscle Gain');
      await tester.scrollUntilVisible(goalChip, 100, scrollable: sheetScrollable);
      await tester.tap(goalChip);
      await tester.pump();

      // Scroll down to select Hypertrophy plan
      final planChip = find.text('Hypertrophy');
      await tester.scrollUntilVisible(planChip, 100, scrollable: sheetScrollable);
      await tester.tap(planChip);
      await tester.pump();

      // Now button is enabled, scroll to it and tap
      await tester.scrollUntilVisible(submitButtonFinder, 100, scrollable: sheetScrollable);
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      // Sheet should be closed and new client visible
      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('6 total · 5 active'), findsOneWidget);
    });

    testWidgets('Tapping a client card navigates to dedicated ClientDetailsScreen',
        (tester) async {
      final mockDatasource = ClientManagementMockDatasource();
      final repository = ClientManagementRepositoryImpl(mockDatasource);

      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            trainerClientTrainerIdProvider.overrideWithValue('trainer_001'),
            clientManagementRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: TrainerClientsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Sarah Chen card
      await tester.tap(find.text('Sarah Chen'));
      await tester.pumpAndSettle();

      // Verify dedicated ClientDetailsScreen rendered matching Screenshots 3 & 4
      expect(find.byType(ClientDetailsScreen), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.text('163cm'), findsOneWidget);
      expect(find.text('Height'), findsOneWidget);
      expect(find.text('Overall Progress'), findsOneWidget);
      expect(find.text('KEY METRICS'), findsOneWidget);
      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text('91%'), findsOneWidget);
      expect(find.text('Avg Intensity'), findsOneWidget);
      expect(find.text('8.2/10'), findsOneWidget);
      expect(find.text('Weight Change'), findsOneWidget);
      expect(find.text('-3.2kg'), findsOneWidget);
      expect(find.text('Goal on track'), findsOneWidget);
      expect(find.text('TRAINER NOTES'), findsOneWidget);
      expect(find.text('+ Add note'), findsOneWidget);
      expect(find.text('UPCOMING SESSIONS'), findsOneWidget);
      expect(find.text('TOD'), findsOneWidget);
      expect(find.text('THU'), findsOneWidget);
      expect(find.text('SAT'), findsOneWidget);
    });
  });
}
