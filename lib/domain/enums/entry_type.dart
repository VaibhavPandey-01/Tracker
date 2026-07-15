/// Entry type enum — distinguishes expense from fund state updates in the ledger.
enum EntryType {
  expense('expense'),
  fundUpdate('fund_update');

  const EntryType(this.value);
  final String value;

  static EntryType fromValue(String value) {
    return EntryType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EntryType.expense,
    );
  }

  String get displayLabel {
    switch (this) {
      case EntryType.expense:
        return 'Expense';
      case EntryType.fundUpdate:
        return 'Fund Update';
    }
  }
}
