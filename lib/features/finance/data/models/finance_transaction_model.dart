import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/finance_transaction.dart';

class FinanceTransactionModel
    extends FinanceTransaction {
  const FinanceTransactionModel({
    required super.id,
    required super.gymId,
    required super.title,
    required super.amount,
    required super.type,
    required super.date,
    super.category,
    super.description,
    super.memberId,
    super.membershipPlanId,
  });

  factory FinanceTransactionModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'Finance transaction does not exist.',
      );
    }

    return FinanceTransactionModel(
      id: document.id,

      gymId:
      data['gymId'] as String? ?? '',

      title:
      data['title'] as String? ?? '',

      amount:
      (data['amount'] as num?)?.toDouble() ?? 0,

      type:
      _parseType(
        data['type'],
      ),

      date:
      _parseDate(
        data['date'],
      ),

      category:
      data['category'] as String?,

      description:
      data['description'] as String?,

      memberId:
      data['memberId'] as String?,

      membershipPlanId:
      data['membershipPlanId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gymId': gymId,
      'title': title,
      'amount': amount,
      'type': type.name,
      'date': Timestamp.fromDate(date),
      'category': category,
      'description': description,
      'memberId': memberId,
      'membershipPlanId': membershipPlanId,
    };
  }

  static FinanceTransactionType _parseType(
      dynamic value,
      ) {
    if (value == 'expense') {
      return FinanceTransactionType.expense;
    }

    return FinanceTransactionType.income;
  }

  static DateTime _parseDate(
      dynamic value,
      ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    return DateTime.now();
  }
}