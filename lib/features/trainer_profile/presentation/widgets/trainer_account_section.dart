import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/trainer_profile.dart';
import '../providers/trainer_profile_provider.dart';

class TrainerAccountSection extends ConsumerWidget {
  const TrainerAccountSection({
    super.key,
    required this.settings,
  });

  final TrainerAccountSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------
        // SECTION TITLE
        // ------------------------------------------------
        const Text(
          'ACCOUNT',
          style: TextStyle(
            color: Color(0xFF8E9DAE),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),

        const SizedBox(height: 12),

        // ------------------------------------------------
        // GROUPED ACCOUNT CARD
        // ------------------------------------------------
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161922),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF262C3A),
              width: 0.8,
            ),
          ),
          child: Column(
            children: [
              // 1. Notifications
              _AccountRow(
                iconWidget: const Text('🔔', style: TextStyle(fontSize: 18)),
                title: 'Notifications',
                value: settings.notificationsEnabled ? 'On' : 'Off',
                onTap: () {
                  final next = !settings.notificationsEnabled;
                  ref
                      .read(trainerProfileControllerProvider.notifier)
                      .toggleNotifications(next);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF1E222D),
                      content: Text(
                        next
                            ? 'Notifications enabled 🔔'
                            : 'Notifications disabled 🔕',
                        style: const TextStyle(color: Colors.white),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const Divider(
                height: 1,
                thickness: 0.8,
                color: Color(0xFF222734),
                indent: 52,
                endIndent: 16,
              ),

              // 2. Client Messaging
              _AccountRow(
                iconWidget: const Text('💬', style: TextStyle(fontSize: 18)),
                title: 'Client Messaging',
                value: settings.clientMessagingEnabled ? 'Enabled' : 'Disabled',
                onTap: () {
                  final next = !settings.clientMessagingEnabled;
                  ref
                      .read(trainerProfileControllerProvider.notifier)
                      .toggleClientMessaging(next);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF1E222D),
                      content: Text(
                        next
                            ? 'Client messaging enabled 💬'
                            : 'Client messaging disabled',
                        style: const TextStyle(color: Colors.white),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const Divider(
                height: 1,
                thickness: 0.8,
                color: Color(0xFF222734),
                indent: 52,
                endIndent: 16,
              ),

              // 3. Privacy & Security
              _AccountRow(
                iconWidget: const Text('🔒', style: TextStyle(fontSize: 18)),
                title: 'Privacy & Security',
                value: '',
                onTap: () => _showPrivacySecurityDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPrivacySecurityDialog(BuildContext context) {
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
              Text('🔒', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Text(
                'Privacy & Security',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Text(
            'Your account is secured with end-to-end encrypted session records and biometric authentication support.',
            style: TextStyle(
              color: Color(0xFF8E9DAE),
              fontSize: 14,
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF0B132B),
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.iconWidget,
    required this.title,
    required this.value,
    this.onTap,
  });

  final Widget iconWidget;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              iconWidget,
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (value.isNotEmpty) ...[
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF8E9DAE),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF64748B),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
