import 'package:flutter/material.dart';

import 'package:sweatsync/app/theme/app_colors.dart';
import 'package:sweatsync/app/theme/app_radius.dart';

class AddMemberPaymentStep extends StatelessWidget {
  const AddMemberPaymentStep({
    super.key,
    required this.amount,
    required this.planName,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
  });

  final double amount;
  final String planName;
  final String? selectedPaymentMethod;

  final ValueChanged<String> onPaymentMethodChanged;

  static const paymentMethods = [
    _PaymentOption(
      id: 'cash',
      label: 'Cash',
      icon: Icons.payments_outlined,
    ),
    _PaymentOption(
      id: 'gcash',
      label: 'GCash',
      icon: Icons.account_balance_wallet_outlined,
    ),
    _PaymentOption(
      id: 'maya',
      label: 'Maya',
      icon: Icons.favorite,
    ),
    _PaymentOption(
      id: 'credit_card',
      label: 'Credit Card',
      icon: Icons.credit_card,
    ),
    _PaymentOption(
      id: 'bank_transfer',
      label: 'Bank Transfer',
      icon: Icons.account_balance,
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
          _totalCard(),

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
              padding:
              const EdgeInsets.only(bottom: 9),
              child: _paymentCard(option),
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Due Today',
                  style: TextStyle(
                    color:
                    AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  planName,
                  style: const TextStyle(
                    color:
                    AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₱${_money(amount)}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
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
      onTap: () =>
          onPaymentMethodChanged(option.id),
      borderRadius: AppRadius.radiusMD,
      child: Container(
        height: 52,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1D2A1B)
              : AppColors.background,
          borderRadius: AppRadius.radiusMD,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              size: 18,
              color: selected
                  ? AppColors.primary
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
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _money(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
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