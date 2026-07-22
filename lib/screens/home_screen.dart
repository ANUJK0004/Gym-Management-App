import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/domain/presentation/providers/auth_provider.dart';

class AuthTestScreen extends ConsumerWidget {
  const AuthTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authController = ref.read(
      authControllerProvider.notifier,
    );

    return Scaffold(
      body: Center(
        child: authState.when(
          loading: () => const CircularProgressIndicator(),

          error: (error, stack) {
            return Text(
              error.toString(),
            );
          },

          data: (user) {
            if (user == null) {
              return ElevatedButton(
                onPressed: () {
                  authController.signUp(
                    email: 'test@sweatsync.com',
                    password: 'Test123456',
                  );
                },
                child: const Text('Create Test Account'),
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(user.email),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    authController.signOut();
                  },
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
