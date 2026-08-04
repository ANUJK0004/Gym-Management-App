enum FinanceTransactionType {
  income,
  expense,
}

class FinanceTransaction {
  const FinanceTransaction({
    required this.id,
    required this.gymId,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.category,
    this.description,
    this.memberId,
    this.membershipPlanId,
  });

  final String id;

  final String gymId;

  final String title;

  final double amount;

  final FinanceTransactionType type;

  final DateTime date;

  final String? category;

  final String? description;

  final String? memberId;

  final String? membershipPlanId;

  bool get isIncome =>
      type == FinanceTransactionType.income;

  bool get isExpense =>
      type == FinanceTransactionType.expense;
}