import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sweatsync/app/routes/app_routes.dart';
import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';
import '../../../../design_system/buttons/primary_button.dart';
import '../../../../design_system/inputs/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    await ref.read(authControllerProvider.notifier).signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    final authState = ref.read(authControllerProvider);

    if (authState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
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
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              AppTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email',
                prefixIcon: Icons.email_outlined,
              ),

              const SizedBox(height: 16),

              AppTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),

              const SizedBox(height: 24),

              PrimaryButton(
                text: 'Login',
                isLoading: authState.isLoading,
                onPressed: _login,
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  // Forgot password
                },
                child: const Text(
                  'Forgot Password?',
                ),
              ),

              TextButton(
                onPressed: () {
                  context.push(AppRoutes.register);
                },
                child: const Text(
                  'Create an Account',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}