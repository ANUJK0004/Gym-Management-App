import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../member_management/presentation/providers/member_management_provider.dart';
import '../../../membership_plan/presentation/providers/membership_plan_provider.dart';
import '../../../trainer_management/presentation/providers/trainer_management_provider.dart';
import '../providers/owner_settings_provider.dart';

class BackupDataDialog extends ConsumerStatefulWidget {
  const BackupDataDialog({
    super.key,
    this.lastBackupAt,
  });

  final DateTime? lastBackupAt;

  @override
  ConsumerState<BackupDataDialog> createState() => _BackupDataDialogState();
}

class _BackupDataDialogState extends ConsumerState<BackupDataDialog> {
  bool _isBackingUp = false;
  DateTime? _latestBackupTime;

  @override
  void initState() {
    super.initState();
    _latestBackupTime = widget.lastBackupAt;
  }

  Future<void> _performBackup() async {
    setState(() {
      _isBackingUp = true;
    });

    try {
      final timestamp = await ref
          .read(ownerSettingsControllerProvider.notifier)
          .recordBackup();

      if (!mounted) return;

      if (timestamp != null) {
        setState(() {
          _latestBackupTime = timestamp;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gym data backup snapshot created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backup failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBackingUp = false;
        });
      }
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'No backup recorded yet';
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(gymMembersProvider);
    final plansAsync = ref.watch(ownerMembershipPlansProvider);
    final trainersAsync = ref.watch(gymTrainersProvider);

    final memberCount = membersAsync.value?.length ?? 0;
    final planCount = plansAsync.value?.length ?? 0;
    final trainerCount = trainersAsync.value?.length ?? 0;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLG),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.owner.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.backup_rounded,
                    color: AppColors.owner,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cloud Data Backup',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Snapshot & Export',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Securely sync and snapshot all current gym member profiles, active membership plans, and staff accounts to cloud storage.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: AppRadius.radiusMD,
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  _statRow(
                    label: 'Enrolled Members',
                    value: '$memberCount',
                    icon: Icons.people_outline_rounded,
                  ),
                  const Divider(height: 16, thickness: 0.4, color: AppColors.border),
                  _statRow(
                    label: 'Membership Plans',
                    value: '$planCount',
                    icon: Icons.workspace_premium_outlined,
                  ),
                  const Divider(height: 16, thickness: 0.4, color: AppColors.border),
                  _statRow(
                    label: 'Registered Trainers',
                    value: '$trainerCount',
                    icon: Icons.sports_gymnastics_rounded,
                  ),
                  const Divider(height: 16, thickness: 0.4, color: AppColors.border),
                  _statRow(
                    label: 'Last Backup',
                    value: _formatDate(_latestBackupTime),
                    icon: Icons.history_rounded,
                    highlight: _latestBackupTime != null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMD,
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isBackingUp ? null : _performBackup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.owner,
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMD,
                      ),
                    ),
                    child: _isBackingUp
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : const Text('Backup Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow({
    required String label,
    required String value,
    required IconData icon,
    bool highlight = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: highlight ? AppColors.owner : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
