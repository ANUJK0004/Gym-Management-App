import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/attendance_record.dart';

class AttendanceCard extends StatelessWidget {
  const AttendanceCard({
    super.key,
    required this.record,
    this.onCheckOut,
  });

  final AttendanceRecord record;
  final VoidCallback? onCheckOut;

  @override
  Widget build(BuildContext context) {
    final isInGym = record.isCurrentlyInGym;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: isInGym ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
          width: isInGym ? 1.0 : 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: record.isMember
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.lightBlue.withValues(alpha: 0.15),
                backgroundImage: record.userPhotoUrl != null && record.userPhotoUrl!.isNotEmpty
                    ? NetworkImage(record.userPhotoUrl!)
                    : null,
                child: record.userPhotoUrl == null || record.userPhotoUrl!.isEmpty
                    ? Text(
                        _getInitials(record.userName),
                        style: TextStyle(
                          color: record.isMember ? AppColors.primary : Colors.lightBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // Name & Role/Plan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            record.userName,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _buildRoleChip(record.userRole),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.isMember
                          ? (record.membershipPlanName ?? 'Gym Member')
                          : (record.specialization ?? 'Fitness Trainer'),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Status Badge
              _buildStatusBadge(isInGym),
            ],
          ),

          const SizedBox(height: 12),

          const Divider(height: 1, color: AppColors.border),

          const SizedBox(height: 10),

          // Timestamps & Duration Footer
          Row(
            children: [
              // Check in time
              _buildTimeItem(
                icon: Icons.login_rounded,
                label: 'In',
                time: _formatTime(record.checkInTime),
                color: Colors.greenAccent,
              ),

              const SizedBox(width: 14),

              // Check out time
              _buildTimeItem(
                icon: Icons.logout_rounded,
                label: 'Out',
                time: record.checkOutTime != null
                    ? _formatTime(record.checkOutTime!)
                    : 'Active',
                color: record.checkOutTime != null ? Colors.orangeAccent : AppColors.primary,
              ),

              const Spacer(),

              // Duration / Method
              if (record.durationMinutes != null && record.durationMinutes! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(record.durationMinutes!),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

              if (isInGym && onCheckOut != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onCheckOut,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.4), width: 0.5),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.exit_to_app_rounded, size: 13, color: Colors.redAccent),
                        SizedBox(width: 4),
                        Text(
                          'Check Out',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    final isMember = role.toLowerCase() == 'member';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isMember
            ? AppColors.primary.withValues(alpha: 0.15)
            : Colors.lightBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isMember ? 'MEMBER' : 'TRAINER',
        style: TextStyle(
          color: isMember ? AppColors.primary : Colors.lightBlue,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isInGym) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isInGym
            ? Colors.greenAccent.withValues(alpha: 0.12)
            : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isInGym
              ? Colors.greenAccent.withValues(alpha: 0.4)
              : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isInGym ? Colors.greenAccent : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isInGym ? 'In Gym' : 'Checked Out',
            style: TextStyle(
              color: isInGym ? Colors.greenAccent : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        Text(
          time,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final remainingMins = minutes % 60;
    return remainingMins > 0 ? '${hours}h ${remainingMins}m' : '${hours}h';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
