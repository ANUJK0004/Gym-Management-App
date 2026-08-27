import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';

class TrainerSignOutButton extends ConsumerWidget {
  const TrainerSignOutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _confirmSignOut(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF220D12), // Deep red/maroon
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4D1A22), // Subtle red border
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Sign Out',
            style: TextStyle(
              color: Color(0xFFEF4444), // Bright red text
              fontWeight: FontWeight.w700,
              fontSize: 15.5,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161922),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF262C3A), width: 0.8),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 10),
              Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to sign out from the Trainer Portal?',
            style: TextStyle(
              color: Color(0xFF8E9DAE),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF8E9DAE)),
              ),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(authControllerProvider.notifier).signOut();
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }
}
