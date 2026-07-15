import 'package:equatable/equatable.dart';

import '../enums/expense_category.dart';
import '../enums/entry_type.dart';

/// A single ledger entry — represents either an expense or a fund update.
/// Immutable value object.
class LedgerEntry extends Equatable {
  const LedgerEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.timestamp,
    required this.balanceAfter,
    this.note,
    this.category,
  });

  final String id;
  final EntryType type;

  /// Positive for fund updates (money coming in), negative for expenses.
  /// Always stored as absolute value; sign is derived from type.
  final double amount;

  final String? note;
  final ExpenseCategory? category;
  final DateTime timestamp;

  /// Snapshot of the spendable balance immediately after this entry was applied.
  /// Used for accurate history display even if fund state changes later.
  final double balanceAfter;

  bool get isExpense => type == EntryType.expense;
  bool get isFundUpdate => type == EntryType.fundUpdate;

  LedgerEntry copyWith({
    String? id,
    EntryType? type,
    double? amount,
    String? note,
    ExpenseCategory? category,
    DateTime? timestamp,
    double? balanceAfter,
  }) {
    return LedgerEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      balanceAfter: balanceAfter ?? this.balanceAfter,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.value,
      'amount': amount,
      'note': note,
      'category': category?.value,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'balanceAfter': balanceAfter,
    };
  }

  factory LedgerEntry.fromFirestore(String id, Map<String, dynamic> data) {
    return LedgerEntry(
      id: id,
      type: EntryType.fromValue(data['type'] as String),
      amount: (data['amount'] as num).toDouble(),
      note: data['note'] as String?,
      category: data['category'] != null
          ? ExpenseCategory.fromValue(data['category'] as String)
          : null,
      timestamp: DateTime.parse(data['timestamp'] as String).toLocal(),
      balanceAfter: (data['balanceAfter'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        amount,
        note,
        category,
        timestamp,
        balanceAfter,
      ];
}
