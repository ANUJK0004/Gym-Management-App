import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/activity_provider.dart';
import 'activity_tile.dart';

class RecentActivityList
    extends ConsumerWidget {
  const RecentActivityList({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final activities =
    ref.watch(recentActivityProvider);

    return activities.when(
      loading: () =>
      const Center(
        child:
        CircularProgressIndicator(),
      ),

      error: (_, _) =>
      const Center(
        child: Text(
          'Unable to load activities',
        ),
      ),

      data: (logs) {
        if (logs.isEmpty) {
          return const Center(
            child: Text(
              'No recent activity',
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          itemCount: logs.length,
          separatorBuilder: (_, _) =>
          const SizedBox(height: 8),
          itemBuilder: (_, index) {
            return ActivityTile(
              activity: logs[index],
            );
          },
        );
      },
    );
  }
}