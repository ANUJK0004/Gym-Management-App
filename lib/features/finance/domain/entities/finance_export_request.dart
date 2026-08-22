enum FinanceExportFormat {
  pdf,
  excel,
  csv,
}

enum FinanceExportPeriod {
  thisMonth,
  lastMonth,
  thisQuarter,
  thisYear,
}

enum FinanceExportSection {
  revenueSummary,
  transactionHistory,
  expenseBreakdown,
  membershipStats,
}

class FinanceExportRequest {
  const FinanceExportRequest({
    required this.gymId,
    required this.format,
    required this.period,
    required this.sections,
    this.email,
  });

  final String gymId;

  final FinanceExportFormat format;

  final FinanceExportPeriod period;

  final List<FinanceExportSection> sections;

  final String? email;

  bool get hasEmail {
    return email != null &&
        email!.trim().isNotEmpty;
  }
}