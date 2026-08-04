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

class FinanceScreen
    extends ConsumerStatefulWidget {
  const FinanceScreen({
    super.key,
  });

  @override
  ConsumerState<
      FinanceScreen>
  createState() =>
      _FinanceScreenState();
}

class _FinanceScreenState
    extends ConsumerState<
        FinanceScreen> {
  late DateTime _selectedPeriod;

  RevenueTrendPeriod
  _trendPeriod =
      RevenueTrendPeriod.month;

  @override
  void initState() {
    super.initState();

    final now =
    DateTime.now();

    _selectedPeriod =
        DateTime(
          now.year,
          now.month,
        );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
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
        child:
        RefreshIndicator(
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
              financeTransactionsProvider
                  .future,
            );
          },

          child:
          CustomScrollView(
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
                            () {
                          ScaffoldMessenger
                              .of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content:
                              Text(
                                'Finance export will be connected next.',
                              ),
                            ),
                          );
                        },
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
                          if (breakdown
                              .isEmpty) {
                            return const _EmptyCard(
                              message:
                              'No revenue recorded for this period.',
                            );
                          }

                          return Column(
                            children:
                            breakdown
                                .map(
                                  (
                                  item,
                                  ) =>
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
                                  .primary,
                              fontWeight:
                              FontWeight
                                  .w600,
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
                                  (
                                  transaction,
                                  ) =>
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

class _SectionTitle
    extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Text(
      title,
      style:
      AppTextStyles
          .labelMedium
          .copyWith(
        color:
        AppColors
            .textSecondary,
        fontWeight:
        FontWeight.w600,
        letterSpacing:
        0.8,
      ),
    );
  }
}

class _LoadingCard
    extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(
      BuildContext context,
      ) {
    return const SizedBox(
      height: 120,
      child: Center(
        child:
        CircularProgressIndicator(),
      ),
    );
  }
}

class _EmptyCard
    extends StatelessWidget {
  const _EmptyCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        24,
      ),
      decoration:
      BoxDecoration(
        color:
        AppColors.surface,
        borderRadius:
        BorderRadius.circular(
          12,
        ),
      ),
      child: Text(
        message,
        textAlign:
        TextAlign.center,
        style:
        AppTextStyles
            .bodyMedium
            .copyWith(
          color:
          AppColors
              .textSecondary,
        ),
      ),
    );
  }
}

class _ErrorCard
    extends StatelessWidget {
  const _ErrorCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(
      BuildContext context,
      ) {
    return _EmptyCard(
      message: message,
    );
  }
}