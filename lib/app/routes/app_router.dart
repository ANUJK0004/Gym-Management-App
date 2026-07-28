import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sweatsync/core/presentation/screens/splash_screen.dart';

import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:sweatsync/features/auth/presentation/screens/login_screen.dart';
import 'package:sweatsync/features/auth/presentation/screens/register_screen.dart';

import 'package:sweatsync/features/dashboard/member/presentation/screens/member_shell.dart';

import 'package:sweatsync/features/profile/presentation/providers/current_user_profile_provider.dart';
import 'package:sweatsync/features/profile/presentation/screens/profile_setup_screen.dart';

import '../../features/membership/presentation/screens/membership_screen.dart';
import '../../features/workout/domain/entities/workout.dart';
import '../../features/workout/presentation/screens/workout_completed_screen.dart';
import '../../features/workout/presentation/screens/workout_detail_screen.dart';
import '../../features/workout/presentation/screens/workout_screen.dart';
import '../../features/workout/presentation/screens/workout_session_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  final profileState = ref.watch(currentUserProfileProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,

    redirect: (context, state) {
      final location = state.matchedLocation;

      final isAuthenticated = authState.value != null;

      final isAuthPage =
          location == AppRoutes.login || location == AppRoutes.register;

      final isProfileSetup = location == AppRoutes.profileSetup;

      final isSplash = location == AppRoutes.splash;

      // ------------------------------------------
      // AUTH STATE IS LOADING
      // ------------------------------------------

      if (authState.isLoading) {
        if (!isSplash) {
          return AppRoutes.splash;
        }

        return null;
      }

      // ------------------------------------------
      // USER IS NOT LOGGED IN
      // ------------------------------------------

      if (!isAuthenticated) {
        if (isAuthPage) {
          return null;
        }

        return AppRoutes.login;
      }

      // ------------------------------------------
      // USER IS LOGGED IN
      // WAIT FOR PROFILE
      // ------------------------------------------

      if (profileState.isLoading) {
        if (!isSplash) {
          return AppRoutes.splash;
        }

        return null;
      }

      // ------------------------------------------
      // PROFILE FAILED
      // ------------------------------------------

      if (profileState.hasError) {
        if (!isProfileSetup) {
          return AppRoutes.profileSetup;
        }

        return null;
      }

      // ------------------------------------------
      // PROFILE LOADED
      // ------------------------------------------

      final profile = profileState.value;

      // ------------------------------------------
      // NO PROFILE FOUND
      // ------------------------------------------

      if (profile == null) {
        if (!isProfileSetup) {
          return AppRoutes.profileSetup;
        }

        return null;
      }

      // ------------------------------------------
      // PROFILE INCOMPLETE
      // ------------------------------------------

      if (!profile.profileCompleted) {
        if (!isProfileSetup) {
          return AppRoutes.profileSetup;
        }

        return null;
      }

      // ------------------------------------------
      // PROFILE COMPLETE
      // ------------------------------------------

      if (profile.profileCompleted) {
        if (isSplash || isAuthPage || isProfileSetup) {
          return AppRoutes.home;
        }
      }

      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) {
          return const SplashScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) {
          return const ProfileSetupScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          return const MemberShell();
        },
      ),

      GoRoute(
        path: AppRoutes.membership,
        builder: (context, state) {
          return const MembershipScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.workout,
        builder: (context, state) {
          return const WorkoutScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.workoutDetail,
        builder: (context, state) {
          final workoutId = state.extra as String;

          return WorkoutDetailScreen(
            workoutId: workoutId,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.workoutSession,
        builder: (
            context,
            state,
            ) {
          final workout =
          state.extra as Workout;

          return WorkoutSessionScreen(
            workout: workout,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.workoutCompleted,
        builder: (
            context,
            state,
            ) {
          final data =
          state.extra
          as Map<String, dynamic>;

          final workout =
          data['workout'] as Workout;

          final duration =
          data['duration'] as int;

          final completedExercises =
          data['completedExercises']
          as int;

          return WorkoutCompletedScreen(
            workout: workout,
            duration: duration,
            completedExercises:
            completedExercises,
          );
        },
      ),
    ],
  );
});
