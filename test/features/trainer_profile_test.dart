import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sweatsync/features/trainer_profile/data/datasources/trainer_profile_remote_datasource.dart';
import 'package:sweatsync/features/trainer_profile/data/repositories/trainer_profile_repository_impl.dart';
import 'package:sweatsync/features/trainer_profile/presentation/providers/trainer_profile_provider.dart';
import 'package:sweatsync/features/trainer_profile/presentation/screens/trainer_profile_screen.dart';

void main() {
  group('TrainerProfileProvider Unit Tests', () {
    late ProviderContainer container;
    late TrainerProfileRemoteDataSource datasource;

    setUp(() {
      TrainerProfileRemoteDataSource.resetToDefault();
      datasource = TrainerProfileRemoteDataSource();
      final repository = TrainerProfileRepositoryImpl(datasource);

      container = ProviderContainer(
        overrides: [
          trainerProfileRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial profile state loads correct mock data from screenshots', () async {
      final profile = await container.read(trainerProfileControllerProvider.future);

      expect(profile.name, equals('Coach Mike Torres'));
      expect(profile.title, equals('Senior Personal Trainer'));
      expect(profile.email, equals('mike.torres@gymsync.com'));
      expect(profile.initials, equals('MT'));
      expect(profile.isVerified, isTrue);
      expect(profile.rating, equals(4.9));
      expect(profile.reviewCount, equals(128));
      expect(profile.clientCount, equals(5));
      expect(profile.experienceYears, equals(3.2));
      expect(profile.sessionCount, equals(142));
      expect(profile.specializations.length, equals(5));
      expect(profile.specializations, contains('Strength & Conditioning'));
      expect(profile.specializations, contains('HIIT'));
      expect(profile.specializations, contains('Weight Loss'));
      expect(profile.specializations, contains('Athletic Performance'));
      expect(profile.specializations, contains('Nutrition Coaching'));
      expect(profile.certifications.length, equals(4));
      expect(profile.monthlyMetrics.sessionsCompleted, equals(38));
      expect(profile.monthlyMetrics.clientRetentionPercentage, equals(96));
      expect(profile.monthlyMetrics.avgSessionRating, equals(4.9));
      expect(profile.monthlyMetrics.newClientsCount, equals(2));
      expect(profile.availability.workingHours, equals('8AM–6PM'));
      expect(profile.availability.daysAvailable, equals('Mon–Sat'));
      expect(profile.availability.sessionDuration, equals('45–60 min'));
      expect(profile.accountSettings.notificationsEnabled, isTrue);
      expect(profile.accountSettings.clientMessagingEnabled, isTrue);
    });

    test('updateProfile updates state dynamically', () async {
      final initial = await container.read(trainerProfileControllerProvider.future);
      final updated = initial.copyWith(
        name: 'Coach Michael Torres',
        title: 'Lead Strength Coach',
      );

      final controller = container.read(trainerProfileControllerProvider.notifier);
      await controller.updateProfile(updated);

      final current = container.read(trainerProfileProvider).value;
      expect(current?.name, equals('Coach Michael Torres'));
      expect(current?.title, equals('Lead Strength Coach'));
    });

    test('toggleNotifications updates notification setting', () async {
      final controller = container.read(trainerProfileControllerProvider.notifier);
      await container.read(trainerProfileControllerProvider.future);

      await controller.toggleNotifications(false);
      expect(
        container.read(trainerProfileProvider).value?.accountSettings.notificationsEnabled,
        isFalse,
      );

      await controller.toggleNotifications(true);
      expect(
        container.read(trainerProfileProvider).value?.accountSettings.notificationsEnabled,
        isTrue,
      );
    });

    test('updateAvailability updates working hours and days', () async {
      final controller = container.read(trainerProfileControllerProvider.notifier);
      await container.read(trainerProfileControllerProvider.future);

      await controller.updateAvailability(
        workingHours: '7AM–7PM',
        daysAvailable: 'Mon–Fri',
      );

      final availability =
          container.read(trainerProfileProvider).value?.availability;
      expect(availability?.workingHours, equals('7AM–7PM'));
      expect(availability?.daysAvailable, equals('Mon–Fri'));
    });
  });

  group('TrainerProfileScreen Widget Tests', () {
    setUp(() {
      TrainerProfileRemoteDataSource.resetToDefault();
    });

    testWidgets('Renders all elements from Screenshots 1, 2, and 3 accurately',
        (tester) async {
      final datasource = TrainerProfileRemoteDataSource();
      final repository = TrainerProfileRepositoryImpl(datasource);

      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            trainerProfileRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: TrainerProfileScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // 1. Top Bar
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);

      // 2. Identity / Avatar
      expect(find.text('MT'), findsOneWidget);
      expect(find.text('Coach Mike Torres'), findsOneWidget);
      expect(find.text('Senior Personal Trainer'), findsOneWidget);
      expect(find.text('mike.torres@gymsync.com'), findsOneWidget);
      expect(find.text('4.9 (128 reviews)'), findsOneWidget);

      // 3. Stats Row
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Clients'), findsOneWidget);
      expect(find.text('3.2yr'), findsOneWidget);
      expect(find.text('Experience'), findsOneWidget);
      expect(find.text('142'), findsOneWidget);
      expect(find.text('Sessions'), findsOneWidget);

      // 4. Specializations
      expect(find.text('SPECIALIZATIONS'), findsOneWidget);
      expect(find.text('Strength & Conditioning'), findsOneWidget);
      expect(find.text('HIIT'), findsOneWidget);
      expect(find.text('Weight Loss'), findsOneWidget);
      expect(find.text('Athletic Performance'), findsOneWidget);
      expect(find.text('Nutrition Coaching'), findsOneWidget);

      // 5. Certifications
      expect(find.text('CERTIFICATIONS'), findsOneWidget);
      expect(find.text('NSCA Certified Personal Trainer'), findsOneWidget);
      expect(find.text('Obtained 2019'), findsOneWidget);
      expect(find.text('Precision Nutrition Level 1'), findsOneWidget);
      expect(find.text('Obtained 2020'), findsOneWidget);
      expect(find.text('TRX Suspension Training'), findsOneWidget);
      expect(find.text('Obtained 2021'), findsOneWidget);

      // Scroll down to check remaining sections
      final scrollable = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(find.text('Sign Out'), 200, scrollable: scrollable);
      await tester.pumpAndSettle();

      // 6. Continuation of Certifications
      expect(find.text('First Aid & CPR Certified'), findsOneWidget);
      expect(find.text('Obtained 2023'), findsOneWidget);

      // 7. This Month
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('38'), findsOneWidget);
      expect(find.text('Sessions Completed'), findsOneWidget);
      expect(find.text('96%'), findsOneWidget);
      expect(find.text('Client Retention'), findsOneWidget);
      expect(find.text('Avg Session Rating'), findsOneWidget);
      expect(find.text('+2'), findsOneWidget);
      expect(find.text('New Clients'), findsOneWidget);

      // 8. Availability
      expect(find.text('AVAILABILITY'), findsOneWidget);
      expect(find.text('Working Hours'), findsOneWidget);
      expect(find.text('8AM–6PM'), findsOneWidget);
      expect(find.text('Days Available'), findsOneWidget);
      expect(find.text('Mon–Sat'), findsOneWidget);
      expect(find.text('Session Duration'), findsOneWidget);
      expect(find.text('45–60 min'), findsOneWidget);

      // 9. Account
      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('On'), findsOneWidget);
      expect(find.text('Client Messaging'), findsOneWidget);
      expect(find.text('Enabled'), findsOneWidget);
      expect(find.text('Privacy & Security'), findsOneWidget);

      // 10. Sign Out Button
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('Tapping edit icon opens EditTrainerProfileSheet and saves updates',
        (tester) async {
      final datasource = TrainerProfileRemoteDataSource();
      final repository = TrainerProfileRepositoryImpl(datasource);

      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            trainerProfileRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: TrainerProfileScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Tap edit button in top bar
      await tester.tap(find.byIcon(Icons.edit_rounded));
      await tester.pumpAndSettle();

      // Verify bottom sheet opened
      expect(find.text('Edit Trainer Profile'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Title / Subtitle'), findsOneWidget);

      // Update full name
      final nameField = find.byKey(const Key('edit_trainer_name_field'));
      await tester.enterText(nameField, 'Coach Mike Vance');
      await tester.pump();

      // Tap Save Changes
      await tester.tap(find.text('Save Changes'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Verify updated name on profile screen
      expect(find.text('Coach Mike Vance'), findsOneWidget);
    });
  });
}
