import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';

class AddMemberPaymentStep extends StatelessWidget {
  const AddMemberPaymentStep({
    super.key,
    required this.memberName,
    required this.planName,
    required this.fitnessGoal,
    required this.amount,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
  });

  final String memberName;
  final String planName;
  final String? fitnessGoal;
  final double amount;

  /// null means that no payment method has been selected yet.
  /// In that state the UI shows "Payment Pending".
  final String? selectedPaymentMethod;

  final ValueChanged<String?> onPaymentMethodChanged;

  static const paymentMethods = [
    _PaymentOption(
      id: 'upi',
      label: 'UPI',
      icon: Icons.account_balance_wallet_outlined,
    ),
    _PaymentOption(
      id: 'cash',
      label: 'Cash',
      icon: Icons.payments_outlined,
    ),
    _PaymentOption(
      id: 'card',
      label: 'Card',
      icon: Icons.credit_card,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryCard(),

          const SizedBox(height: 20),

          const Text(
            'PAYMENT METHOD',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 9),

          ...paymentMethods.map(
                (option) => Padding(
              padding: const EdgeInsets.only(
                bottom: 9,
              ),
              child: _paymentCard(option),
            ),
          ),

          // null means no payment method has been selected.
          // This is displayed as a status rather than another
          // selectable payment option.
          if (selectedPaymentMethod == null) ...[
            const SizedBox(height: 2),
            _paymentPendingIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ENROLLMENT SUMMARY',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 10),

          _summaryRow(
            'Member',
            memberName,
          ),

          _summaryRow(
            'Plan',
            planName,
          ),

          _summaryRow(
            'Goal',
            fitnessGoal ?? 'Not specified',
          ),

          _summaryRow(
            'Amount',
            '₱${_money(amount)}/month',
          ),

          const Divider(
            color: AppColors.border,
            height: 20,
          ),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total Due Today',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '₱${_money(amount)}',
                style: const TextStyle(
                  color: AppColors.owner,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 7,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(
      _PaymentOption option,
      ) {
    final selected =
        selectedPaymentMethod == option.id;

    return InkWell(
      onTap: () {
        onPaymentMethodChanged(option.id);
      },
      borderRadius: AppRadius.radiusMD,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF332314)
              : AppColors.background,
          borderRadius: AppRadius.radiusMD,
          border: Border.all(
            color: selected
                ? AppColors.owner
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              size: 18,
              color: selected
                  ? AppColors.owner
                  : AppColors.textSecondary,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                option.label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              size: 17,
              color: selected
                  ? AppColors.owner
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentPendingIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF332314),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: AppColors.owner,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.schedule_outlined,
            size: 16,
            color: AppColors.owner,
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              'Payment Pending',
              style: TextStyle(
                color: AppColors.owner,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _money(
      double amount,
      ) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
      RegExp(
        r'(\d)(?=(\d{3})+(?!\d))',
      ),
          (match) => '${match[1]},',
    );
  }
}

class _PaymentOption {
  const _PaymentOption({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}