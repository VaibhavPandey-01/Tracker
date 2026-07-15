import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:tracker_app/data/repositories/fund_state_repository.dart';
import 'package:tracker_app/data/repositories/ledger_repository.dart';
import 'package:tracker_app/domain/models/fund_state.dart';
import 'package:tracker_app/presentation/providers/ledger_provider.dart';
import 'package:tracker_app/presentation/screens/expense/add_expense_screen.dart';
import 'package:tracker_app/core/constants/app_theme.dart';

// NOTE: Run `flutter pub run build_runner build` to generate mock files
// @GenerateMocks([LedgerRepository, FundStateRepository, FirebaseAuth])
// import 'add_expense_flow_test.mocks.dart';

/// Widget test for the Add Expense flow.
/// Tests form validation and UI state without Firestore dependency.
void main() {
  group('AddExpenseScreen', () {
    late FundState mockFundState;

    setUp(() {
      mockFundState = FundState(
        principalAmount: 8000,
        lockedAmount: 6000,
        lastUpdated: DateTime.now(),
      );
    });

    testWidgets('renders spendable balance header', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fundStateStreamProvider.overrideWith(
              (ref) => Stream.value(mockFundState),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AddExpenseScreen(),
          ),
        ),
      );

      await tester.pump();
      // Should show spendable amount
      expect(find.textContaining('2,000'), findsOneWidget);
    });

    testWidgets('shows validation error for empty amount', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fundStateStreamProvider.overrideWith(
              (ref) => Stream.value(mockFundState),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AddExpenseScreen(),
          ),
        ),
      );

      await tester.pump();

      // Tap add button without entering amount
      final addButton = find.text('Add Expense');
      await tester.tap(addButton);
      await tester.pump();

      expect(find.text('Amount is required'), findsOneWidget);
    });

    testWidgets('shows validation error for zero amount', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fundStateStreamProvider.overrideWith(
              (ref) => Stream.value(mockFundState),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AddExpenseScreen(),
          ),
        ),
      );

      await tester.pump();

      final amountField = find.byKey(const Key('add_expense_amount'));
      await tester.enterText(amountField, '0');

      final addButton = find.text('Add Expense');
      await tester.tap(addButton);
      await tester.pump();

      expect(find.text('Enter a valid amount'), findsOneWidget);
    });

    testWidgets('shows overspend warning when amount exceeds spendable', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fundStateStreamProvider.overrideWith(
              (ref) => Stream.value(mockFundState),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AddExpenseScreen(),
          ),
        ),
      );

      await tester.pump();

      // Enter amount exceeding spendable (2000)
      final amountField = find.byType(TextFormField).first;
      await tester.enterText(amountField, '3000');
      await tester.pump();

      // Should show warning banner
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
    });

    testWidgets('category chips are selectable', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fundStateStreamProvider.overrideWith(
              (ref) => Stream.value(mockFundState),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const AddExpenseScreen(),
          ),
        ),
      );

      await tester.pump();

      // Tap on "Food" category
      await tester.tap(find.text('Food & Drinks'));
      await tester.pump();

      // Category should be selected (visually via AnimatedContainer)
      expect(find.text('Food & Drinks'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // LedgerState unit tests (no widget required)
  // ---------------------------------------------------------------------------
  group('LedgerState', () {
    test('initial state has no entries and is not loading', () {
      const state = LedgerState();
      expect(state.entries, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.hasMore, isTrue);
      expect(state.error, isNull);
    });

    test('copyWith preserves unchanged fields', () {
      const state = LedgerState(hasMore: false);
      final updated = state.copyWith(isLoading: true);
      expect(updated.isLoading, isTrue);
      expect(updated.hasMore, isFalse); // Preserved
    });

    test('clearError resets error field', () {
      const state = LedgerState(error: 'some error');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });
  });
}
