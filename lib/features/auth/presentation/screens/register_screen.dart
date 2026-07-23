import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';

import '../../../../design_system/buttons/primary_button.dart';
import '../../../../design_system/inputs/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    await ref.read(authControllerProvider.notifier).signUp(
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                hint: 'Create a password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
              ),

              const SizedBox(height: 24),

              PrimaryButton(
                text: 'Create Account',
                isLoading: authState.isLoading,
                onPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}