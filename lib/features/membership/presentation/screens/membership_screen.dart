import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/membership_provider.dart';
import '../widgets/membership_details_card.dart';

class MembershipScreen
    extends ConsumerWidget {
  const MembershipScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final membershipsAsync =
    ref.watch(
      membershipProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Memberships',
        ),
      ),

      body: membershipsAsync.when(
        loading: () {
          return const Center(
            child:
            CircularProgressIndicator(),
          );
        },

        error: (
            error,
            stackTrace,
            ) {
          return Center(
            child: Text(
              'Something went wrong.\n$error',
              textAlign:
              TextAlign.center,
            ),
          );
        },

        data: (memberships) {
          if (memberships.isEmpty) {
            return const Center(
              child: Text(
                'No memberships found.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                membershipProvider,
              );

              await ref.read(
                membershipProvider.future,
              );
            },

            child: ListView.separated(
              padding:
              const EdgeInsets.all(24),

              itemCount:
              memberships.length,

              separatorBuilder:
                  (context, index) {
                return const SizedBox(
                  height: 16,
                );
              },

              itemBuilder:
                  (context, index) {
                return MembershipDetailsCard(
                  membership:
                  memberships[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}