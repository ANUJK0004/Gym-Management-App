import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/trainer_dashboard_provider.dart';
import '../widgets/trainer_client_card.dart';

class TrainerClientsScreen extends ConsumerStatefulWidget {
  const TrainerClientsScreen({super.key});

  @override
  ConsumerState<TrainerClientsScreen> createState() =>
      _TrainerClientsScreenState();
}

class _TrainerClientsScreenState extends ConsumerState<TrainerClientsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(trainerDashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F14),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Clients',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: dashboardAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
          ),
        ),
        error: (e, s) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        data: (dashboard) {
          final filteredClients = dashboard.clients.where((client) {
            return client.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                client.goal
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              // Search input
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search client by name or goal...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF64748B),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF161922),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF262C3A),
                        width: 0.8,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF262C3A),
                        width: 0.8,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF38BDF8),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),

              // Clients list
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredClients.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return TrainerClientCard(
                      client: filteredClients[index],
                      onTap: () {
                        // Display client details sheet or snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF161922),
                            content: Text(
                              'Viewing details for ${filteredClients[index].name}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
