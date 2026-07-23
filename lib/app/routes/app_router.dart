import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:sweatsync/features/dashboard/member/presentation/screens/member_home_screen.dart';
import 'package:sweatsync/features/profile/presentation/providers/current_user_profile_provider.dart';
import 'package:sweatsync/features/profile/presentation/screens/profile_setup_screen.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  final profileState = ref.watch(currentUserProfileProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,

    redirect: (context, state) {
      final isAuthenticated = authState.value != null;

      final isGoingToLogin = state.matchedLocation == AppRoutes.login;

      final isGoingToRegister = state.matchedLocation == AppRoutes.register;

      final isGoingToAuthPage = isGoingToLogin || isGoingToRegister;

      final isGoingToProfileSetup =
          state.matchedLocation == AppRoutes.profileSetup;

      // Firebase Auth is still loading.
      if (authState.isLoading) {
        return null;
      }

      // User is not authenticated.
      if (!isAuthenticated) {
        if (!isGoingToAuthPage) {
          return AppRoutes.login;
        }

        return null;
      }

      // Profile is loading.
      if (profileState.isLoading) {
        return null;
      }

      // Profile failed to load.
      if (profileState.hasError) {
        if (!isGoingToProfileSetup) {
          return AppRoutes.profileSetup;
        }
        return null;
      }

      final profile = profileState.value;

      // User has no Firestore profile.
      if (profile == null) {
        if (!isGoingToProfileSetup) {
          return AppRoutes.profileSetup;
        }

        return null;
      }

      // User has incomplete profile.
      if (!profile.profileCompleted) {
        if (!isGoingToProfileSetup) {
          return AppRoutes.profileSetup;
        }

        return null;
      }

      // User has completed profile.
      if (profile.profileCompleted &&
          (isGoingToAuthPage || isGoingToProfileSetup)) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
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
