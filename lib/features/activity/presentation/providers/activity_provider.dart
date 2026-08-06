import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../gym/presentation/providers/gym_provider.dart';

import '../../application/activity_service.dart';
import '../../data/datasources/activity_remote_datasource.dart';
import '../../data/repositories/activity_repository_impl.dart';

import '../../domain/entities/activity_log.dart';
import '../../domain/repositories/activity_repository.dart';

final activityRemoteDatasourceProvider =
Provider(
      (ref) => ActivityRemoteDataSource(
    FirebaseFirestore.instance,
  ),
);

final activityRepositoryProvider =
Provider<ActivityRepository>(
      (ref) {
    return ActivityRepositoryImpl(
      ref.watch(
        activityRemoteDatasourceProvider,
      ),
    );
  },
);

final recentActivityProvider =
FutureProvider<List<ActivityLog>>(
      (ref) async {
    final gym =
    await ref.watch(ownerGymProvider.future);

    if (gym == null) {
      return [];
    }

    return ref
        .watch(activityRepositoryProvider)
        .getRecentActivities(
      gymId: gym.id,
      limit: 20,
    );
  },
);


final activityServiceProvider =
Provider<ActivityService>(
      (ref) {
    return ActivityService(
      ref.watch(
        activityRepositoryProvider,
      ),
    );
  },
);