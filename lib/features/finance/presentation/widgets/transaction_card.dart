import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';

import '../../domain/entities/finance_transaction.dart';

class TransactionCard
    extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
  });

  final FinanceTransaction
  transaction;

  @override
  Widget build(
      BuildContext context,
      ) {
    final isIncome =
        transaction.isIncome;

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 8,
      ),
      padding:
      const EdgeInsets.all(
        10,
      ),
      decoration:
      BoxDecoration(
        color:
        AppColors.surface,
        borderRadius:
        AppRadius.radiusMD,
        border:
        Border.all(
          color:
          AppColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
            BoxDecoration(
              color: isIncome
                  ? AppColors
                  .primary
                  .withValues(
                alpha: 0.10,
              )
                  : Colors.red
                  .withValues(
                alpha: 0.10,
              ),
              shape:
              BoxShape.circle,
            ),
            child:
            Icon(
              isIncome
                  ? Icons
                  .account_balance_wallet_rounded
                  : Icons
                  .receipt_long_rounded,
              size: 18,
              color: isIncome
                  ? AppColors
                  .primary
                  : Colors.redAccent,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  AppTextStyles
                      .bodyMedium
                      .copyWith(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  _subtitle,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  AppTextStyles
                      .labelMedium
                      .copyWith(
                    color:
                    AppColors
                        .textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Text(
            '${isIncome ? '+' : '-'}₹${transaction.amount.toStringAsFixed(0)}',
            style:
            AppTextStyles
                .bodyMedium
                .copyWith(
              color: isIncome
                  ? AppColors
                  .primary
                  : Colors.redAccent,
              fontWeight:
              FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String get _subtitle {
    if (transaction.category !=
        null) {
      return '${transaction.category} · ${_formatDate(transaction.date)}';
    }

    return _formatDate(
      transaction.date,
    );
  }

  String _formatDate(
      DateTime date,
      ) {
    const months = [
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

    return '${months[date.month - 1]} ${date.day}';
  }
}