import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sweatsync/app/routes/app_routes.dart';
import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';
import 'package:sweatsync/app/theme/app_text_styles.dart';

import '../providers/member_management_provider.dart';
import '../widgets/member_card.dart';
import '../widgets/member_search_bar.dart';
import '../widgets/member_status_chip.dart';

class MemberManagementScreen extends ConsumerStatefulWidget {
  const MemberManagementScreen({
    super.key,
  });

  @override
  ConsumerState<MemberManagementScreen> createState() =>
      _MemberManagementScreenState();
}

class _MemberManagementScreenState
    extends ConsumerState<MemberManagementScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';

  String _selectedStatus = 'All';

  final List<String> _statuses = const [
    'All',
    'Active',
    'Expired',
    'Inactive',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(
      gymMembersProvider,
    );

    final searchAsync = _searchQuery.trim().isEmpty
        ? null
        : ref.watch(
      memberSearchProvider(
        _searchQuery.trim(),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(
              gymMembersProvider,
            );

            await ref.read(
              gymMembersProvider.future,
            );
          },

          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  10,
                  18,
                  10,
                  100,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _buildHeader(
                        context,
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      MemberSearchBar(
                        controller:
                        _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      _buildStatusFilters(),

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
                        _buildGymMembers(
                          membersAsync,
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

  // ----------------------------------------------------------
  // HEADER
  // ----------------------------------------------------------

  Widget _buildHeader(
      BuildContext context,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder:
            const CircleBorder(),
            onTap: () {
              context.pop();
            },
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

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Members',
                style: AppTextStyles
                    .headlineMedium
                    .copyWith(
                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              Text(
                'Manage your gym members',
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
            onTap: _openMemberSearch,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_rounded,
                    size: 17,
                    color: Colors.black,
                  ),

                  const SizedBox(
                    width: 3,
                  ),

                  Text(
                    'Add',
                    style: AppTextStyles
                        .labelMedium
                        .copyWith(
                      color: Colors.black,
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

  // ----------------------------------------------------------
  // STATUS FILTERS
  // ----------------------------------------------------------

  Widget _buildStatusFilters() {
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

          return MemberStatusChip(
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

  // ----------------------------------------------------------
  // MEMBERS
  // ----------------------------------------------------------

  Widget _buildGymMembers(
      AsyncValue membersAsync,
      ) {
    return membersAsync.when(
      loading: () {
        return const Padding(
          padding:
          EdgeInsets.only(
            top: 60,
          ),
          child: Center(
            child:
            CircularProgressIndicator(),
          ),
        );
      },

      error: (
          error,
          stackTrace,
          ) {
        return Padding(
          padding:
          const EdgeInsets.all(24),
          child: Text(
            'Unable to load members.\n$error',
            textAlign:
            TextAlign.center,
          ),
        );
      },

      data: (members) {
        final filteredMembers =
        _filterMembers(
          members,
        );

        if (filteredMembers.isEmpty) {
          return _EmptyMembersView(
            status:
            _selectedStatus,
          );
        }

        return Column(
          children:
          filteredMembers.map(
                (member) {
              return Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 10,
                ),
                child: MemberCard(
                  member: member,
                  onTap: () {
                    context.push(
                      AppRoutes.memberDetails,
                      extra: member.uid,
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

  // ----------------------------------------------------------
  // SEARCH RESULTS
  // ----------------------------------------------------------

  Widget _buildSearchResults(
      AsyncValue? searchAsync,
      ) {
    if (searchAsync == null) {
      return const SizedBox();
    }

    return searchAsync.when(
      loading: () {
        return const Padding(
          padding:
          EdgeInsets.only(
            top: 40,
          ),
          child: Center(
            child:
            CircularProgressIndicator(),
          ),
        );
      },

      error: (
          error,
          stackTrace,
          ) {
        return Text(
          'Search failed: $error',
        );
      },

      data: (members) {
        final filteredMembers =
        _filterMembers(
          members,
        );

        if (filteredMembers.isEmpty) {
          return const Padding(
            padding:
            EdgeInsets.all(40),
            child: Center(
              child: Text(
                'No matching members found.',
              ),
            ),
          );
        }

        return Column(
          children:
          filteredMembers.map(
                (member) {
              return Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 10,
                ),
                child: MemberCard(
                  member: member,
                  onTap: () {
                    context.push(
                      AppRoutes.memberDetails,
                      extra: member.uid,
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

  // ----------------------------------------------------------
  // FILTER
  // ----------------------------------------------------------

  List<dynamic> _filterMembers(
      List<dynamic> members,
      ) {
    if (_selectedStatus == 'All') {
      return members;
    }

    return members.where(
          (member) {
        final status =
        member.status
            .toString()
            .toLowerCase();

        return status ==
            _selectedStatus
                .toLowerCase();
      },
    ).toList();
  }

  // ----------------------------------------------------------
  // ADD MEMBER
  // ----------------------------------------------------------

  void _openMemberSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });

    FocusScope.of(context)
        .requestFocus(
      FocusNode(),
    );
  }
}

// ------------------------------------------------------------
// EMPTY STATE
// ------------------------------------------------------------

class _EmptyMembersView
    extends StatelessWidget {
  const _EmptyMembersView({
    required this.status,
  });

  final String status;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        AppRadius.radiusLG,
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.groups_outlined,
            size: 42,
            color:
            AppColors.textSecondary,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            status == 'All'
                ? 'No members yet'
                : 'No $status members',
            style: AppTextStyles
                .titleMedium
                .copyWith(
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            'Members assigned to your gym will appear here.',
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