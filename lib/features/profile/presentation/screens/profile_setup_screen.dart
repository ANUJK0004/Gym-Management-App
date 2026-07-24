import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweatsync/design_system/buttons/primary_button.dart';
import 'package:sweatsync/design_system/buttons/secondary_button.dart';
import 'package:sweatsync/design_system/common/app_scaffold.dart';
import 'package:sweatsync/design_system/indicators/app_progress_indicator.dart';
import 'package:sweatsync/features/profile/presentation/providers/current_user_profile_provider.dart';
import 'package:sweatsync/features/profile/presentation/providers/profile_setup_provider.dart';
import '../widgets/basic_info_page.dart';
import '../widgets/body_info_page.dart';
import '../widgets/fitness_goal_page.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  bool _isCompleting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeProfile() async {
    if (_isCompleting) {
      return;
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User session expired. Please log in again.'),
        ),
      );

      return;
    }

    final notifier = ref.read(profileSetupProvider.notifier);

    if (!notifier.validateProfile()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all profile details.')),
      );

      return;
    }

    setState(() {
      _isCompleting = true;
    });

    try {
      await notifier.completeProfile(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
      );

      ref.invalidate(currentUserProfileProvider);

    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save profile: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentPage + 1) / 3;

    final isLastPage = _currentPage == 2;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  Text(
                    'Step ${_currentPage + 1} of 3',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const Spacer(),

                  Text('${(progress * 100).round()}%'),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppProgressIndicator(value: progress),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: const [
                  BasicInfoPage(),
                  BodyInfoPage(),
                  FitnessGoalPage(),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0) ...[
                    Expanded(
                      child: SecondaryButton(
                        text: 'Back',
                        onPressed: _isCompleting ? null : _previousPage,
                      ),
                    ),

                    const SizedBox(width: 12),
                  ],

                  Expanded(
                    child: PrimaryButton(
                      text: isLastPage ? 'Complete' : 'Continue',
                      isLoading: _isCompleting,
                      onPressed: isLastPage ? _completeProfile : _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
