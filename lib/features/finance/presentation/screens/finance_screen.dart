import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

import '../providers/finance_provider.dart';

import '../widgets/finance_header.dart';
import '../widgets/finance_period_selector.dart';
import '../widgets/revenue_breakdown_card.dart';
import '../widgets/revenue_trend_card.dart';
import '../widgets/transaction_card.dart';

import '../widgets/export_finance/finance_export_format_selector.dart';
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

  Future<void> _openExportSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.70),
      useSafeArea: true,
      builder: (sheetContext) {
        return FinanceExportSheet(
          onExport: (
              format,
              period,
              sections,
              ) async {
            /*
             * UI PHASE ONLY
             *
             * Backend connection will be added later.
             *
             * For now we simulate a successful export so that
             * the complete UI flow can be tested.
             */
            await Future.delayed(
              const Duration(milliseconds: 500),
            );

            if (!mounted) {
              return;
            }

            Navigator.of(sheetContext).pop();

            await Future.delayed(
              const Duration(milliseconds: 150),
            );

            if (!mounted) {
              return;
            }

            await _showExportSuccess(
              format,
            );
          },
        );
      },
    );
  }

  Future<void> _showExportSuccess(
      FinanceExportFormat format,
      ) async {
    String label;

    switch (format) {
      case FinanceExportFormat.pdf:
        label = 'PDF';
        break;
      case FinanceExportFormat.excel:
        label = 'Excel';
        break;
      case FinanceExportFormat.csv:
        label = 'CSV';
        break;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.70),
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      builder: (_) {
        return FinanceExportSuccessSheet(
          format: label,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync =
    ref.watch(financeTransactionsProvider);

    final breakdownAsync =
    ref.watch(revenueBreakdownProvider);

    final trendAsync =
    ref.watch(revenueTrendProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
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
                padding: const EdgeInsets.fromLTRB(
                  14,
                  18,
                  14,
                  30,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      FinanceHeader(
                        onExport: _openExportSheet,
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      FinancePeriodSelector(
                        selectedPeriod:
                        _selectedPeriod,
                        onChanged: (period) {
                          setState(() {
                            _selectedPeriod = period;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      trendAsync.when(
                        loading: () =>
                        const _LoadingCard(),

                        error: (
                            error,
                            stack,
                            ) =>
                        const _ErrorCard(
                          message:
                          'Unable to load revenue trend.',
                        ),

                        data: (trends) =>
                            RevenueTrendCard(
                              trends: trends,
                              period: _trendPeriod,
                              onPeriodChanged:
                                  (period) {
                                setState(() {
                                  _trendPeriod = period;
                                });
                              },
                            ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      const _SectionTitle(
                        title: 'REVENUE BREAKDOWN',
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      breakdownAsync.when(
                        loading: () =>
                        const _LoadingCard(),

                        error: (
                            error,
                            stack,
                            ) =>
                        const _ErrorCard(
                          message:
                          'Unable to load revenue breakdown.',
                        ),

                        data: (breakdown) {
                          if (breakdown.isEmpty) {
                            return const _EmptyCard(
                              message:
                              'No revenue recorded for this period.',
                            );
                          }

                          return Column(
                            children: breakdown
                                .map(
                                  (item) =>
                                  RevenueBreakdownCard(
                                    breakdown: item,
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
                            child: _SectionTitle(
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
                              AppColors.primary,
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
                        loading: () =>
                        const _LoadingCard(),

                        error: (
                            error,
                            stack,
                            ) =>
                        const _ErrorCard(
                          message:
                          'Unable to load transactions.',
                        ),

                        data: (transactions) {
                          if (transactions.isEmpty) {
                            return const _EmptyCard(
                              message:
                              'No transactions found.',
                            );
                          }

                          return Column(
                            children: transactions
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.labelMedium.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
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