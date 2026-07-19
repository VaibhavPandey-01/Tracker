class Transaction {
  final String id;
  final String accountId;
  final String categoryId;
  final double amount;
  final String note;
  final DateTime date;
  final bool isRecurring;

  const Transaction({
    required this.id,
    required this.accountId,
    required this.categoryId,
    required this.amount,
    required this.note,
    required this.date,
    this.isRecurring = false,
  });

  Transaction copyWith({
    String? id,
    String? accountId,
    String? categoryId,
    double? amount,
    String? note,
    DateTime? date,
    bool? isRecurring,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }
}
