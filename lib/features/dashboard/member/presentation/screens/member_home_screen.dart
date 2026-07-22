import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sweatsync/features/auth/presentation/providers/auth_provider.dart';


class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SweatSync'),
        actions: [
          IconButton(
            onPressed: () {
              ref
                  .read(authControllerProvider.notifier)
                  .signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome ${user?.email ?? ''}',
        ),
      ),
    );
  }
}