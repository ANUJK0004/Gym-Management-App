import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../gym/presentation/providers/gym_provider.dart';
import '../../../member_management/presentation/providers/member_management_provider.dart';
import '../../../trainer_management/presentation/providers/trainer_management_provider.dart';
import '../../domain/entities/attendance_record.dart';
import '../providers/attendance_provider.dart';

class ManualCheckInSheet extends ConsumerStatefulWidget {
  const ManualCheckInSheet({
    super.key,
    required this.todayRecords,
  });

  final List<AttendanceRecord> todayRecords;

  @override
  ConsumerState<ManualCheckInSheet> createState() => _ManualCheckInSheetState();
}

class _ManualCheckInSheetState extends ConsumerState<ManualCheckInSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'member'; // 'member' | 'trainer'
  String? _selectedUserId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gym = ref.watch(ownerGymProvider).value;
    final membersAsync = ref.watch(gymMembersProvider);
    final trainersAsync = ref.watch(gymTrainersProvider);

    final alreadyPresentIds = widget.todayRecords
        .where((r) => r.isCurrentlyInGym)
        .map((r) => r.userId)
        .toSet();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Manual Attendance Check-In',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mark attendance for members or trainers manually',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          // Role Switcher
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.radiusMD,
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedRole = 'member';
                        _selectedUserId = null;
                      });
                    },
                    borderRadius: AppRadius.radiusMD,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedRole == 'member' ? AppColors.primary : Colors.transparent,
                        borderRadius: AppRadius.radiusMD,
                      ),
                      child: Text(
                        'Gym Members',
                        style: TextStyle(
                          color: _selectedRole == 'member' ? Colors.black : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedRole = 'trainer';
                        _selectedUserId = null;
                      });
                    },
                    borderRadius: AppRadius.radiusMD,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _selectedRole == 'trainer' ? AppColors.primary : Colors.transparent,
                        borderRadius: AppRadius.radiusMD,
                      ),
                      child: Text(
                        'Trainers',
                        style: TextStyle(
                          color: _selectedRole == 'trainer' ? Colors.black : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim().toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: _selectedRole == 'member' ? 'Search member name...' : 'Search trainer name...',
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
          ),

          const SizedBox(height: 14),

          // Candidate List
          Expanded(
            child: _selectedRole == 'member'
                ? _buildMemberList(membersAsync, alreadyPresentIds, gym?.id ?? '')
                : _buildTrainerList(trainersAsync, alreadyPresentIds, gym?.id ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberList(
    AsyncValue membersAsync,
    Set<String> alreadyPresentIds,
    String gymId,
  ) {
    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading members: $e')),
      data: (members) {
        final filtered = members.where((m) {
          final name = (m.displayName ?? '').toLowerCase();
          final email = m.email.toLowerCase();
          return name.contains(_searchQuery) || email.contains(_searchQuery);
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No members found'));
        }

        return ListView.separated(
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final member = filtered[index];
            final isPresent = alreadyPresentIds.contains(member.uid);

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.radiusMD,
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      member.displayName != null && member.displayName!.isNotEmpty
                          ? member.displayName![0].toUpperCase()
                          : 'M',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.displayName ?? 'Unnamed Member',
                          style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
                        ),
                        Text(
                          member.email,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isPresent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'In Gym',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () => _performManualCheckIn(
                                gymId: gymId,
                                userId: member.uid,
                                userName: member.displayName ?? 'Member',
                                userRole: 'member',
                                userPhotoUrl: member.photoUrl,
                                planOrSpecialization: member.membershipPlanName,
                              ),
                      child: const Text('Check In', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTrainerList(
    AsyncValue trainersAsync,
    Set<String> alreadyPresentIds,
    String gymId,
  ) {
    return trainersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading trainers: $e')),
      data: (trainers) {
        final filtered = trainers.where((t) {
          final name = t.name.toLowerCase();
          final email = t.email.toLowerCase();
          return name.contains(_searchQuery) || email.contains(_searchQuery);
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text('No trainers found'));
        }

        return ListView.separated(
          itemCount: filtered.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final trainer = filtered[index];
            final isPresent = alreadyPresentIds.contains(trainer.uid);

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.radiusMD,
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.lightBlue.withValues(alpha: 0.15),
                    child: Text(
                      trainer.name.isNotEmpty ? trainer.name[0].toUpperCase() : 'T',
                      style: const TextStyle(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trainer.name,
                          style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
                        ),
                        Text(
                          trainer.specializations.isNotEmpty
                              ? trainer.specializations.join(', ')
                              : 'Fitness Trainer',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isPresent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'On Shift',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Colors.lightBlue,
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () => _performManualCheckIn(
                                gymId: gymId,
                                userId: trainer.uid,
                                userName: trainer.name,
                                userRole: 'trainer',
                                userPhotoUrl: trainer.photoUrl,
                                planOrSpecialization: trainer.specializations.join(', '),
                              ),
                      child: const Text('Check In', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _performManualCheckIn({
    required String gymId,
    required String userId,
    required String userName,
    required String userRole,
    String? userPhotoUrl,
    String? planOrSpecialization,
  }) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(attendanceControllerProvider.notifier).ownerManualCheckIn(
            gymId: gymId,
            userId: userId,
            userName: userName,
            userRole: userRole,
            userPhotoUrl: userPhotoUrl,
            planOrSpecialization: planOrSpecialization,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$userName marked present successfully.'),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark check-in: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
