class ReportMembershipBreakdown {
  const ReportMembershipBreakdown({
    required this.planId,
    required this.planName,
    required this.memberCount,
    required this.percentage,
  });

  final String planId;
  final String planName;
  final int memberCount;
  final double percentage;
}
