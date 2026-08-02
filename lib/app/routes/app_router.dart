import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sweatsync/core/presentation/screens/splash_screen.dart';

import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';
import 'package:sweatsync/features/auth/presentation/screens/login_screen.dart';
import 'package:sweatsync/features/auth/presentation/screens/register_screen.dart';

import 'package:sweatsync/features/dashboard/member/presentation/screens/member_shell.dart';

import 'package:sweatsync/features/profile/presentation/providers/current_user_profile_provider.dart';
import 'package:sweatsync/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:sweatsync/features/profile/presentation/screens/profile_setup_screen.dart';

import '../../core/enums/app_role.dart';
import '../../features/dashboard/owner/presentation/screens/owner_shell.dart';
import '../../features/dashboard/trainer/presentation/screens/trainer_shell.dart';
import '../../features/gym/presentation/screens/gym_management_screen.dart';
import '../../features/membership/presentation/screens/membership_screen.dart';
import '../../features/owner/presentation/screens/owner_setup_screen.dart';
import '../../features/profile/domain/entities/user_profile.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/role_selection/presentation/screens/role_selection_screen.dart';
import '../../features/workout/domain/entities/workout.dart';
import '../../features/workout/presentation/screens/workout_completed_screen.dart';
import '../../features/workout/presentation/screens/workout_detail_screen.dart';
import '../../features/workout/presentation/screens/workout_screen.dart';
import '../../features/workout/presentation/screens/workout_session_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  final profileState = ref.watch(
    currentUserProfileProvider,
  );

  return GoRouter(
    initialLocation: AppRoutes.splash,

    redirect: (context, state) {
      final location = state.matchedLocation;

      final isAuthenticated =
          authState.value != null;

      final isAuthPage =
          location == AppRoutes.login ||
              location == AppRoutes.register;

      final isRoleSelection =
          location == AppRoutes.roleSelection;

      final isProfileSetup =
          location == AppRoutes.profileSetup;

      final isSplash =
          location == AppRoutes.splash;

      // ------------------------------------------
      // 1. AUTH STATE IS STILL LOADING
      // ------------------------------------------

      if (authState.isLoading) {
        if (isSplash) {
          return null;
        }

        return AppRoutes.splash;
      }

      // ------------------------------------------
      // 2. USER IS NOT LOGGED IN
      // ------------------------------------------

      if (!isAuthenticated) {
        // Allow the user to stay on Role Selection.
        if (isRoleSelection) {
          return null;
        }

        // Allow Login and Register.
        if (isAuthPage) {
          return null;
        }

        // Any other page requires authentication.
        return AppRoutes.roleSelection;
      }

      // ------------------------------------------
      // 3. USER IS LOGGED IN
      // WAIT FOR PROFILE
      // ------------------------------------------

      if (profileState.isLoading) {
        if (isSplash) {
          return null;
        }

        return AppRoutes.splash;
      }

      // ------------------------------------------
      // 4. PROFILE FAILED
      // ------------------------------------------

      if (profileState.hasError) {
        if (isProfileSetup) {
          return null;
        }

        return AppRoutes.profileSetup;
      }

      // ------------------------------------------
      // 5. PROFILE LOADED
      // ------------------------------------------

      final profile = profileState.value;

      // ------------------------------------------
      // 6. NO PROFILE FOUND
      // ------------------------------------------

      if (profile == null) {
        if (isProfileSetup) {
          return null;
        }

        return AppRoutes.profileSetup;
      }

      // ------------------------------------------
      // 7. PROFILE IS INCOMPLETE
      // ------------------------------------------

      if (!profile.profileCompleted) {
        if (isProfileSetup) {
          return null;
        }

        return AppRoutes.profileSetup;
      }

      // ------------------------------------------
      // 8. PROFILE IS COMPLETE
      // ------------------------------------------

      if (profile.profileCompleted) {
        if (profile.role == 'owner') {
          if (profile.gymId == null) {
            if (location != AppRoutes.ownerSetup) {
              return AppRoutes.ownerSetup;
            }

            return null;
          }

          if (isSplash ||
              isAuthPage ||
              isProfileSetup ||
              location == AppRoutes.ownerSetup) {
            return AppRoutes.ownerHome;
          }
        }

        if (profile.role == 'member') {
          if (isSplash ||
              isAuthPage ||
              isProfileSetup) {
            return AppRoutes.home;
          }
        }
      }
      return null;
    },

    routes: [
      // ------------------------------------------
      // SPLASH
      // ------------------------------------------

      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) {
          return const SplashScreen();
        },
      ),

      // ------------------------------------------
      // ROLE SELECTION
      // ------------------------------------------

      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) {
          return const RoleSelectionScreen();
        },
      ),

      // ------------------------------------------
      // AUTH
      // ------------------------------------------

      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          final role = state.extra as AppRole;

          return LoginScreen(
            role: role,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) {
          final role = state.extra as AppRole;

          return RegisterScreen(
            role: role,
          );
        },
      ),

      // ------------------------------------------
      // PROFILE SETUP
      // ------------------------------------------

      GoRoute(
        path: AppRoutes.ownerSetup,
        builder: (
            context,
            state,
            ) {
          return const OwnerSetupScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) {
          return const ProfileSetupScreen();
        },
      ),

      // ------------------------------------------
      // MEMBER HOME
      // ------------------------------------------
      GoRoute(
        path: AppRoutes.ownerHome,
        builder: (
            context,
            state,
            ) {
          return const OwnerShell();
        },
      ),

      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          return const MemberShell();
        },
      ),

      // ------------------------------------------
      // MEMBERSHIP
      // ------------------------------------------

      GoRoute(
        path: AppRoutes.membership,
        builder: (context, state) {
          return const MembershipScreen();
        },
      ),

      // ------------------------------------------
      // WORKOUT
      // ------------------------------------------

      GoRoute(
        path: AppRoutes.workout,
        builder: (context, state) {
          return const WorkoutScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.workoutDetail,
        builder: (context, state) {
          final workoutId =
          state.extra as String;

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

      // ------------------------------------------
      // PROGRESS
      // ------------------------------------------

      GoRoute(
        path: AppRoutes.progress,
        builder: (context, state) {
          return const ProgressScreen();
        },
      ),

      // ------------------------------------------
      // PROFILE
      // ------------------------------------------

      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) {
          return const ProfileScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) {
          final profile =
          state.extra as UserProfile;

          return EditProfileScreen(
            profile: profile,
          );
        },
      ),


      GoRoute(
        path: AppRoutes.trainerHome,
        builder: (context, state) {
          return const TrainerShell();
        },
      ),

      GoRoute(
        path: AppRoutes.ownerHome,
        builder: (context, state) {
          return const OwnerShell();
        },
      ),

      GoRoute(
        path: AppRoutes.ownerGymManagement,
        builder: (
            context,
            state,
            ) {
          return const GymManagementScreen();
        },
      ),
    ],
  );
});