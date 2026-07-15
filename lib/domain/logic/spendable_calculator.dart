import '../models/fund_state.dart';

/// Pure business logic for spendable calculations.
/// No Flutter or Firebase dependencies — fully testable in isolation.
class SpendableCalculator {
  const SpendableCalculator._();

  /// Core formula: spendable = principal - locked
  static double computeSpendable({
    required double principal,
    required double locked,
  }) {
    return principal - locked;
  }

  /// Compute new spendable after deducting an expense.
  static double afterExpense({
    required double currentSpendable,
    required double expenseAmount,
  }) {
    return currentSpendable - expenseAmount;
  }

  /// Compute new principal after adding funds.
  static double afterAddFunds({
    required double currentPrincipal,
    required double addedAmount,
  }) {
    return currentPrincipal + addedAmount;
  }

  /// Validate that an expense amount is positive and within limits.
  static ExpenseValidationResult validateExpense({
    required double amount,
    required double currentSpendable,
  }) {
    if (amount <= 0) {
      return ExpenseValidationResult.invalid('Amount must be greater than ₹0');
    }
    if (amount > currentSpendable) {
      // Warn but don't hard-block — overspending is allowed with confirmation
      return ExpenseValidationResult.warning(
        'This expense exceeds your spendable amount by '
        '₹${(amount - currentSpendable).toStringAsFixed(2)}',
      );
    }
    return ExpenseValidationResult.valid();
  }

  /// Validate principal and locked amounts for fund state update.
  static FundStateValidationResult validateFundState({
    required double principal,
    required double locked,
  }) {
    if (principal < 0) {
      return FundStateValidationResult.invalid(
        'Principal amount cannot be negative',
      );
    }
    if (locked < 0) {
      return FundStateValidationResult.invalid(
        'Locked amount cannot be negative',
      );
    }
    if (locked > principal) {
      return FundStateValidationResult.invalid(
        'Locked amount cannot exceed principal amount',
      );
    }
    return FundStateValidationResult.valid();
  }

  /// Compute total spent in a list of amounts (all positive values)
  static double totalSpent(List<double> amounts) {
    return amounts.fold(0.0, (sum, a) => sum + a);
  }

  /// New FundState after applying an expense (reduces principal, locked unchanged)
  static FundState applyExpenseToFundState({
    required FundState state,
    required double expenseAmount,
  }) {
    return state.copyWith(
      principalAmount: state.principalAmount - expenseAmount,
      lastUpdated: DateTime.now(),
    );
  }

  /// New FundState after a fund update
  static FundState applyFundUpdate({
    required FundState state,
    required double newPrincipal,
    required double newLocked,
  }) {
    return state.copyWith(
      principalAmount: newPrincipal,
      lockedAmount: newLocked,
      lastUpdated: DateTime.now(),
    );
  }
}

/// Result of expense validation
class ExpenseValidationResult {
  const ExpenseValidationResult._({
    required this.isValid,
    required this.isWarning,
    this.message,
  });

  factory ExpenseValidationResult.valid() =>
      const ExpenseValidationResult._(isValid: true, isWarning: false);

  factory ExpenseValidationResult.warning(String message) =>
      ExpenseValidationResult._(
          isValid: true, isWarning: true, message: message);

  factory ExpenseValidationResult.invalid(String message) =>
      ExpenseValidationResult._(
          isValid: false, isWarning: false, message: message);

  final bool isValid;
  final bool isWarning;
  final String? message;
}

/// Result of fund state validation
class FundStateValidationResult {
  const FundStateValidationResult._({
    required this.isValid,
    this.message,
  });

  factory FundStateValidationResult.valid() =>
      const FundStateValidationResult._(isValid: true);

  factory FundStateValidationResult.invalid(String message) =>
      FundStateValidationResult._(isValid: false, message: message);

  final bool isValid;
  final String? message;
}
