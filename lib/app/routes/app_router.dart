import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sweatsync/core/presentation/screens/splash_screen.dart';

import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:sweatsync/features/auth/presentation/screens/login_screen.dart';
import 'package:sweatsync/features/auth/presentation/screens/register_screen.dart';

import 'package:sweatsync/features/dashboard/member/presentation/screens/member_home_screen.dart';

import 'package:sweatsync/features/profile/presentation/providers/current_user_profile_provider.dart';
import 'package:sweatsync/features/profile/presentation/screens/profile_setup_screen.dart';

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
          return const MemberHomeScreen();
        },
      ),
    ],
  );
});
