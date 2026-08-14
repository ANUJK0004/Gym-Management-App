import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_text_styles.dart';

import 'report_export_content_step.dart';
import 'report_export_format_step.dart';
import 'report_export_step_indicator.dart';
import 'report_export_success_sheet.dart';
import 'report_export_type_step.dart';

enum ReportExportType {
  finance,
  members,
  staff,
  operations,
  fullReport,
}

extension ReportExportTypeData on ReportExportType {
  String get label {
    switch (this) {
      case ReportExportType.finance:
        return 'Finance';
      case ReportExportType.members:
        return 'Members';
      case ReportExportType.staff:
        return 'Staff';
      case ReportExportType.operations:
        return 'Operations';
      case ReportExportType.fullReport:
        return 'Full Report';
    }
  }

  String get icon {
    switch (this) {
      case ReportExportType.finance:
        return '💰';
      case ReportExportType.members:
        return '👥';
      case ReportExportType.staff:
        return '🏆';
      case ReportExportType.operations:
        return '🗓️';
      case ReportExportType.fullReport:
        return '📊';
    }
  }

  String get description {
    switch (this) {
      case ReportExportType.finance:
        return 'Revenue, expenses, profit & membership billing';
      case ReportExportType.members:
        return 'Enrollment, retention, churn and plan distribution';
      case ReportExportType.staff:
        return 'Trainer sessions, ratings and performance scores';
      case ReportExportType.operations:
        return 'Gym attendance, peak hours and capacity data';
      case ReportExportType.fullReport:
        return 'All sections combined into one comprehensive report';
    }
  }

  List<ReportExportSection> get sections {
    switch (this) {
      case ReportExportType.finance:
        return const [
          ReportExportSection(
            id: 'revenue',
            label: 'Revenue',
          ),
          ReportExportSection(
            id: 'expenses',
            label: 'Expenses',
          ),
          ReportExportSection(
            id: 'profit_loss',
            label: 'Profit & Loss',
          ),
          ReportExportSection(
            id: 'membership_billing',
            label: 'Membership Billing',
          ),
        ];

      case ReportExportType.members:
        return const [
          ReportExportSection(
            id: 'enrollment',
            label: 'Enrollment',
          ),
          ReportExportSection(
            id: 'retention',
            label: 'Retention',
          ),
          ReportExportSection(
            id: 'churn',
            label: 'Churn Rate',
          ),
          ReportExportSection(
            id: 'membership_breakdown',
            label: 'Membership Breakdown',
          ),
        ];

      case ReportExportType.staff:
        return const [
          ReportExportSection(
            id: 'trainer_sessions',
            label: 'Trainer Sessions',
          ),
          ReportExportSection(
            id: 'client_ratings',
            label: 'Client Ratings',
          ),
          ReportExportSection(
            id: 'attendance_rate',
            label: 'Attendance Rate',
          ),
          ReportExportSection(
            id: 'performance_scores',
            label: 'Performance Scores',
          ),
        ];

      case ReportExportType.operations:
        return const [
          ReportExportSection(
            id: 'attendance_rate',
            label: 'Attendance Rate',
          ),
          ReportExportSection(
            id: 'peak_hours',
            label: 'Peak Hours',
          ),
          ReportExportSection(
            id: 'capacity_data',
            label: 'Capacity Data',
          ),
        ];

      case ReportExportType.fullReport:
        return const [
          ReportExportSection(
            id: 'finance_summary',
            label: 'Finance Summary',
          ),
          ReportExportSection(
            id: 'member_analytics',
            label: 'Member Analytics',
          ),
          ReportExportSection(
            id: 'staff_performance',
            label: 'Staff Performance',
          ),
          ReportExportSection(
            id: 'operations_attendance',
            label: 'Operations & Attendance',
          ),
        ];
    }
  }
}

class ReportExportSection {
  const ReportExportSection({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

enum ReportExportFormat {
  pdf,
  excel,
  csv,
}

extension ReportExportFormatData on ReportExportFormat {
  String get label {
    switch (this) {
      case ReportExportFormat.pdf:
        return 'PDF';
      case ReportExportFormat.excel:
        return 'Excel';
      case ReportExportFormat.csv:
        return 'CSV';
    }
  }

  String get subtitle {
    switch (this) {
      case ReportExportFormat.pdf:
        return 'Print-ready';
      case ReportExportFormat.excel:
        return 'Editable';
      case ReportExportFormat.csv:
        return 'Raw data';
    }
  }

  String get icon {
    switch (this) {
      case ReportExportFormat.pdf:
        return '📄';
      case ReportExportFormat.excel:
        return '📊';
      case ReportExportFormat.csv:
        return '📋';
    }
  }
}

enum ReportExportPeriod {
  thisWeek,
  thisMonth,
  lastMonth,
  thisQuarter,
  lastQuarter,
  thisYear,
}

extension ReportExportPeriodData on ReportExportPeriod {
  String get label {
    switch (this) {
      case ReportExportPeriod.thisWeek:
        return 'This Week';
      case ReportExportPeriod.thisMonth:
        return 'This Month';
      case ReportExportPeriod.lastMonth:
        return 'Last Month';
      case ReportExportPeriod.thisQuarter:
        return 'This Quarter';
      case ReportExportPeriod.lastQuarter:
        return 'Last Quarter';
      case ReportExportPeriod.thisYear:
        return 'This Year';
    }
  }
}

class ReportExportResult {
  const ReportExportResult({
    required this.reportType,
    required this.sections,
    required this.format,
    required this.period,
    required this.email,
  });

  final ReportExportType reportType;
  final Set<String> sections;
  final ReportExportFormat format;
  final ReportExportPeriod period;
  final String email;
}

class ReportExportSheet extends StatefulWidget {
  const ReportExportSheet({
    super.key,
  });

  @override
  State<ReportExportSheet> createState() =>
      _ReportExportSheetState();
}

class _ReportExportSheetState
    extends State<ReportExportSheet> {
  int _currentStep = 0;

  ReportExportType? _selectedType;

  Set<String> _selectedSections = {};

  ReportExportFormat _selectedFormat =
      ReportExportFormat.pdf;

  ReportExportPeriod _selectedPeriod =
      ReportExportPeriod.thisYear;

  final TextEditingController _emailController =
  TextEditingController();

  bool _isExporting = false;

  ReportExportResult? _result;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) {
      return ReportExportSuccessSheet(
        result: _result!,
        onDone: () {
          Navigator.of(context).pop();
        },
      );
    }

    return SafeArea(
      top: false,
      child: Material(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        child: SizedBox(
          height:
          MediaQuery.of(context).size.height *
              0.82,
          child: Column(
            children: [
              const SizedBox(height: 12),
              _handle(),
              const SizedBox(height: 14),
              _header(),
              const SizedBox(height: 10),
              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: ReportExportStepIndicator(
                  currentStep: _currentStep,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _buildStep(),
              ),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _handle() {
    return Container(
      width: 34,
      height: 4,
      decoration: BoxDecoration(
        color:
        AppColors.textSecondary
            .withOpacity(0.55),
        borderRadius:
        BorderRadius.circular(10),
      ),
    );
  }

  Widget _header() {
    final title = switch (_currentStep) {
      0 => 'Report Type',
      1 => 'Content',
      2 => 'Format & Delivery',
      _ => '',
    };

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Export Report',
                  style:
                  AppTextStyles.headlineMedium
                      .copyWith(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Step ${_currentStep + 1} of 3 — $title',
                  style:
                  AppTextStyles.bodySmall
                      .copyWith(
                    color:
                    AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _isExporting
                ? null
                : () =>
                Navigator.of(context).pop(),
            borderRadius:
            BorderRadius.circular(30),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 19,
                color:
                AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return ReportExportTypeStep(
          selectedType: _selectedType,
          onTypeSelected: _selectType,
        );

      case 1:
        if (_selectedType == null) {
          return const SizedBox.shrink();
        }

        return ReportExportContentStep(
          reportType: _selectedType!,
          selectedSections: _selectedSections,
          onSelectionChanged: (value) {
            setState(() {
              _selectedSections = value;
            });
          },
        );

      case 2:
        return ReportExportFormatStep(
          reportType: _selectedType!,
          selectedSectionCount:
          _selectedSections.length,
          selectedFormat: _selectedFormat,
          selectedPeriod: _selectedPeriod,
          emailController: _emailController,
          onFormatChanged: (format) {
            setState(() {
              _selectedFormat = format;
            });
          },
          onPeriodChanged: (period) {
            setState(() {
              _selectedPeriod = period;
            });
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _footer() {
    if (_currentStep == 0) {
      return _navigation(
        backEnabled: false,
        nextLabel: 'Continue →',
        onNext:
        _selectedType == null
            ? null
            : _goToContent,
      );
    }

    if (_currentStep == 1) {
      return _navigation(
        backEnabled: true,
        nextLabel: 'Continue →',
        onBack: _goBack,
        onNext:
        _selectedSections.isEmpty
            ? null
            : _goToFormat,
      );
    }

    return _navigation(
      backEnabled: true,
      nextLabel:
      _isExporting
          ? 'Exporting...'
          : '↓ Export as ${_selectedFormat.label}',
      onBack:
      _isExporting ? null : _goBack,
      onNext:
      _isExporting ? null : _export,
      loading: _isExporting,
    );
  }

  Widget _navigation({
    required bool backEnabled,
    required String nextLabel,
    VoidCallback? onBack,
    VoidCallback? onNext,
    bool loading = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          if (backEnabled) ...[
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: onBack,
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.background,
                    foregroundColor:
                    AppColors.textPrimary,
                    elevation: 0,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      AppRadius.radiusMD,
                    ),
                  ),
                  child: const Text(
                    '← Back',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onNext,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  AppColors.primary,
                  foregroundColor:
                  Colors.black,
                  disabledBackgroundColor:
                  AppColors.primary
                      .withOpacity(0.35),
                  elevation: 0,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    AppRadius.radiusMD,
                  ),
                ),
                child: loading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: Colors.black,
                  ),
                )
                    : Text(
                  nextLabel,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectType(
      ReportExportType type,
      ) {
    setState(() {
      _selectedType = type;
      _selectedSections = {};
    });
  }

  void _goToContent() {
    if (_selectedType == null) {
      return;
    }

    setState(() {
      _selectedSections =
          _selectedType!
              .sections
              .map(
                (section) => section.id,
          )
              .toSet();

      _currentStep = 1;
    });
  }

  void _goToFormat() {
    if (_selectedSections.isEmpty) {
      return;
    }

    setState(() {
      _currentStep = 2;
    });
  }

  void _goBack() {
    if (_currentStep <= 0) {
      return;
    }

    setState(() {
      _currentStep--;
    });
  }

  Future<void> _export() async {
    if (_selectedType == null ||
        _selectedSections.isEmpty) {
      return;
    }

    setState(() {
      _isExporting = true;
    });

    // Backend generation/download will be
    // connected after the UI layer is complete.
    await Future<void>.delayed(
      const Duration(
        milliseconds: 450,
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isExporting = false;

      _result = ReportExportResult(
        reportType: _selectedType!,
        sections:
        Set<String>.from(
          _selectedSections,
        ),
        format: _selectedFormat,
        period: _selectedPeriod,
        email:
        _emailController.text.trim(),
      );
    });
  }
}