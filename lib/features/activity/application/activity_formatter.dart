import '../domain/entities/activity_log.dart';

import 'activity_actor.dart';
import 'activity_target.dart';
import 'activity_type.dart';

class ActivityFormatter {
  const ActivityFormatter._();

  static ActivityLog build({
    required String gymId,
    required ActivityType type,
    required ActivityActor actor,
    ActivityTarget? target,
    Map<String, dynamic>? metadata,
  }) {
    return ActivityLog(
      id: '',

      gymId: gymId,

      title: _title(type),

      description: _description(
        type,
        actor,
        target,
      ),

      type: type.name,

      actorId: actor.id,

      actorName: actor.name,

      actorRole: actor.role,

      targetId: target?.id,

      targetName: target?.name,

      targetType: target?.type,

      createdAt: DateTime.now(),

      metadata: metadata ?? {},
    );
  }

  //--------------------------------------------------
  // TITLE
  //--------------------------------------------------

  static String _title(
      ActivityType type,
      ) {
    switch (type) {
      case ActivityType.memberJoined:
        return 'New Member Joined';

      case ActivityType.memberAssigned:
        return 'Member Assigned';

      case ActivityType.memberRemoved:
        return 'Member Removed';

      case ActivityType.memberEnrollmentCreated:
        return 'Member Enrollment Created';

      case ActivityType.memberInvitationSent:
        return 'Member Invitation Sent';

      case ActivityType.trainerAdded:
        return 'Trainer Added';

      case ActivityType.trainerRemoved:
        return 'Trainer Removed';

      case ActivityType.trainerAssigned:
        return 'Trainer Assigned';

      case ActivityType.membershipPurchased:
        return 'Membership Purchased';

      case ActivityType.membershipRenewed:
        return 'Membership Renewed';

      case ActivityType.paymentReceived:
        return 'Payment Received';

      case ActivityType.paymentRefunded:
        return 'Payment Refunded';

      case ActivityType.workoutCreated:
        return 'Workout Created';

      case ActivityType.workoutAssigned:
        return 'Workout Assigned';

      case ActivityType.attendanceChecked:
        return 'Attendance Recorded';

      case ActivityType.profileUpdated:
        return 'Profile Updated';

      case ActivityType.gymUpdated:
        return 'Gym Updated';

      case ActivityType.membershipPlanCreated:
        return 'Membership Plan Created';

      case ActivityType.membershipPlanUpdated:
        return 'Membership Plan Updated';

      case ActivityType.membershipPlanDeleted:
        return 'Membership Plan Deleted';

      case ActivityType.membershipPlanActivated:
        return 'Membership Plan Activated';

      case ActivityType.membershipPlanDeactivated:
        return 'Membership Plan Deactivated';
    }
  }

  //--------------------------------------------------
  // DESCRIPTION
  //--------------------------------------------------

  static String _description(
      ActivityType type,
      ActivityActor actor,
      ActivityTarget? target,
      ) {
    switch (type) {
      case ActivityType.memberJoined:
        return '${target?.name} joined the gym';

      case ActivityType.memberAssigned:
        return '${actor.name} assigned ${target?.name}';

      case ActivityType.memberRemoved:
        return '${actor.name} removed ${target?.name}';

      case ActivityType.memberEnrollmentCreated:
        return '${actor.name} enrolled ${target?.name}';

      case ActivityType.memberInvitationSent:
        return '${actor.name} invited ${target?.name} to join the gym';

      case ActivityType.trainerAdded:
        return '${actor.name} added trainer ${target?.name}';

      case ActivityType.trainerRemoved:
        return '${actor.name} removed trainer ${target?.name}';

      case ActivityType.trainerAssigned:
        return '${actor.name} assigned trainer ${target?.name}';

      case ActivityType.membershipPurchased:
        return '${target?.name} purchased a membership';

      case ActivityType.membershipRenewed:
        return '${target?.name} renewed membership';

      case ActivityType.paymentReceived:
        return 'Payment received from ${target?.name}';

      case ActivityType.paymentRefunded:
        return 'Refund issued to ${target?.name}';

      case ActivityType.workoutCreated:
        return '${actor.name} created a workout';

      case ActivityType.workoutAssigned:
        return '${actor.name} assigned a workout';

      case ActivityType.attendanceChecked:
        return '${target?.name} checked in';

      case ActivityType.profileUpdated:
        return '${actor.name} updated profile';

      case ActivityType.gymUpdated:
        return '${actor.name} updated gym information';

      case ActivityType.membershipPlanCreated:
        return '${actor.name} created "${target?.name}" plan';

      case ActivityType.membershipPlanUpdated:
        return '${actor.name} updated "${target?.name}" plan';

      case ActivityType.membershipPlanDeleted:
        return '${actor.name} deleted "${target?.name}" plan';

      case ActivityType.membershipPlanActivated:
        return '${actor.name} activated "${target?.name}" plan';

      case ActivityType.membershipPlanDeactivated:
        return '${actor.name} deactivated "${target?.name}" plan';
    }
  }
}