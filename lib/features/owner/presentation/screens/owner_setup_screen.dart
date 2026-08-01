import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/buttons/primary_button.dart';
import '../../../../design_system/inputs/app_text_field.dart';

import '../../../profile/presentation/providers/current_user_profile_provider.dart';

import '../providers/owner_setup_provider.dart';

class OwnerSetupScreen
    extends ConsumerStatefulWidget {
  const OwnerSetupScreen({
    super.key,
  });

  @override
  ConsumerState<OwnerSetupScreen>
  createState() =>
      _OwnerSetupScreenState();
}

class _OwnerSetupScreenState
    extends ConsumerState<OwnerSetupScreen> {
  final _gymNameController =
  TextEditingController();

  final _descriptionController =
  TextEditingController();

  final _addressController =
  TextEditingController();

  final _phoneController =
  TextEditingController();

  final _emailController =
  TextEditingController();

  @override
  void dispose() {
    _gymNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  Future<void> _createGym() async {
    final firebaseUser =
        FirebaseAuth
            .instance
            .currentUser;

    if (firebaseUser == null) {
      _showMessage(
        'Your session has expired. Please log in again.',
      );

      return;
    }

    final gymName =
    _gymNameController
        .text
        .trim();

    if (gymName.isEmpty) {
      _showMessage(
        'Please enter your gym name.',
      );

      return;
    }

    await ref
        .read(
      ownerSetupProvider
          .notifier,
    )
        .completeOwnerSetup(
      uid: firebaseUser.uid,
      gymName: gymName,
      description:
      _descriptionController
          .text,
      address:
      _addressController
          .text,
      phone:
      _phoneController
          .text,
      email:
      _emailController
          .text,
    );

    if (!mounted) {
      return;
    }

    final state =
    ref.read(
      ownerSetupProvider,
    );

    if (state.hasError) {
      _showMessage(
        'Failed to create gym: ${state.error}',
      );

      return;
    }

    // Refresh profile so router
    // can detect profileCompleted = true
    // and gymId.
    ref.invalidate(
      currentUserProfileProvider,
    );
  }

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger
        .of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final state =
    ref.watch(
      ownerSetupProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Set Up Your Gym',
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              const Text(
                'Create Your Gym',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'Set up your gym to start managing members, trainers, workouts and memberships.',
              ),

              const SizedBox(
                height: 32,
              ),

              AppTextField(
                controller:
                _gymNameController,
                label: 'Gym Name',
                hint:
                'Enter your gym name',
                prefixIcon:
                Icons.fitness_center,
              ),

              const SizedBox(
                height: 16,
              ),

              AppTextField(
                controller:
                _descriptionController,
                label: 'Description',
                hint:
                'Tell members about your gym',
                prefixIcon:
                Icons.description_outlined,
              ),

              const SizedBox(
                height: 16,
              ),

              AppTextField(
                controller:
                _addressController,
                label: 'Address',
                hint:
                'Enter gym address',
                prefixIcon:
                Icons.location_on_outlined,
              ),

              const SizedBox(
                height: 16,
              ),

              AppTextField(
                controller:
                _phoneController,
                label: 'Phone',
                hint:
                'Enter gym phone number',
                prefixIcon:
                Icons.phone_outlined,
              ),

              const SizedBox(
                height: 16,
              ),

              AppTextField(
                controller:
                _emailController,
                label: 'Gym Email',
                hint:
                'Enter gym email',
                prefixIcon:
                Icons.email_outlined,
              ),

              const SizedBox(
                height: 32,
              ),

              PrimaryButton(
                text:
                'Create Gym',
                isLoading:
                state.isLoading,
                onPressed:
                _createGym,
              ),
            ],
          ),
        ),
      ),
    );
  }
}