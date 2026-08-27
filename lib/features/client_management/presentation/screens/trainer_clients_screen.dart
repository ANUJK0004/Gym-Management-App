import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sweatsync/features/dashboard/trainer/presentation/providers/trainer_shell_provider.dart';
import '../providers/client_management_provider.dart';
import '../widgets/add_client_sheet.dart';
import '../widgets/client_card.dart';
import '../widgets/client_filter_tabs.dart';
import '../widgets/client_metrics_row.dart';
import '../widgets/client_search_bar.dart';
import 'client_details_screen.dart';

class TrainerClientsScreen extends ConsumerWidget {
  const TrainerClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientManagementProvider);
    final notifier = ref.read(clientManagementProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ------------------------------------------------
              // 1. BACK BUTTON (<)
              // ------------------------------------------------
              GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    ref.read(trainerNavIndexProvider.notifier).setIndex(0);
                  }
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E222D),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2A3040),
                      width: 0.8,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------
              // 2. HEADER ROW (TITLE + SUBTITLE & "+ Add Client")
              // ------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Subtitle (e.g. 5 total · 4 active)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Clients',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${state.totalCount} total · ${state.activeCount} active',
                          style: const TextStyle(
                            color: Color(0xFF8E9DAE),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // "+ Add Client" Pill Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => AddClientSheet.show(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C2438),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF1D4A6E),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: Color(0xFF38BDF8),
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Add Client',
                              style: TextStyle(
                                color: Color(0xFF38BDF8),
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ------------------------------------------------
              // 3. SUMMARY METRICS ROW (Clients, Sessions/wk, Avg Progress)
              // ------------------------------------------------
              ClientMetricsRow(
                totalClients: state.totalCount,
                sessionsPerWeek: state.sessionsPerWeek,
                avgProgress: state.avgProgressPercentage,
              ),

              const SizedBox(height: 14),

              // ------------------------------------------------
              // 4. SEARCH BAR
              // ------------------------------------------------
              ClientSearchBar(
                initialValue: state.searchQuery,
                onChanged: notifier.setSearchQuery,
              ),

              const SizedBox(height: 14),

              // ------------------------------------------------
              // 5. FILTER TABS (All, Active, Inactive)
              // ------------------------------------------------
              ClientFilterTabs(
                selectedTab: state.selectedFilter,
                onTabSelected: notifier.setFilter,
              ),

              const SizedBox(height: 14),

              // ------------------------------------------------
              // 6. CLIENTS LIST VIEW
              // ------------------------------------------------
              Expanded(
                child: state.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                        ),
                      )
                    : state.filteredClients.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF161922),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.person_search_rounded,
                                    color: Color(0xFF64748B),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No clients found',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  state.searchQuery.isNotEmpty
                                      ? 'No matching results for "${state.searchQuery}"'
                                      : 'No clients in this category.',
                                  style: const TextStyle(
                                    color: Color(0xFF8E9DAE),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(top: 2, bottom: 20),
                            itemCount: state.filteredClients.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final client = state.filteredClients[index];
                              return ClientCard(
                                client: client,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ClientDetailsScreen(
                                        client: client,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
