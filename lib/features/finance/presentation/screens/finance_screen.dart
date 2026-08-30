import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

import '../../domain/entities/finance_export_request.dart';
import '../providers/finance_provider.dart';

import '../widgets/finance_header.dart';
import '../widgets/finance_period_selector.dart';
import '../widgets/revenue_breakdown_card.dart';
import '../widgets/revenue_trend_card.dart';
import '../widgets/transaction_card.dart';

import '../widgets/export_finance/finance_export_sheet.dart';
import '../widgets/export_finance/finance_export_success_sheet.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({
    super.key,
  });

  @override
  ConsumerState<FinanceScreen> createState() =>
      _FinanceScreenState();
}

class _FinanceScreenState
    extends ConsumerState<FinanceScreen> {
  late DateTime _selectedPeriod;

  RevenueTrendPeriod _trendPeriod =
      RevenueTrendPeriod.month;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _selectedPeriod = DateTime(
      now.year,
      now.month,
    );
  }

  // ==========================================================
  // EXPORT
  // ==========================================================

  Future<void> _openExportSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor:
      Colors.black.withValues(alpha: 0.70),
      useSafeArea: true,
      builder: (sheetContext) {
        return FinanceExportSheet(
          onExport: (
              format,
              period,
              sections,
              email,
              ) async {
            try {
              final result =
              await ref
                  .read(
                financeExportControllerProvider
                    .notifier,
              )
                  .export(
                format: format,
                period: period,
                sections: sections.toList(),
                email: email,
              );

              if (!mounted) {
                return;
              }

              // ------------------------------------------------
              // NO EMAIL
              //
              // Generate -> Storage -> signed URL -> open
              // ------------------------------------------------

              if (!result.emailed) {
                if (!result.hasDownloadUrl) {
                  throw Exception(
                    'The export was generated, but no download URL was returned.',
                  );
                }

                final uri =
                Uri.tryParse(
                  result.downloadUrl!,
                );

                if (uri == null) {
                  throw Exception(
                    'The download URL returned by the server is invalid.',
                  );
                }

                final opened =
                await launchUrl(
                  uri,
                  mode:
                  LaunchMode
                      .externalApplication,
                );

                if (!opened) {
                  throw Exception(
                    'Unable to open the exported file.',
                  );
                }
              }

              if (!mounted || !sheetContext.mounted) {
                return;
              }

              // ------------------------------------------------
              // CLOSE EXPORT SHEET
              // ------------------------------------------------

              Navigator.of(
                sheetContext,
              ).pop();

              await Future.delayed(
                const Duration(
                  milliseconds: 150,
                ),
              );

              if (!mounted) {
                return;
              }

              // ------------------------------------------------
              // SHOW SUCCESS SHEET
              // It automatically closes after 3 seconds.
              // ------------------------------------------------

              await _showExportSuccess(
                format,
                emailed:
                result.emailed,
              );
            } catch (error) {
              if (!mounted) {
                return;
              }

              _showMessage(
                'Finance export failed: $error',
              );
            }
          },
        );
      },
    );
  }

  Future<void> _showExportSuccess(
      FinanceExportFormat format, {
        required bool emailed,
      }) async {
    final label =
    _formatLabel(format);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor:
      Colors.transparent,
      barrierColor:
      Colors.black.withValues(alpha: 0.70),
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      builder: (_) {
        return FinanceExportSuccessSheet(
          format: label,
          emailed: emailed,
        );
      },
    );
  }

  String _formatLabel(
      FinanceExportFormat format,
      ) {
    switch (format) {
      case FinanceExportFormat.pdf:
        return 'PDF';

      case FinanceExportFormat.excel:
        return 'Excel';

      case FinanceExportFormat.csv:
        return 'CSV';
    }
  }

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ==========================================================
  // SCREEN
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final transactionsAsync =
    ref.watch(
      financeTransactionsProvider,
    );

    final breakdownAsync =
    ref.watch(
      revenueBreakdownProvider,
    );

    final trendAsync =
    ref.watch(
      revenueTrendProvider,
    );

    return Scaffold(
      backgroundColor:
      AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.owner,
          onRefresh: () async {
            ref.invalidate(
              financeTransactionsProvider,
            );

            ref.invalidate(
              revenueBreakdownProvider,
            );

            ref.invalidate(
              revenueTrendProvider,
            );

            await ref.read(
              financeTransactionsProvider.future,
            );
          },
          child: CustomScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding:
                const EdgeInsets.fromLTRB(
                  14,
                  18,
                  14,
                  30,
                ),
                sliver:
                SliverList(
                  delegate:
                  SliverChildListDelegate(
                    [
                      FinanceHeader(
                        onExport:
                        _openExportSheet,
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      FinancePeriodSelector(
                        selectedPeriod:
                        _selectedPeriod,
                        onChanged:
                            (period) {
                          setState(() {
                            _selectedPeriod =
                                period;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      trendAsync.when(
                        loading:
                            () =>
                        const _LoadingCard(),
                        error:
                            (
                            error,
                            stack,
                            ) =>
                        const _ErrorCard(
                          message:
                          'Unable to load revenue trend.',
                        ),
                        data:
                            (trends) =>
                            RevenueTrendCard(
                              trends:
                              trends,
                              period:
                              _trendPeriod,
                              onPeriodChanged:
                                  (period) {
                                setState(() {
                                  _trendPeriod =
                                      period;
                                });
                              },
                            ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      const _SectionTitle(
                        title:
                        'REVENUE BREAKDOWN',
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      breakdownAsync.when(
                        loading:
                            () =>
                        const _LoadingCard(),
                        error:
                            (
                            error,
                            stack,
                            ) =>
                        const _ErrorCard(
                          message:
                          'Unable to load revenue breakdown.',
                        ),
                        data:
                            (breakdown) {
                          if (breakdown.isEmpty) {
                            return const _EmptyCard(
                              message:
                              'No revenue recorded for this period.',
                            );
                          }

                          return Column(
                            children:
                            breakdown
                                .map(
                                  (item) =>
                                  RevenueBreakdownCard(
                                    breakdown:
                                    item,
                                  ),
                            )
                                .toList(),
                          );
                        },
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      Row(
                        children: [
                          const Expanded(
                            child:
                            _SectionTitle(
                              title:
                              'RECENT TRANSACTIONS',
                            ),
                          ),
                          Text(
                            'See all',
                            style:
                            AppTextStyles
                                .labelMedium
                                .copyWith(
                              color:
                              AppColors
                                  .owner,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      transactionsAsync.when(
                        loading:
                            () =>
                        const _LoadingCard(),
                        error:
                            (
                            error,
                            stack,
                            ) =>
                        const _ErrorCard(
                          message:
                          'Unable to load transactions.',
                        ),
                        data:
                            (transactions) {
                          if (transactions
                              .isEmpty) {
                            return const _EmptyCard(
                              message:
                              'No transactions found.',
                            );
                          }

                          return Column(
                            children:
                            transactions
                                .map(
                                  (transaction) =>
                                  TransactionCard(
                                    transaction:
                                    transaction,
                                  ),
                            )
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle
    extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style:
      AppTextStyles.labelMedium
          .copyWith(
        color:
        AppColors.textSecondary,
        fontWeight:
        FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ============================================================
// LOADING
// ============================================================

class _LoadingCard
    extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(
        child:
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.owner),
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY
// ============================================================

class _EmptyCard
    extends StatelessWidget {
  const _EmptyCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(24),
      decoration:
      BoxDecoration(
        color:
        AppColors.surface,
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign:
        TextAlign.center,
        style:
        AppTextStyles.bodyMedium
            .copyWith(
          color:
          AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ErrorCard
    extends StatelessWidget {
  const _ErrorCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return _EmptyCard(
      message: message,
    );
  }
}