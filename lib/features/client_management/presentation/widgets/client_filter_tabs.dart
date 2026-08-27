import 'package:flutter/material.dart';

import '../providers/client_management_provider.dart';

class ClientFilterTabs extends StatelessWidget {
  const ClientFilterTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final ClientFilterTab selectedTab;
  final ValueChanged<ClientFilterTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          title: 'All',
          isSelected: selectedTab == ClientFilterTab.all,
          onTap: () => onTabSelected(ClientFilterTab.all),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          title: 'Active',
          isSelected: selectedTab == ClientFilterTab.active,
          onTap: () => onTabSelected(ClientFilterTab.active),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          title: 'Inactive',
          isSelected: selectedTab == ClientFilterTab.inactive,
          onTap: () => onTabSelected(ClientFilterTab.inactive),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF38BDF8)
                : const Color(0xFF1E222D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF38BDF8)
                  : const Color(0xFF262C3A),
              width: 0.8,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF0B132B)
                  : const Color(0xFF8E9DAE),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ),
      ),
    );
  }
}
