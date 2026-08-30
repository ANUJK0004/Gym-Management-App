import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/app/routes/app_routes.dart';
import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/core/enums/app_role.dart';
import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';

import '../../../../design_system/appbar/app_back_button.dart';
import '../../../../design_system/buttons/primary_button.dart';
import '../../../../design_system/inputs/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({
    super.key,
    required this.role,
  });

  final AppRole role;

  @override
  ConsumerState<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends ConsumerState<RegisterScreen> {

  final _emailController =
  TextEditingController();

  final _passwordController =
  TextEditingController();

  Color _getRoleColor(AppRole role) {
    switch (role) {
      case AppRole.member:
        return AppColors.roleMember;
      case AppRole.trainer:
        return AppColors.roleTrainer;
      case AppRole.owner:
        return AppColors.roleOwner;
    }
  }

  Future<void> _register() async {
    await ref
        .read(
      authControllerProvider.notifier,
    )
        .signUp(
      email:
      _emailController.text.trim(),
      password:
      _passwordController.text.trim(),
      role: widget.role.name,
    );

    if (!mounted) return;

    final authState =
    ref.read(authControllerProvider);

    if (authState.hasError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            authState.error.toString(),
          ),
        ),
      );

      return;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState =
    ref.watch(authControllerProvider);
    final roleColor = _getRoleColor(widget.role);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leadingWidth: 56,
        leading: const Center(
          child: AppBackButton(
            fallbackRoute: AppRoutes.roleSelection,
          ),
        ),
        title: Text(
          'Create ${_formatRole(widget.role)} Account',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: roleColor.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  'Registering as ${_formatRole(widget.role)}',
                  style: TextStyle(
                    color: roleColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              AppTextField(
                controller:
                _emailController,
                label: 'Email',
                hint:
                'Enter your email',
                prefixIcon:
                Icons.email_outlined,
                focusedColor: roleColor,
              ),

              const SizedBox(
                height: 16,
              ),

              AppTextField(
                controller:
                _passwordController,
                label: 'Password',
                hint:
                'Create a password',
                prefixIcon:
                Icons.lock_outline,
                obscureText: true,
                focusedColor: roleColor,
              ),

              const SizedBox(
                height: 24,
              ),

              PrimaryButton(
                text:
                'Create Account',
                backgroundColor: roleColor,
                foregroundColor: Colors.black,
                isLoading:
                authState.isLoading,
                onPressed:
                _register,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRole(AppRole role) {
    return role.name[0].toUpperCase() +
        role.name.substring(1);
  }
}