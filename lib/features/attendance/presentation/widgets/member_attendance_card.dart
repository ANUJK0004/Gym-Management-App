import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/attendance_provider.dart';
import 'gym_qr_scanner_sheet.dart';
import 'member_attendance_history_sheet.dart';

class MemberAttendanceCard extends ConsumerWidget {
  const MemberAttendanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayRecordAsync = ref.watch(memberTodayAttendanceProvider);
    final historyAsync = ref.watch(memberAttendanceHistoryProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GYM ATTENDANCE',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Check-in & Tracking',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // History button
              InkWell(
                onTap: () => _openHistorySheet(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'History',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          todayRecordAsync.when(
            loading: () => const SizedBox(
              height: 50,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (err, _) => Text(
              'Unable to load attendance: $err',
              style: AppTextStyles.bodySmall,
            ),
            data: (record) {
              final isPresent = record != null && record.isCurrentlyInGym;
              final isCheckedOut = record != null && record.isCheckedOut;

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadius.radiusMD,
                      border: Border.all(
                        color: isPresent
                            ? Colors.greenAccent.withValues(alpha: 0.4)
                            : AppColors.border,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isPresent
                                ? Colors.greenAccent
                                : (isCheckedOut ? Colors.orangeAccent : AppColors.textSecondary),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isPresent
                                ? 'Present in Gym (Since ${_formatTime(record.checkInTime)})'
                                : (isCheckedOut
                                    ? 'Completed workout today (${_formatTime(record.checkInTime)} - ${_formatTime(record.checkOutTime!)})'
                                    : 'Not checked in today'),
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isPresent ? Colors.greenAccent : AppColors.textPrimary,
                              fontWeight: isPresent ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      // Monthly visits badge
                      historyAsync.when(
                        data: (history) {
                          final currentMonthCount = history.length;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: AppRadius.radiusMD,
                              border: Border.all(color: AppColors.border, width: 0.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$currentMonthCount Visits',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Total Logged',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const SizedBox(),
                        error: (_, _) => const SizedBox(),
                      ),

                      const SizedBox(width: 10),

                      // Action Button (Scan / Check Out)
                      Expanded(
                        child: isPresent
                            ? OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.red.withValues(alpha: 0.6),
                                  ),
                                  foregroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () {
                                  ref
                                      .read(attendanceControllerProvider.notifier)
                                      .memberCheckOut(currentRecord: record);
                                },
                                icon: const Icon(Icons.exit_to_app_rounded, size: 18),
                                label: const Text('Check Out'),
                              )
                            : FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () => _openScannerSheet(context),
                                icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                                label: Text(isCheckedOut ? 'Scan Again' : 'Scan Gym QR'),
                              ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _openScannerSheet(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GymQRScannerSheet(),
      ),
    );
  }

  void _openHistorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MemberAttendanceHistorySheet(),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
