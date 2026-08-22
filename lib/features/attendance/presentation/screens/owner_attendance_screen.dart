import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../gym/presentation/providers/gym_provider.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/daily_qr_payload.dart';
import '../providers/attendance_provider.dart';
import '../widgets/attendance_card.dart';
import '../widgets/daily_gym_qr_sheet.dart';
import '../widgets/manual_checkin_sheet.dart';

class OwnerAttendanceScreen extends ConsumerStatefulWidget {
  const OwnerAttendanceScreen({super.key});

  @override
  ConsumerState<OwnerAttendanceScreen> createState() => _OwnerAttendanceScreenState();
}

class _OwnerAttendanceScreenState extends ConsumerState<OwnerAttendanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'all'; // 'all' | 'member' | 'trainer'
  String _selectedStatus = 'All'; // 'All' | 'In Gym' | 'Checked Out'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gymAsync = ref.watch(ownerGymProvider);
    final selectedDate = ref.watch(selectedAttendanceDateProvider);
    final attendanceAsync = ref.watch(gymDailyAttendanceProvider(selectedDate));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(gymDailyAttendanceProvider(selectedDate));
            await ref.read(gymDailyAttendanceProvider(selectedDate).future);
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _buildHeader(context, gymAsync.value),

                      const SizedBox(height: 18),

                      _buildDateSelector(context, selectedDate),

                      const SizedBox(height: 16),

                      _buildStatsSummary(attendanceAsync),

                      const SizedBox(height: 16),

                      _buildSearchBar(),

                      const SizedBox(height: 14),

                      _buildRoleAndStatusFilters(attendanceAsync),

                      const SizedBox(height: 14),

                      _buildAttendanceList(attendanceAsync, gymAsync.value?.id ?? ''),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: gymAsync.value != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'manual_checkin',
                  onPressed: () {
                    final todayRecords = attendanceAsync.value ?? [];
                    _openManualCheckIn(context, todayRecords);
                  },
                  backgroundColor: AppColors.surface,
                  icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
                  label: const Text('Check In', style: TextStyle(color: AppColors.textPrimary)),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  heroTag: 'daily_qr',
                  onPressed: () => _openDailyQR(context, gymAsync.value!),
                  backgroundColor: AppColors.primary,
                  icon: const Icon(Icons.qr_code_rounded, color: Colors.black),
                  label: const Text('Daily QR Pass', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                ),
              ],
            )
          : null,
    );
  }

  // ----------------------------------------------------------
  // HEADER
  // ----------------------------------------------------------

  Widget _buildHeader(BuildContext context, dynamic gym) {
    return Row(
      children: [
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => context.pop(),
            child: const SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                Icons.chevron_left_rounded,
                size: 22,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attendance Console',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                gym?.name ?? 'Manage Gym Check-ins',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (gym != null)
          IconButton.filledTonal(
            onPressed: () => _openDailyQR(context, gym),
            icon: const Icon(Icons.qr_code_2_rounded),
            tooltip: 'View Daily QR',
          ),
      ],
    );
  }

  // ----------------------------------------------------------
  // DATE SELECTOR
  // ----------------------------------------------------------

  Widget _buildDateSelector(BuildContext context, String selectedDate) {
    final today = DailyQRPayload.getTodayKey();
    final isToday = selectedDate == today;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month_rounded, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'Today\'s Roster' : 'Historical Date',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  selectedDate,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (!isToday)
            TextButton(
              onPressed: () {
                ref.read(selectedAttendanceDateProvider.notifier).resetToToday();
              },
              child: const Text('Reset Today'),
            ),
          IconButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(selectedDate) ?? DateTime.now(),
                firstDate: DateTime(2025, 1, 1),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                final dateStr = DailyQRPayload.getTodayKey(picked);
                ref.read(selectedAttendanceDateProvider.notifier).setDate(dateStr);
              }
            },
            icon: const Icon(Icons.edit_calendar_rounded, size: 20),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // STATS SUMMARY
  // ----------------------------------------------------------

  Widget _buildStatsSummary(AsyncValue<List<AttendanceRecord>> attendanceAsync) {
    final records = attendanceAsync.value ?? [];
    final membersPresent = records.where((r) => r.isMember).length;
    final trainersPresent = records.where((r) => r.isTrainer).length;
    final currentlyInGym = records.where((r) => r.isCurrentlyInGym).length;

    return Row(
      children: [
        Expanded(
          child: _StatBox(
            title: 'Members',
            value: '$membersPresent',
            accent: AppColors.primary,
            icon: Icons.groups_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatBox(
            title: 'Trainers',
            value: '$trainersPresent',
            accent: Colors.lightBlue,
            icon: Icons.sports_gymnastics_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatBox(
            title: 'In Gym Now',
            value: '$currentlyInGym',
            accent: Colors.greenAccent,
            icon: Icons.meeting_room_rounded,
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // SEARCH BAR
  // ----------------------------------------------------------

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (v) {
        setState(() {
          _searchQuery = v.trim().toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search by attendee name...',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // FILTERS
  // ----------------------------------------------------------

  Widget _buildRoleAndStatusFilters(AsyncValue<List<AttendanceRecord>> attendanceAsync) {
    final records = attendanceAsync.value ?? [];
    final membersCount = records.where((r) => r.isMember).length;
    final trainersCount = records.where((r) => r.isTrainer).length;

    return Column(
      children: [
        // Role Segmented Tabs
        Row(
          children: [
            _buildRoleTab('all', 'All (${records.length})'),
            const SizedBox(width: 8),
            _buildRoleTab('member', 'Members ($membersCount)'),
            const SizedBox(width: 8),
            _buildRoleTab('trainer', 'Trainers ($trainersCount)'),
          ],
        ),

        const SizedBox(height: 10),

        // Status Filter Chips
        Row(
          children: [
            _buildStatusChip('All'),
            const SizedBox(width: 8),
            _buildStatusChip('In Gym'),
            const SizedBox(width: 8),
            _buildStatusChip('Checked Out'),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleTab(String role, String label) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        borderRadius: AppRadius.radiusMD,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: AppRadius.radiusMD,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final isSelected = _selectedStatus == status;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // ATTENDANCE LIST
  // ----------------------------------------------------------

  Widget _buildAttendanceList(
    AsyncValue<List<AttendanceRecord>> attendanceAsync,
    String gymId,
  ) {
    return attendanceAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text('Unable to load attendance: $err'),
      ),
      data: (records) {
        var filtered = records;

        // Role filter
        if (_selectedRole != 'all') {
          filtered = filtered.where((r) => r.userRole.toLowerCase() == _selectedRole).toList();
        }

        // Status filter
        if (_selectedStatus == 'In Gym') {
          filtered = filtered.where((r) => r.isCurrentlyInGym).toList();
        } else if (_selectedStatus == 'Checked Out') {
          filtered = filtered.where((r) => r.isCheckedOut).toList();
        }

        // Search filter
        if (_searchQuery.isNotEmpty) {
          filtered = filtered.where((r) => r.userName.toLowerCase().contains(_searchQuery)).toList();
        }

        if (filtered.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.radiusLG,
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.person_off_outlined,
                  size: 40,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  'No attendance records found',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Members and trainers will appear here when they scan the Daily QR code.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: filtered.map((record) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AttendanceCard(
                record: record,
                onCheckOut: record.isCurrentlyInGym
                    ? () {
                        ref.read(attendanceControllerProvider.notifier).ownerManualCheckOut(
                              gymId: gymId,
                              recordId: record.id,
                            );
                      }
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _openDailyQR(BuildContext context, dynamic gym) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DailyGymQRSheet(gym: gym),
    );
  }

  void _openManualCheckIn(BuildContext context, List<AttendanceRecord> todayRecords) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManualCheckInSheet(todayRecords: todayRecords),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.title,
    required this.value,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String value;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accent),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
