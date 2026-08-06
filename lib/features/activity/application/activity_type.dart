enum ActivityType {
  // Member
  memberJoined,
  memberAssigned,
  memberRemoved,

  // Trainer
  trainerAdded,
  trainerRemoved,
  trainerAssigned,

  // Membership (Purchased by member)
  membershipPurchased,
  membershipRenewed,

  // Membership Plan (Owner CRUD)
  membershipPlanCreated,
  membershipPlanUpdated,
  membershipPlanDeleted,
  membershipPlanActivated,
  membershipPlanDeactivated,

  // Finance
  paymentReceived,
  paymentRefunded,

  // Workout
  workoutCreated,
  workoutAssigned,

  // Attendance
  attendanceChecked,

  // General
  profileUpdated,
  gymUpdated,
}