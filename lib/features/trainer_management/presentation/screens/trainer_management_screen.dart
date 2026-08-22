import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sweatsync/app/routes/app_routes.dart';
import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

import '../../domain/entities/managed_trainer.dart';
import '../../domain/entities/trainer_enrollment.dart';

import '../providers/trainer_management_provider.dart';

import '../widgets/add_trainer/add_trainer_sheet.dart';
import '../widgets/add_trainer/trainer_enrollment_success_sheet.dart';

import '../widgets/trainer_card.dart';
import '../widgets/trainer_search_bar.dart';
import '../widgets/trainer_status_chip.dart';

class TrainerManagementScreen
    extends ConsumerStatefulWidget {
  const TrainerManagementScreen({
    super.key,
  });

  @override
  ConsumerState<
      TrainerManagementScreen> createState() =>
      _TrainerManagementScreenState();
}

class _TrainerManagementScreenState
    extends ConsumerState<
        TrainerManagementScreen> {
  final _searchController =
  TextEditingController();

  String _searchQuery = '';
  String _selectedStatus = 'All';

  final _statuses = const [
    'All',
    'Active',
    'Inactive',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final trainersAsync =
    ref.watch(
      gymTrainersProvider,
    );

    final searchAsync =
    _searchQuery.trim().isEmpty
        ? null
        : ref.watch(
      trainerSearchProvider(
        _searchQuery.trim(),
      ),
    );

    return Scaffold(
      backgroundColor:
      AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(
              gymTrainersProvider,
            );

            await ref.read(
              gymTrainersProvider.future,
            );
          },
          child:
          CustomScrollView(
            slivers: [
              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  10,
                  18,
                  10,
                  100,
                ),
                sliver: SliverList(
                  delegate:
                  SliverChildListDelegate(
                    [
                      _buildHeader(
                        context,
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      _buildStats(
                        trainersAsync,
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      TrainerSearchBar(
                        controller:
                        _searchController,
                        onChanged:
                            (value) {
                          setState(() {
                            _searchQuery =
                                value;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      _buildFilters(),

                      const SizedBox(
                        height: 14,
                      ),

                      if (_searchQuery
                          .trim()
                          .isNotEmpty)
                        _buildSearchResults(
                          searchAsync,
                        )
                      else
                        _buildTrainers(
                          trainersAsync,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context,
      ) {
    return Row(
      children: [
        Material(
          color: AppColors.surface,
          shape:
          const CircleBorder(),
          child: InkWell(
            customBorder:
            const CircleBorder(),
            onTap: () =>
                context.pop(),
            child:
            const SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                Icons.chevron_left_rounded,
                size: 22,
                color:
                AppColors.textPrimary,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Trainers',
                style: AppTextStyles
                    .headlineMedium
                    .copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
              Text(
                'Manage your gym trainers',
                style: AppTextStyles
                    .labelMedium
                    .copyWith(
                  color:
                  AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        Material(
          color: AppColors.primary,
          borderRadius:
          BorderRadius.circular(10),
          child: InkWell(
            borderRadius:
            BorderRadius.circular(10),
            onTap:
            _openAddTrainerSheet,
            child:
            const Padding(
              padding:
              EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons
                        .person_add_rounded,
                    size: 16,
                    color: Colors.black,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(
      AsyncValue<List<ManagedTrainer>>
      trainersAsync,
      ) {
    final trainers =
        trainersAsync.value ?? [];

    final active =
        trainers
            .where(
              (trainer) =>
          trainer.isActive,
        )
            .length;

    final totalClients =
    trainers.fold<int>(
      0,
          (sum, trainer) =>
      sum + trainer.clientCount,
    );

    final rated =
    trainers
        .where(
          (trainer) =>
      trainer.rating > 0,
    )
        .toList();

    final averageRating =
    rated.isEmpty
        ? 0.0
        : rated.fold<double>(
      0,
          (sum, trainer) =>
      sum + trainer.rating,
    ) /
        rated.length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value:
            '${trainers.length}',
            label: '$active Active',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            value:
            '$totalClients',
            label: 'Clients',
            accent:
            const Color(0xFF2CC8FF),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            value:
            averageRating == 0
                ? '—'
                : '${averageRating.toStringAsFixed(1)}★',
            label: 'Avg Rating',
            accent:
            const Color(0xFFFFA23A),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection:
        Axis.horizontal,
        itemCount:
        _statuses.length,
        separatorBuilder:
            (_, _) =>
        const SizedBox(
          width: 8,
        ),
        itemBuilder:
            (context, index) {
          final status =
          _statuses[index];

          return TrainerStatusChip(
            label: status,
            selected:
            _selectedStatus ==
                status,
            onTap: () {
              setState(() {
                _selectedStatus =
                    status;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildTrainers(
      AsyncValue<List<ManagedTrainer>>
      trainersAsync,
      ) {
    return trainersAsync.when(
      loading: () =>
      const Padding(
        padding:
        EdgeInsets.only(
          top: 60,
        ),
        child: Center(
          child:
          CircularProgressIndicator(),
        ),
      ),

      error:
          (error, stackTrace) =>
          Padding(
            padding:
            const EdgeInsets.all(24),
            child: Text(
              'Unable to load trainers.\n$error',
              textAlign:
              TextAlign.center,
            ),
          ),

      data: (trainers) {
        final filtered =
        _applyStatusFilter(
          trainers,
        );

        if (filtered.isEmpty) {
          return _EmptyTrainerView(
            status:
            _selectedStatus,
          );
        }

        return Column(
          children:
          filtered.map(
                (trainer) {
              return Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 10,
                ),
                child: TrainerCard(
                  trainer: trainer,
                  onTap: () {
                    context.push(
                      AppRoutes
                          .trainerDetails,
                      extra:
                      trainer.uid,
                    );
                  },
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }

  Widget _buildSearchResults(
      AsyncValue<
          List<ManagedTrainer>>?
      searchAsync,
      ) {
    if (searchAsync == null) {
      return const SizedBox();
    }

    return searchAsync.when(
      loading: () =>
      const Padding(
        padding:
        EdgeInsets.only(top: 40),
        child: Center(
          child:
          CircularProgressIndicator(),
        ),
      ),

      error:
          (error, stackTrace) =>
          Padding(
            padding:
            const EdgeInsets.all(20),
            child: Text(
              'Search failed: $error',
            ),
          ),

      data: (trainers) {
        final filtered =
        _applyStatusFilter(
          trainers,
        );

        if (filtered.isEmpty) {
          return const Padding(
            padding:
            EdgeInsets.all(40),
            child: Center(
              child: Text(
                'No matching trainers found.',
              ),
            ),
          );
        }

        return Column(
          children:
          filtered.map(
                (trainer) {
              return Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 10,
                ),
                child: TrainerCard(
                  trainer: trainer,
                  onTap: () {
                    context.push(
                      AppRoutes
                          .trainerDetails,
                      extra:
                      trainer.uid,
                    );
                  },
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }

  List<ManagedTrainer>
  _applyStatusFilter(
      List<ManagedTrainer> trainers,
      ) {
    if (_selectedStatus ==
        'All') {
      return trainers;
    }

    return trainers
        .where(
          (trainer) =>
      trainer.status
          .toLowerCase() ==
          _selectedStatus
              .toLowerCase(),
    )
        .toList();
  }

  Future<void>
  _openAddTrainerSheet() async {
    final result =
    await showModalBottomSheet<
        TrainerEnrollment>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
      Colors.transparent,
      useSafeArea: true,
      builder: (_) {
        return const AddTrainerSheet();
      },
    );

    if (!mounted ||
        result == null) {
      return;
    }

    ref.invalidate(
      gymTrainersProvider,
    );

    // The management sheet has already closed.
    // Show a separate success sheet and allow it
    // to auto-close after 3 seconds.
    await showModalBottomSheet(
      context: context,
      backgroundColor:
      Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return TrainerEnrollmentSuccessSheet(
          enrollment: result,
        );
      },
    );
  }
}

class _StatCard
    extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    this.accent =
        AppColors.primary,
  });

  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      height: 52,
      decoration:
      BoxDecoration(
        color:
        AppColors.surface,
        borderRadius:
        BorderRadius.circular(
          10,
        ),
        border:
        Border.all(
          color:
          AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Text(
            value,
            style:
            TextStyle(
              color: accent,
              fontSize: 14,
              fontWeight:
              FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style:
            const TextStyle(
              color:
              AppColors.textSecondary,
              fontSize: 7,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTrainerView
    extends StatelessWidget {
  const _EmptyTrainerView({
    required this.status,
  });

  final String status;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(30),
      decoration:
      BoxDecoration(
        color:
        AppColors.surface,
        borderRadius:
        AppRadius.radiusLG,
        border:
        Border.all(
          color:
          AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons
                .sports_gymnastics_rounded,
            size: 42,
            color:
            AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            status == 'All'
                ? 'No trainers yet'
                : 'No $status trainers',
            style: AppTextStyles
                .titleMedium
                .copyWith(
              fontWeight:
              FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Trainers assigned to your gym will appear here.',
            textAlign:
            TextAlign.center,
            style: AppTextStyles
                .bodySmall
                .copyWith(
              color:
              AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}