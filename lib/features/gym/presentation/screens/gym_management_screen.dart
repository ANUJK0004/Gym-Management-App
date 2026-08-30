import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/app/routes/app_routes.dart';
import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';
import 'package:sweatsync/design_system/appbar/app_back_button.dart';

import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';

import '../../domain/entities/gym.dart';
import '../providers/gym_provider.dart';

class GymManagementScreen
    extends ConsumerWidget {
  const GymManagementScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final gymAsync =
    ref.watch(ownerGymProvider);

    return Scaffold(
      backgroundColor:
      AppColors.background,

      appBar: AppBar(
        leadingWidth: 56,
        leading: const Center(
          child: AppBackButton(
            fallbackRoute: AppRoutes.ownerHome,
          ),
        ),
        title: const Text(
          'Gym Management',
        ),
        backgroundColor:
        AppColors.background,
      ),

      body: gymAsync.when(
        loading: () {
          return const Center(
            child:
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.owner),
            ),
          );
        },

        error: (
            error,
            stackTrace,
            ) {
          return Center(
            child: Padding(
              padding:
              const EdgeInsets.all(24),

              child: Text(
                'Unable to load gym.\n$error',
                textAlign:
                TextAlign.center,
              ),
            ),
          );
        },

        data: (gym) {
          if (gym == null) {
            return _NoGymView(
              onCreateGym: () {
                _openGymForm(
                  context,
                  ref,
                );
              },
            );
          }

          return _GymDetailsView(
            gym: gym,
            onEdit: () {
              _openGymForm(
                context,
                ref,
                gym: gym,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openGymForm(
      BuildContext context,
      WidgetRef ref, {
        Gym? gym,
      }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      AppColors.background,
      builder: (_) {
        return _GymForm(
          gym: gym,
        );
      },
    );

    ref.invalidate(
      ownerGymProvider,
    );
  }
}

// ------------------------------------------------------------
// NO GYM
// ------------------------------------------------------------

class _NoGymView
    extends StatelessWidget {
  const _NoGymView({
    required this.onCreateGym,
  });

  final VoidCallback onCreateGym;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [
            Container(
              width: 80,
              height: 80,

              decoration:
              BoxDecoration(
                color: AppColors.owner
                    .withValues(alpha: 0.12),
                borderRadius:
                AppRadius.radiusLG,
              ),

              child: const Icon(
                Icons
                    .fitness_center_rounded,
                size: 40,
                color:
                AppColors.owner,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              'Set Up Your Gym',
              style: AppTextStyles
                  .headlineMedium
                  .copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Create your gym profile to start managing members, trainers and membership plans.',
              textAlign:
              TextAlign.center,
              style: AppTextStyles
                  .bodyMedium
                  .copyWith(
                color: AppColors
                    .textSecondary,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            SizedBox(
              width:
              double.infinity,

              child:
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.owner,
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed:
                onCreateGym,

                child: const Text(
                  'Create Gym',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// GYM DETAILS
// ------------------------------------------------------------

class _GymDetailsView
    extends StatelessWidget {
  const _GymDetailsView({
    required this.gym,
    required this.onEdit,
  });

  final Gym gym;
  final VoidCallback onEdit;

  @override
  Widget build(
      BuildContext context,
      ) {
    return SingleChildScrollView(
      padding:
      const EdgeInsets.all(22),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Container(
            width:
            double.infinity,

            padding:
            const EdgeInsets.all(20),

            decoration:
            BoxDecoration(
              color:
              AppColors.surface,
              borderRadius:
              AppRadius.radiusLG,
              border:
              Border.all(
                color:
                AppColors.border,
                width: 0.5,
              ),
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,

                      decoration:
                      BoxDecoration(
                        color: AppColors
                            .owner
                            .withValues(
                            alpha: 0.12),
                        borderRadius:
                        BorderRadius
                            .circular(
                          16,
                        ),
                      ),

                      child:
                      const Icon(
                        Icons
                            .fitness_center_rounded,
                        color:
                        AppColors
                            .owner,
                        size: 28,
                      ),
                    ),

                    const SizedBox(
                      width: 14,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [
                          Text(
                            gym.name,
                            style:
                            AppTextStyles
                                .titleLarge
                                .copyWith(
                              fontWeight:
                              FontWeight
                                  .w700,
                            ),
                          ),

                          if (gym.email !=
                              null) ...[
                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              gym.email!,
                              style:
                              AppTextStyles
                                  .bodySmall
                                  .copyWith(
                                color: AppColors
                                    .textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed:
                      onEdit,
                      icon:
                      const Icon(
                        Icons
                            .edit_rounded,
                      ),
                    ),
                  ],
                ),

                if (gym.description !=
                    null) ...[
                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    gym.description!,
                    style:
                    AppTextStyles
                        .bodyMedium,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          Text(
            'GYM INFORMATION',
            style: AppTextStyles
                .labelMedium
                .copyWith(
              color: AppColors
                  .textSecondary,
              fontWeight:
              FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          _InfoCard(
            icon:
            Icons.location_on_outlined,
            label: 'Address',
            value:
            gym.address ??
                'Not provided',
          ),

          _InfoCard(
            icon:
            Icons.phone_outlined,
            label: 'Phone',
            value:
            gym.phone ??
                'Not provided',
          ),

          _InfoCard(
            icon:
            Icons.email_outlined,
            label: 'Email',
            value:
            gym.email ??
                'Not provided',
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// INFO CARD
// ------------------------------------------------------------

class _InfoCard
    extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
      const EdgeInsets.all(16),

      decoration:
      BoxDecoration(
        color:
        AppColors.surface,
        borderRadius:
        AppRadius.radiusMD,
        border:
        Border.all(
          color:
          AppColors.border,
          width: 0.5,
        ),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color:
            AppColors.owner,
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                Text(
                  label,
                  style:
                  AppTextStyles
                      .labelMedium
                      .copyWith(
                    color: AppColors
                        .textSecondary,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  value,
                  style:
                  AppTextStyles
                      .bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// FORM
// ------------------------------------------------------------

class _GymForm
    extends ConsumerStatefulWidget {
  const _GymForm({
    this.gym,
  });

  final Gym? gym;

  @override
  ConsumerState<_GymForm>
  createState() =>
      _GymFormState();
}

class _GymFormState
    extends ConsumerState<_GymForm> {
  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _nameController;

  late final TextEditingController
  _descriptionController;

  late final TextEditingController
  _addressController;

  late final TextEditingController
  _phoneController;

  late final TextEditingController
  _emailController;

  bool _isSaving = false;

  bool get _isEditing =>
      widget.gym != null;

  @override
  void initState() {
    super.initState();

    final gym = widget.gym;

    _nameController =
        TextEditingController(
          text: gym?.name ?? '',
        );

    _descriptionController =
        TextEditingController(
          text:
          gym?.description ?? '',
        );

    _addressController =
        TextEditingController(
          text: gym?.address ?? '',
        );

    _phoneController =
        TextEditingController(
          text: gym?.phone ?? '',
        );

    _emailController =
        TextEditingController(
          text: gym?.email ?? '',
        );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController
        .dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  Future<void> _saveGym() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = ref
        .read(firebaseAuthProvider)
        .currentUser;

    if (user == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repository =
      ref.read(gymRepositoryProvider);

      if (_isEditing) {
        final updatedGym = Gym(
          id: widget.gym!.id,
          ownerId: widget.gym!.ownerId,
          name: _nameController.text.trim(),
          description:
          _descriptionController.text.trim(),
          address:
          _addressController.text.trim(),
          phone:
          _phoneController.text.trim(),
          email:
          _emailController.text.trim(),
          logoUrl: widget.gym!.logoUrl,
          createdAt: widget.gym!.createdAt,
        );

        await repository.updateGym(
          updatedGym,
        );
      } else {
        final gym = Gym(
          // Firestore will generate the ID.
          id: '',
          ownerId: user.uid,
          name: _nameController.text.trim(),
          description:
          _descriptionController.text.trim(),
          address:
          _addressController.text.trim(),
          phone:
          _phoneController.text.trim(),
          email:
          _emailController.text.trim(),
          createdAt: DateTime.now(),
        );

        await repository.createGym(
          gym,
        );
      }

      ref.invalidate(
        ownerGymProvider,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save gym: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }


  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      EdgeInsets.only(
        left: 22,
        right: 22,
        top: 24,
        bottom:
        MediaQuery.of(context)
            .viewInsets
            .bottom +
            24,
      ),

      child:
      SingleChildScrollView(
        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,

            children: [
              Text(
                _isEditing
                    ? 'Edit Gym'
                    : 'Create Your Gym',

                style: AppTextStyles
                    .headlineMedium
                    .copyWith(
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              _field(
                controller:
                _nameController,
                label:
                'Gym Name',
                icon:
                Icons
                    .fitness_center_rounded,
                requiredField: true,
              ),

              _field(
                controller:
                _descriptionController,
                label:
                'Description',
                icon:
                Icons
                    .description_outlined,
                maxLines: 3,
              ),

              _field(
                controller:
                _addressController,
                label:
                'Address',
                icon:
                Icons
                    .location_on_outlined,
              ),

              _field(
                controller:
                _phoneController,
                label:
                'Phone',
                icon:
                Icons
                    .phone_outlined,
              ),

              _field(
                controller:
                _emailController,
                label:
                'Email',
                icon:
                Icons
                    .email_outlined,
              ),

              const SizedBox(
                height: 10,
              ),

              SizedBox(
                width:
                double.infinity,

                child:
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.owner,
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onPressed:
                  _isSaving
                      ? null
                      : _saveGym,

                  child: _isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                      : Text(
                    _isEditing
                        ? 'Save Changes'
                        : 'Create Gym',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController
    controller,
    required String label,
    required IconData icon,
    bool requiredField = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 14,
      ),

      child: TextFormField(
        controller: controller,
        maxLines: maxLines,

        decoration:
        InputDecoration(
          labelText: label,
          prefixIcon:
          Icon(icon),
        ),

        validator:
        requiredField
            ? (value) {
          if (value ==
              null ||
              value
                  .trim()
                  .isEmpty) {
            return '$label is required';
          }

          return null;
        }
            : null,
      ),
    );
  }
}