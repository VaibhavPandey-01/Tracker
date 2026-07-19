enum RecurringFrequency { daily, weekly, monthly, yearly }

extension RecurringFrequencyLabel on RecurringFrequency {
  String get label {
    switch (this) {
      case RecurringFrequency.daily:
        return 'Daily';
      case RecurringFrequency.weekly:
        return 'Weekly';
      case RecurringFrequency.monthly:
        return 'Monthly';
      case RecurringFrequency.yearly:
        return 'Yearly';
    }
  }
}

class RecurringRule {
  final String id;
  final String accountId;
  final String categoryId;
  final double amount;
  final String note;
  final RecurringFrequency frequency;
  final DateTime nextDate;
  final bool isActive;

  const RecurringRule({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.note,
    required this.frequency,
    required this.nextDate,
    this.isActive = true,
  });

  RecurringRule copyWith({
    String? id,
    String? accountId,
    String? categoryId,
    double? amount,
    String? note,
    RecurringFrequency? frequency,
    DateTime? nextDate,
    bool? isActive,
  }) {
    return RecurringRule(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      frequency: frequency ?? this.frequency,
      nextDate: nextDate ?? this.nextDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
