import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sweatsync/app/routes/app_routes.dart';
import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/core/enums/app_role.dart';
import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';

import '../../../../design_system/appbar/app_back_button.dart';
import '../../../../design_system/buttons/primary_button.dart';
import '../../../../design_system/inputs/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    required this.role,
  });

  final AppRole role;

  @override
  ConsumerState<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends ConsumerState<LoginScreen> {

  final _emailController =
  TextEditingController();

  final _passwordController =
  TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

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

  Future<void> _login() async {
    await ref
        .read(
      authControllerProvider.notifier,
    )
        .signIn(
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
  Widget build(BuildContext context) {
    final authState =
    ref.watch(authControllerProvider);
    final roleColor = _getRoleColor(widget.role);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackButton(
                fallbackRoute: AppRoutes.roleSelection,
              ),

              const SizedBox(
                height: 32,
              ),

              Center(
                child: Column(
                  children: [
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
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
                        'Logging in as ${_formatRole(widget.role)}',
                        style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 32,
                    ),

                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      focusedColor: roleColor,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      focusedColor: roleColor,
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    PrimaryButton(
                      text: 'Login',
                      backgroundColor: roleColor,
                      foregroundColor: Colors.black,
                      isLoading: authState.isLoading,
                      onPressed: _login,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    TextButton(
                      onPressed: () {
                        // Forgot password
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        context.push(
                          AppRoutes.register,
                          extra: widget.role,
                        );
                      },
                      child: Text(
                        'Create an Account',
                        style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
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