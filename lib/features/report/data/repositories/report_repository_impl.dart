import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:math' as math;

import '../../domain/entities/downloadable_report.dart';
import '../../domain/entities/report_export_request.dart';
import '../../domain/entities/report_export_result.dart';
import '../../domain/entities/report_membership_breakdown.dart';
import '../../domain/entities/report_peak_hour.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/entities/report_trend.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';
import '../models/downloadable_report_model.dart';
import '../models/report_membership_breakdown_model.dart';
import '../models/report_peak_hour_model.dart';
import '../models/report_summary_model.dart';
import '../models/report_trend_model.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._dataSource);

  final ReportRemoteDataSource _dataSource;

  @override
  Future<ReportSummary> getSummary({
    required String gymId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final results = await Future.wait([
      _dataSource.getMembers(gymId),
      _dataSource.getFinanceTransactions(gymId),
      _dataSource.getAttendance(gymId),
      _dataSource.getNpsResponses(gymId),
    ]);

    final members = results[0];
    final transactions =
        results[1];
    final attendance =
        results[2];
    final npsResponses =
        results[3];

    final currentMembers = members
        .where((member) => _date(member['joinedAt']) != null)
        .where((member) {
      final joined = _date(member['joinedAt'])!;
      return joined.isBefore(endDate);
    }).toList();

    final churnRate = _calculateChurnRate(
      members,
      endDate.subtract(const Duration(seconds: 1)),
    );

    final previousPeriodStart =
        startDate.subtract(endDate.difference(startDate));
    final previousPeriodEnd = startDate;

    final previousChurnRate = _calculateChurnRate(
      members,
      previousPeriodEnd.subtract(const Duration(seconds: 1)),
    );

    final churnChange = churnRate - previousChurnRate;

    final lifetimeValue = _calculateLtv(
      transactions,
      currentMembers,
    );

    final previousLtv = _calculatePeriodLtv(
      transactions,
      currentMembers,
      previousPeriodStart,
      previousPeriodEnd,
    );

    final currentPeriodLtv = _calculatePeriodLtv(
      transactions,
      currentMembers,
      startDate,
      endDate,
    );

    final lifetimeValueChange =
        currentPeriodLtv - previousLtv;

    final activeMembers = currentMembers.where(_isActiveMember).length;

    final currentSessions = _countAttendance(
      attendance,
      startDate,
      endDate,
    );

    final previousSessions = _countAttendance(
      attendance,
      previousPeriodStart,
      previousPeriodEnd,
    );

    final averageSessions = activeMembers == 0
        ? 0
        : currentSessions / activeMembers;

    final previousAverageSessions = activeMembers == 0
        ? 0
        : previousSessions / activeMembers;

    final averageSessionsChange =
        averageSessions - previousAverageSessions;

    final npsScore = _calculateNps(
      npsResponses,
      startDate,
      endDate,
    );

    final previousNps = _calculateNps(
      npsResponses,
      previousPeriodStart,
      previousPeriodEnd,
    );

    return ReportSummaryModel(
      churnRate: churnRate,
      churnChange: churnChange,
      lifetimeValue: lifetimeValue,
      lifetimeValueChange: lifetimeValueChange,
      averageSessions: averageSessions,
      averageSessionsChange: averageSessionsChange,
      npsScore: npsScore,
      npsChange: npsScore - previousNps,
    );
  }

  @override
  Future<List<ReportTrend>> getTrends({
    required String gymId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final members = await _dataSource.getMembers(gymId);

    final firstMonth = DateTime(
      startDate.year,
      startDate.month,
      1,
    );

    final points = <ReportTrendPointModel>[];
    final retentionPoints = <ReportTrendPointModel>[];

    for (var index = 0; index < 12; index++) {
      final monthStart = DateTime(
        firstMonth.year,
        firstMonth.month + index,
        1,
      );

      final monthEnd = DateTime(
        monthStart.year,
        monthStart.month + 1,
        1,
      );

      final cumulativeMembers = members.where((member) {
        final joined = _date(member['joinedAt']);
        return joined != null && joined.isBefore(monthEnd);
      }).length;

      final retainedMembers = members.where((member) {
        final joined = _date(member['joinedAt']);
        if (joined == null || !joined.isBefore(monthEnd)) {
          return false;
        }

        final expires =
            _date(member['membershipExpiresAt']);

        return expires == null || !expires.isBefore(monthEnd);
      }).length;

      final retention = cumulativeMembers == 0
          ? 0
          : retainedMembers / cumulativeMembers * 100;

      final label = _monthLabel(monthStart);

      points.add(
        ReportTrendPointModel(
          month: label,
          value: cumulativeMembers.toDouble(),
        ),
      );

      retentionPoints.add(
        ReportTrendPointModel(
          month: label,
          value: retention,
        ),
      );
    }

    final currentMembers = points.isEmpty
        ? 0
        : points.last.value;
    final firstMembers = points.isEmpty
        ? 0
        : points.first.value;

    final currentRetention = retentionPoints.isEmpty
        ? 0
        : retentionPoints.last.value;
    final firstRetention = retentionPoints.isEmpty
        ? 0
        : retentionPoints.first.value;

    return [
      ReportTrendModel(
        type: ReportTrendType.members,
        points: points,
        currentValue: currentMembers,
        changeFromStart: currentMembers - firstMembers,
      ),
      ReportTrendModel(
        type: ReportTrendType.retention,
        points: retentionPoints,
        currentValue: currentRetention,
        changeFromStart:
            currentRetention - firstRetention,
      ),
    ];
  }

  @override
  Future<List<ReportPeakHour>> getPeakHours({
    required String gymId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final attendance = await _dataSource.getAttendance(gymId);
    final counts = <int, int>{};

    for (final record in attendance) {
      final date = _attendanceDate(record);
      if (date == null ||
          date.isBefore(startDate) ||
          !date.isBefore(endDate)) {
        continue;
      }

      counts[date.hour] = (counts[date.hour] ?? 0) + 1;
    }

    return counts.entries
        .map(
          (entry) => ReportPeakHourModel(
            hour: entry.key,
            sessions: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => a.hour.compareTo(b.hour));
  }

  @override
  Future<List<ReportMembershipBreakdown>>
      getMembershipBreakdown({
    required String gymId,
  }) async {
    final results = await Future.wait([
      _dataSource.getMembers(gymId),
      _dataSource.getMembershipPlans(gymId),
    ]);

    final members = results[0];
    final plans = results[1];

    final planNames = <String, String>{
      for (final plan in plans)
        plan['_id']?.toString() ?? '':
            plan['name']?.toString() ?? 'Other',
    };

    final counts = <String, int>{};

    for (final member in members) {
      if (!_isActiveMember(member)) {
        continue;
      }

      final planId =
          member['membershipPlanId']?.toString() ?? '';

      if (planId.isEmpty) {
        continue;
      }

      counts[planId] = (counts[planId] ?? 0) + 1;
    }

    final total = counts.values.fold<int>(0, (int sum, value) => sum + value);

    if (total == 0) {
      return [];
    }

    return counts.entries
        .map(
          (entry) => ReportMembershipBreakdownModel(
            planId: entry.key,
            planName: planNames[entry.key] ?? 'Other',
            memberCount: entry.value,
            percentage: entry.value / total * 100,
          ),
        )
        .toList()
      ..sort(
        (a, b) => b.memberCount.compareTo(a.memberCount),
      );
  }

  @override
  Future<List<DownloadableReport>> getDownloadableReports() async {
    return const [
      DownloadableReportModel(
        type: DownloadableReportType.monthlyRevenue,
        title: 'Monthly Revenue Report',
        subtitle: 'Current period · CSV',
        icon: '💰',
      ),
      DownloadableReportModel(
        type: DownloadableReportType.memberAcquisition,
        title: 'Member Acquisition Report',
        subtitle: 'Last 12 months · CSV',
        icon: '👥',
      ),
      DownloadableReportModel(
        type: DownloadableReportType.trainerPerformance,
        title: 'Trainer Performance Report',
        subtitle: 'Current team · CSV',
        icon: '🏆',
      ),
      DownloadableReportModel(
        type: DownloadableReportType.attendanceAnalytics,
        title: 'Attendance Analytics',
        subtitle: 'Current period · CSV',
        icon: '📅',
      ),
    ];
  }

  @override
  Future<String> exportReportCsv({
    required DownloadableReportType type,
    required String gymId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    switch (type) {
      case DownloadableReportType.monthlyRevenue:
        return _buildRevenueCsv(
          await _dataSource.getFinanceTransactions(gymId),
          startDate,
          endDate,
        );

      case DownloadableReportType.memberAcquisition:
        return _buildMemberAcquisitionCsv(
          await _dataSource.getMembers(gymId),
          startDate,
          endDate,
        );

      case DownloadableReportType.trainerPerformance:
        return _buildTrainerCsv(
          await _dataSource.getTrainers(gymId),
        );

      case DownloadableReportType.attendanceAnalytics:
        return _buildAttendanceCsv(
          await _dataSource.getAttendance(gymId),
          startDate,
          endDate,
        );
    }
  }

  @override
  Future<ReportExportResult> exportReport({
    required ReportExportRequest request,
  }) {
    return _dataSource.exportReport(
      request: request,
    );
  }

  double _calculateChurnRate(
    List<Map<String, dynamic>> members,
    DateTime asOf,
  ) {
    final eligible = members.where((member) {
      final joined = _date(member['joinedAt']);
      return joined == null || !joined.isAfter(asOf);
    }).toList();

    if (eligible.isEmpty) {
      return 0;
    }

    final churned = eligible.where((member) {
      final expires = _date(member['membershipExpiresAt']);
      final status =
          member['membershipStatus']?.toString().toLowerCase();

      if (expires != null && expires.isBefore(asOf)) {
        return true;
      }

      return status == 'inactive' || status == 'expired';
    }).length;

    return churned / eligible.length * 100;
  }

  bool _isActiveMember(Map<String, dynamic> member) {
    final status =
        member['membershipStatus']?.toString().toLowerCase();

    final expires = _date(member['membershipExpiresAt']);

    if (expires != null && expires.isBefore(DateTime.now())) {
      return false;
    }

    return status == 'active';
  }

  double _calculateLtv(
    List<Map<String, dynamic>> transactions,
    List<Map<String, dynamic>> members,
  ) {
    final income = transactions
        .where((item) => item['type'] == 'income')
        .fold<double>(
          0,
          (double sum, item) =>
              sum + ((item['amount'] as num?)?.toDouble() ?? 0),
        );

    final uniqueMembers = <String>{};
    for (final transaction in transactions) {
      if (transaction['type'] != 'income') {
        continue;
      }

      final memberId = transaction['memberId']?.toString();
      if (memberId != null && memberId.isNotEmpty) {
        uniqueMembers.add(memberId);
      }
    }

    final denominator = uniqueMembers.isNotEmpty
        ? uniqueMembers.length
        : math.max(members.length, 1);

    return income / denominator;
  }

  double _calculatePeriodLtv(
    List<Map<String, dynamic>> transactions,
    List<Map<String, dynamic>> members,
    DateTime startDate,
    DateTime endDate,
  ) {
    final period = transactions.where((transaction) {
      if (transaction['type'] != 'income') {
        return false;
      }

      final date = _date(transaction['date']);
      return date != null &&
          !date.isBefore(startDate) &&
          date.isBefore(endDate);
    }).toList();

    return _calculateLtv(period, members);
  }

  int _countAttendance(
    List<Map<String, dynamic>> attendance,
    DateTime startDate,
    DateTime endDate,
  ) {
    return attendance.where((record) {
      final date = _attendanceDate(record);
      return date != null &&
          !date.isBefore(startDate) &&
          date.isBefore(endDate);
    }).length;
  }

  double _calculateNps(
    List<Map<String, dynamic>> responses,
    DateTime startDate,
    DateTime endDate,
  ) {
    final scores = <double>[];

    for (final response in responses) {
      final date =
          _date(response['createdAt']) ??
              _date(response['date']);

      if (date == null ||
          date.isBefore(startDate) ||
          !date.isBefore(endDate)) {
        continue;
      }

      final score =
          (response['score'] as num?)?.toDouble() ??
              (response['rating'] as num?)?.toDouble();

      if (score != null && score >= 0 && score <= 10) {
        scores.add(score);
      }
    }

    if (scores.isEmpty) {
      return 0;
    }

    final promoters = scores.where((score) => score >= 9).length;
    final detractors = scores.where((score) => score <= 6).length;

    return (promoters / scores.length * 100) -
        (detractors / scores.length * 100);
  }

  DateTime? _attendanceDate(Map<String, dynamic> data) {
    const fields = [
      'checkInAt',
      'checkedInAt',
      'checkInTime',
      'timestamp',
      'date',
    ];

    for (final field in fields) {
      final parsed = _date(data[field]);
      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  DateTime? _date(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  String _monthLabel(DateTime date) {
    const labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return labels[date.month - 1];
  }

  String _buildRevenueCsv(
    List<Map<String, dynamic>> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    final rows = <List<String>>[
      ['Date', 'Title', 'Amount', 'Type', 'Category', 'Member ID'],
    ];

    for (final transaction in transactions) {
      final date = _date(transaction['date']);
      if (date == null ||
          date.isBefore(startDate) ||
          !date.isBefore(endDate)) {
        continue;
      }

      rows.add([
        date.toIso8601String(),
        transaction['title']?.toString() ?? '',
        '${transaction['amount'] ?? 0}',
        transaction['type']?.toString() ?? '',
        transaction['category']?.toString() ?? '',
        transaction['memberId']?.toString() ?? '',
      ]);
    }

    return _csv(rows);
  }

  String _buildMemberAcquisitionCsv(
    List<Map<String, dynamic>> members,
    DateTime startDate,
    DateTime endDate,
  ) {
    final rows = <List<String>>[
      ['Member ID', 'Name', 'Email', 'Joined At'],
    ];

    for (final member in members) {
      final joinedAt = _date(member['joinedAt']);
      if (joinedAt == null ||
          joinedAt.isBefore(startDate) ||
          !joinedAt.isBefore(endDate)) {
        continue;
      }

      rows.add([
        member['_id']?.toString() ?? '',
        member['displayName']?.toString() ?? '',
        member['email']?.toString() ?? '',
        joinedAt.toIso8601String(),
      ]);
    }

    return _csv(rows);
  }

  String _buildTrainerCsv(
    List<Map<String, dynamic>> trainers,
  ) {
    final rows = <List<String>>[
      [
        'Trainer ID',
        'Name',
        'Email',
        'Specialization',
        'Clients',
        'Sessions',
        'Rating',
        'Monthly Salary',
        'Status',
      ],
    ];

    for (final trainer in trainers) {
      rows.add([
        trainer['_id']?.toString() ?? '',
        trainer['displayName']?.toString() ?? '',
        trainer['email']?.toString() ?? '',
        trainer['specialization']?.toString() ?? '',
        '${trainer['clientCount'] ?? 0}',
        '${trainer['sessionCount'] ?? 0}',
        '${trainer['rating'] ?? 0}',
        '${trainer['monthlySalary'] ?? 0}',
        trainer['status']?.toString() ?? '',
      ]);
    }

    return _csv(rows);
  }

  String _buildAttendanceCsv(
    List<Map<String, dynamic>> attendance,
    DateTime startDate,
    DateTime endDate,
  ) {
    final rows = <List<String>>[
      ['Attendance ID', 'Member ID', 'Timestamp'],
    ];

    for (final record in attendance) {
      final date = _attendanceDate(record);
      if (date == null ||
          date.isBefore(startDate) ||
          !date.isBefore(endDate)) {
        continue;
      }

      rows.add([
        record['_id']?.toString() ?? '',
        record['memberId']?.toString() ?? '',
        date.toIso8601String(),
      ]);
    }

    return _csv(rows);
  }

  String _csv(List<List<String>> rows) {
    return rows.map((row) {
      return row
          .map(_escapeCsv)
          .join(',');
    }).join('\n');
  }

  String _escapeCsv(String value) {
    final needsQuotes =
        value.contains(',') ||
        value.contains('"') ||
        value.contains('\n');

    final escaped = value.replaceAll('"', '""');

    return needsQuotes ? '"$escaped"' : escaped;
  }
}
