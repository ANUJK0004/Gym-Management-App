import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class FinancePeriodSelector
    extends StatelessWidget {
  const FinancePeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  final DateTime selectedPeriod;

  final ValueChanged<DateTime>
  onChanged;

  @override
  Widget build(
      BuildContext context,
      ) {
    final label =
        '${_monthName(selectedPeriod.month)} '
        '${selectedPeriod.year} '
        'REVENUE';

    return InkWell(
      onTap: () async {
        final selected =
        await showDatePicker(
          context: context,
          initialDate:
          selectedPeriod,
          firstDate:
          DateTime(2020),
          lastDate:
          DateTime.now(),
        );

        if (selected != null) {
          onChanged(
            DateTime(
              selected.year,
              selected.month,
            ),
          );
        }
      },
      borderRadius:
      BorderRadius.circular(
        14,
      ),
      child: Container(
        width:
        double.infinity,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 11,
        ),
        decoration:
        BoxDecoration(
          color:
          AppColors.primary
              .withOpacity(
            0.12,
          ),
          borderRadius:
          BorderRadius.circular(
            14,
          ),
          border:
          Border.all(
            color:
            AppColors.primary
                .withOpacity(
              0.35,
            ),
          ),
        ),
        child: Text(
          label,
          style:
          const TextStyle(
            color:
            AppColors.primary,
            fontSize: 11,
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _monthName(
      int month,
      ) {
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];

    return months[month - 1];
  }
}