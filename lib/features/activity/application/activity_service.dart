import '../domain/repositories/activity_repository.dart';

import 'activity_actor.dart';
import 'activity_formatter.dart';
import 'activity_target.dart';
import 'activity_type.dart';

class ActivityService {
  ActivityService(
      this._repository,
      );

  final ActivityRepository _repository;

  Future<void> log({
    required String gymId,
    required ActivityType type,
    required ActivityActor actor,
    ActivityTarget? target,
    Map<String, dynamic>? metadata,
  }) async {
    final activity = ActivityFormatter.build(
      gymId: gymId,
      type: type,
      actor: actor,
      target: target,
      metadata: metadata,
    );

    await _repository.createActivity(
      activity,
    );
  }
}