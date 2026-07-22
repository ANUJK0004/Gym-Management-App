import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/member_home_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,

    redirect: (context, state) {
      final isAuthenticated = authState.value != null;

      final isGoingToLogin =
          state.matchedLocation == AppRoutes.login;

      final isGoingToRegister =
          state.matchedLocation == AppRoutes.register;

      final isGoingToAuthPage =
          isGoingToLogin || isGoingToRegister;

      // Firebase is still checking the authentication state.
      if (authState.isLoading) {
        return null;
      }

      // User is NOT authenticated.
      if (!isAuthenticated) {
        if (!isGoingToAuthPage) {
          return AppRoutes.login;
        }

        return null;
      }

      // User is authenticated.
      if (isAuthenticated && isGoingToAuthPage) {
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
        path: AppRoutes.home,
        builder: (context, state) {
          return const MemberHomeScreen();
        },
      ),
    ],
  );
});