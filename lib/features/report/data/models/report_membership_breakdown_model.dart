import '../../domain/entities/report_membership_breakdown.dart';

class ReportMembershipBreakdownModel
    extends ReportMembershipBreakdown {
  const ReportMembershipBreakdownModel({
    required super.planId,
    required super.planName,
    required super.memberCount,
    required super.percentage,
  });

  factory ReportMembershipBreakdownModel.fromMap(
      Map<String, dynamic> data) {
    return ReportMembershipBreakdownModel(
      planId: data['planId'] as String? ?? '',
      planName: data['planName'] as String? ?? 'Other',
      memberCount:
          (data['memberCount'] as num?)?.toInt() ?? 0,
      percentage:
          (data['percentage'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'planId': planId,
      'planName': planName,
      'memberCount': memberCount,
      'percentage': percentage,
    };
  }
}
