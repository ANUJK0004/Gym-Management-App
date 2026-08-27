import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/trainer_client.dart';
import '../providers/client_management_provider.dart';

class ClientDetailsSheet extends ConsumerWidget {
  const ClientDetailsSheet({
    super.key,
    required this.client,
  });

  static Future<void> show(BuildContext context, TrainerClient client) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClientDetailsSheet(client: client),
    );
  }

  final TrainerClient client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF141720),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF333B4E),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Header with Avatar & Details
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF334155),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        client.initials,
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (client.isActive)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF141720),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        client.email,
                        style: const TextStyle(
                          color: Color(0xFF8E9DAE),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E222D),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2A3040),
                        width: 0.8,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF8E9DAE),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Stat Badges
            Row(
              children: [
                Expanded(
                  child: _DetailStatBox(
                    label: 'Status',
                    value: client.isActive ? 'Active' : 'Inactive',
                    valueColor: client.isActive
                        ? const Color(0xFF4ADE80)
                        : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DetailStatBox(
                    label: 'Sessions',
                    value: '${client.sessionsCount}',
                    valueColor: const Color(0xFF38BDF8),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DetailStatBox(
                    label: 'Streak',
                    value: '${client.streakDays}d 🔥',
                    valueColor: const Color(0xFFFB923C),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Detail items
            _buildDetailSection(
              title: 'PROGRAM & GOALS',
              children: [
                _buildInfoRow('Fitness Goal', client.goal),
                _buildInfoRow('Training Plan', client.trainingPlan),
                _buildInfoRow('Overall Progress', '${client.progressPercentage}%'),
                _buildInfoRow(
                  'Next Session',
                  client.nextSession ?? 'Not scheduled',
                ),
              ],
            ),

            const SizedBox(height: 14),

            _buildDetailSection(
              title: 'BIOMETRICS & CONTACT',
              children: [
                _buildInfoRow('Age', client.age != null ? '${client.age} yrs' : '--'),
                _buildInfoRow('Current Weight', client.formattedWeight),
                _buildInfoRow('Phone', client.phone ?? 'Not provided'),
              ],
            ),

            const SizedBox(height: 22),

            // Actions: Toggle Active Status & Delete Client
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref
                          .read(clientManagementProvider.notifier)
                          .toggleActiveStatus(client.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF1E222D),
                          content: Text(
                            'Client marked as ${!client.isActive ? "Active" : "Inactive"}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF262C3A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: Icon(
                      client.isActive
                          ? Icons.pause_circle_outline_rounded
                          : Icons.play_circle_outline_rounded,
                      color: const Color(0xFF38BDF8),
                      size: 18,
                    ),
                    label: Text(
                      client.isActive ? 'Deactivate' : 'Activate',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showDeleteConfirmation(context, ref);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444),
                      size: 18,
                    ),
                    label: const Text(
                      'Remove',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161922),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF262C3A)),
        ),
        title: const Text(
          'Remove Client?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to remove ${client.name} from your client list?',
          style: const TextStyle(color: Color(0xFF8E9DAE)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E9DAE))),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              ref.read(clientManagementProvider.notifier).deleteClient(client.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF161922),
                  content: Text('${client.name} removed'),
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1218),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF262C3A),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8E9DAE),
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStatBox extends StatelessWidget {
  const _DetailStatBox({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1218),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF262C3A),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8E9DAE),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
