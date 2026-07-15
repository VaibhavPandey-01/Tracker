import 'package:flutter_test/flutter_test.dart';

import 'package:tracker_app/domain/logic/spendable_calculator.dart';
import 'package:tracker_app/domain/models/fund_state.dart';

void main() {
  group('SpendableCalculator', () {
    // ---------------------------------------------------------------------------
    // computeSpendable
    // ---------------------------------------------------------------------------
    group('computeSpendable', () {
      test('correctly computes spendable as principal minus locked', () {
        expect(
          SpendableCalculator.computeSpendable(
            principal: 8000,
            locked: 6000,
          ),
          equals(2000),
        );
      });

      test('returns 0 when principal equals locked', () {
        expect(
          SpendableCalculator.computeSpendable(
            principal: 5000,
            locked: 5000,
          ),
          equals(0),
        );
      });

      test('returns negative when locked exceeds principal (overspent state)', () {
        // This shouldn't happen via normal flow, but the calc must be honest
        expect(
          SpendableCalculator.computeSpendable(
            principal: 4000,
            locked: 6000,
          ),
          equals(-2000),
        );
      });

      test('works with decimal amounts', () {
        expect(
          SpendableCalculator.computeSpendable(
            principal: 8000.50,
            locked: 3000.25,
          ),
          closeTo(5000.25, 0.001),
        );
      });

      test('works with zero locked amount', () {
        expect(
          SpendableCalculator.computeSpendable(
            principal: 10000,
            locked: 0,
          ),
          equals(10000),
        );
      });
    });

    // ---------------------------------------------------------------------------
    // validateExpense
    // ---------------------------------------------------------------------------
    group('validateExpense', () {
      test('returns valid for amount within spendable', () {
        final result = SpendableCalculator.validateExpense(
          amount: 500,
          currentSpendable: 2000,
        );
        expect(result.isValid, isTrue);
        expect(result.isWarning, isFalse);
      });

      test('returns warning for amount exceeding spendable', () {
        final result = SpendableCalculator.validateExpense(
          amount: 3000,
          currentSpendable: 2000,
        );
        expect(result.isValid, isTrue); // Still valid — overspend allowed
        expect(result.isWarning, isTrue);
        expect(result.message, contains('1000')); // 3000 - 2000
      });

      test('returns invalid for zero amount', () {
        final result = SpendableCalculator.validateExpense(
          amount: 0,
          currentSpendable: 2000,
        );
        expect(result.isValid, isFalse);
        expect(result.message, contains('greater than'));
      });

      test('returns invalid for negative amount', () {
        final result = SpendableCalculator.validateExpense(
          amount: -100,
          currentSpendable: 2000,
        );
        expect(result.isValid, isFalse);
      });

      test('returns valid for amount exactly equal to spendable', () {
        final result = SpendableCalculator.validateExpense(
          amount: 2000,
          currentSpendable: 2000,
        );
        expect(result.isValid, isTrue);
        expect(result.isWarning, isFalse);
      });
    });

    // ---------------------------------------------------------------------------
    // validateFundState
    // ---------------------------------------------------------------------------
    group('validateFundState', () {
      test('returns valid for legitimate principal/locked pair', () {
        final result = SpendableCalculator.validateFundState(
          principal: 8000,
          locked: 6000,
        );
        expect(result.isValid, isTrue);
      });

      test('returns invalid when locked exceeds principal', () {
        final result = SpendableCalculator.validateFundState(
          principal: 5000,
          locked: 7000,
        );
        expect(result.isValid, isFalse);
        expect(result.message, contains('cannot exceed'));
      });

      test('returns invalid for negative principal', () {
        final result = SpendableCalculator.validateFundState(
          principal: -1000,
          locked: 0,
        );
        expect(result.isValid, isFalse);
        expect(result.message, contains('negative'));
      });

      test('returns invalid for negative locked', () {
        final result = SpendableCalculator.validateFundState(
          principal: 5000,
          locked: -500,
        );
        expect(result.isValid, isFalse);
        expect(result.message, contains('negative'));
      });

      test('returns valid when both are zero', () {
        final result = SpendableCalculator.validateFundState(
          principal: 0,
          locked: 0,
        );
        expect(result.isValid, isTrue);
      });

      test('returns valid when locked equals principal', () {
        final result = SpendableCalculator.validateFundState(
          principal: 5000,
          locked: 5000,
        );
        expect(result.isValid, isTrue);
      });
    });

    // ---------------------------------------------------------------------------
    // totalSpent
    // ---------------------------------------------------------------------------
    group('totalSpent', () {
      test('sums a list of amounts correctly', () {
        expect(
          SpendableCalculator.totalSpent([500, 200, 300]),
          equals(1000),
        );
      });

      test('returns 0 for empty list', () {
        expect(SpendableCalculator.totalSpent([]), equals(0));
      });

      test('handles decimal amounts', () {
        expect(
          SpendableCalculator.totalSpent([100.50, 200.75]),
          closeTo(301.25, 0.001),
        );
      });
    });

    // ---------------------------------------------------------------------------
    // applyExpenseToFundState
    // ---------------------------------------------------------------------------
    group('applyExpenseToFundState', () {
      test('reduces principal by expense amount', () {
        final state = FundState(
          principalAmount: 8000,
          lockedAmount: 6000,
          lastUpdated: DateTime.now(),
        );
        final newState = SpendableCalculator.applyExpenseToFundState(
          state: state,
          expenseAmount: 500,
        );
        expect(newState.principalAmount, equals(7500));
        expect(newState.lockedAmount, equals(6000)); // Unchanged
        expect(newState.spendableAmount, equals(1500));
      });

      test('locked amount is never affected', () {
        final state = FundState(
          principalAmount: 10000,
          lockedAmount: 8000,
          lastUpdated: DateTime.now(),
        );
        final newState = SpendableCalculator.applyExpenseToFundState(
          state: state,
          expenseAmount: 300,
        );
        expect(newState.lockedAmount, equals(8000));
      });
    });

    // ---------------------------------------------------------------------------
    // afterExpense
    // ---------------------------------------------------------------------------
    group('afterExpense', () {
      test('deducts expense from spendable', () {
        expect(
          SpendableCalculator.afterExpense(
            currentSpendable: 2000,
            expenseAmount: 500,
          ),
          equals(1500),
        );
      });

      test('allows going negative (overspend)', () {
        expect(
          SpendableCalculator.afterExpense(
            currentSpendable: 200,
            expenseAmount: 500,
          ),
          equals(-300),
        );
      });
    });
  });

  // ---------------------------------------------------------------------------
  // FundState model
  // ---------------------------------------------------------------------------
  group('FundState', () {
    test('computes spendableAmount correctly', () {
      final state = FundState(
        principalAmount: 8000,
        lockedAmount: 6000,
        lastUpdated: DateTime.now(),
      );
      expect(state.spendableAmount, equals(2000));
    });

    test('isOverspent is true when spendable is negative', () {
      final state = FundState(
        principalAmount: 4000,
        lockedAmount: 6000,
        lastUpdated: DateTime.now(),
      );
      expect(state.isOverspent, isTrue);
    });

    test('isOverspent is false when spendable is zero', () {
      final state = FundState(
        principalAmount: 5000,
        lockedAmount: 5000,
        lastUpdated: DateTime.now(),
      );
      expect(state.isOverspent, isFalse);
    });

    test('copyWith updates only specified fields', () {
      final state = FundState(
        principalAmount: 8000,
        lockedAmount: 6000,
        lastUpdated: DateTime(2026, 1, 1),
      );
      final updated = state.copyWith(principalAmount: 9000);
      expect(updated.principalAmount, equals(9000));
      expect(updated.lockedAmount, equals(6000)); // Unchanged
    });

    test('Firestore serialization round-trip', () {
      final now = DateTime(2026, 7, 15, 12, 0, 0);
      final state = FundState(
        principalAmount: 8000,
        lockedAmount: 6000,
        lastUpdated: now,
      );
      final map = state.toFirestore();
      final restored = FundState.fromFirestore(map);

      expect(restored.principalAmount, equals(state.principalAmount));
      expect(restored.lockedAmount, equals(state.lockedAmount));
      expect(restored.spendableAmount, equals(state.spendableAmount));
    });
  });
}
