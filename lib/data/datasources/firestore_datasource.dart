import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums/entry_type.dart';
import '../../domain/enums/expense_category.dart';
import '../../domain/models/fund_state.dart';
import '../../domain/models/ledger_entry.dart';
import '../../domain/logic/spendable_calculator.dart';

/// Central Firestore datasource — all read/write operations.
/// Uses atomic batch writes to prevent data corruption.
class FirestoreDatasource {
  FirestoreDatasource(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  // ---------------------------------------------------------------------------
  // Collection references
  // ---------------------------------------------------------------------------

  DocumentReference<Map<String, dynamic>> get _fundStateRef =>
      _firestore.collection('users').doc(_uid).collection('fund_state').doc('current');

  CollectionReference<Map<String, dynamic>> get _ledgerRef =>
      _firestore.collection('users').doc(_uid).collection('ledger_entries');

  // ---------------------------------------------------------------------------
  // FundState operations
  // ---------------------------------------------------------------------------

  /// Stream of the user's fund state — auto-updates on any change.
  Stream<FundState?> watchFundState() {
    return _fundStateRef.snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return FundState.fromFirestore(snap.data()!);
    });
  }

  /// One-time read — used during onboarding check.
  Future<FundState?> getFundState() async {
    final snap = await _fundStateRef.get();
    if (!snap.exists || snap.data() == null) return null;
    return FundState.fromFirestore(snap.data()!);
  }

  // ---------------------------------------------------------------------------
  // Atomic write: set initial fund state (onboarding)
  // ---------------------------------------------------------------------------
  Future<void> initializeFundState({
    required double principal,
    required double locked,
    String? note,
  }) async {
    final now = DateTime.now();
    final fundState = FundState(
      principalAmount: principal,
      lockedAmount: locked,
      lastUpdated: now,
    );

    final ledgerEntry = LedgerEntry(
      id: _ledgerRef.doc().id,
      type: EntryType.fundUpdate,
      amount: principal,
      note: note ?? 'Initial setup',
      timestamp: now,
      balanceAfter: fundState.spendableAmount,
    );

    final batch = _firestore.batch();
    batch.set(_fundStateRef, fundState.toFirestore());
    batch.set(_ledgerRef.doc(ledgerEntry.id), ledgerEntry.toFirestore());
    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // Atomic write: add expense
  // ---------------------------------------------------------------------------
  Future<void> addExpense({
    required FundState currentState,
    required double amount,
    String? note,
    String? category,
    DateTime? timestamp,
  }) async {
    final now = timestamp ?? DateTime.now();
    final newState = SpendableCalculator.applyExpenseToFundState(
      state: currentState,
      expenseAmount: amount,
    );

    final entryId = _ledgerRef.doc().id;
    final ledgerEntry = LedgerEntry(
      id: entryId,
      type: EntryType.expense,
      amount: amount,
      note: note,
      category: category != null
          ? ExpenseCategory.fromValue(category)
          : null,
      timestamp: now,
      balanceAfter: newState.spendableAmount,
    );

    final batch = _firestore.batch();
    batch.set(_fundStateRef, newState.toFirestore());
    batch.set(_ledgerRef.doc(entryId), ledgerEntry.toFirestore());
    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // Atomic write: update fund state (edit principal/locked)
  // ---------------------------------------------------------------------------
  Future<void> updateFundState({
    required FundState currentState,
    required double newPrincipal,
    required double newLocked,
    String? note,
  }) async {
    final now = DateTime.now();
    final newState = FundState(
      principalAmount: newPrincipal,
      lockedAmount: newLocked,
      lastUpdated: now,
    );

    final diff = newPrincipal - currentState.principalAmount;
    final entryId = _ledgerRef.doc().id;
    final ledgerEntry = LedgerEntry(
      id: entryId,
      type: EntryType.fundUpdate,
      amount: diff.abs(),
      note: note ?? _buildFundUpdateNote(currentState, newState),
      timestamp: now,
      balanceAfter: newState.spendableAmount,
    );

    final batch = _firestore.batch();
    batch.set(_fundStateRef, newState.toFirestore());
    batch.set(_ledgerRef.doc(entryId), ledgerEntry.toFirestore());
    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // Atomic write: delete ledger entry and recalculate fund state
  // ---------------------------------------------------------------------------
  Future<void> deleteEntry({
    required LedgerEntry entry,
    required FundState currentState,
  }) async {
    // Restore the amount to the fund state
    FundState newState;
    if (entry.isExpense) {
      // Restoring an expense: add amount back to principal
      newState = currentState.copyWith(
        principalAmount: currentState.principalAmount + entry.amount,
        lastUpdated: DateTime.now(),
      );
    } else {
      // For fund updates, recalculate from scratch isn't feasible without full history.
      // Instead: mark as deleted & adjust the difference
      newState = currentState; // Fund updates typically aren't deleted in MVP
    }

    final batch = _firestore.batch();
    batch.delete(_ledgerRef.doc(entry.id));
    if (entry.isExpense) {
      batch.set(_fundStateRef, newState.toFirestore());
    }
    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // Atomic write: update existing expense entry
  // ---------------------------------------------------------------------------
  Future<void> updateExpense({
    required LedgerEntry originalEntry,
    required FundState currentState,
    required double newAmount,
    String? newNote,
    String? newCategory,
    DateTime? newTimestamp,
  }) async {
    // Calculate the difference in amounts
    final amountDiff = newAmount - originalEntry.amount;
    final newState = currentState.copyWith(
      principalAmount: currentState.principalAmount - amountDiff,
      lastUpdated: DateTime.now(),
    );

    final updatedEntry = originalEntry.copyWith(
      amount: newAmount,
      note: newNote ?? originalEntry.note,
      category: newCategory != null
          ? ExpenseCategory.fromValue(newCategory)
          : originalEntry.category,
      timestamp: newTimestamp ?? originalEntry.timestamp,
      balanceAfter: newState.spendableAmount,
    );

    final batch = _firestore.batch();
    batch.set(_ledgerRef.doc(updatedEntry.id), updatedEntry.toFirestore());
    batch.set(_fundStateRef, newState.toFirestore());
    await batch.commit();
  }

  // ---------------------------------------------------------------------------
  // Ledger queries
  // ---------------------------------------------------------------------------

  /// Paginated query — most recent entries first.
  Query<Map<String, dynamic>> get ledgerQuery => _ledgerRef
      .orderBy('timestamp', descending: true)
      .limit(20);

  /// Paginated query starting after a given document
  Query<Map<String, dynamic>> ledgerQueryAfter(
          DocumentSnapshot lastDoc) =>
      _ledgerRef
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDoc)
          .limit(20);

  /// Entries for the current month (for monthly summary)
  Query<Map<String, dynamic>> ledgerThisMonth() {
    final start = DateTime.now();
    final monthStart = DateTime(start.year, start.month, 1).toUtc();
    return _ledgerRef
        .where('timestamp', isGreaterThanOrEqualTo: monthStart.toIso8601String())
        .orderBy('timestamp', descending: true);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  String _buildFundUpdateNote(FundState oldState, FundState newState) {
    final diffPrincipal = newState.principalAmount - oldState.principalAmount;
    final diffLocked = newState.lockedAmount - oldState.lockedAmount;
    final parts = <String>[];
    if (diffPrincipal != 0) {
      final sign = diffPrincipal > 0 ? '+' : '';
      parts.add('Principal $sign₹${diffPrincipal.toStringAsFixed(0)}');
    }
    if (diffLocked != 0) {
      final sign = diffLocked > 0 ? '+' : '';
      parts.add('Locked $sign₹${diffLocked.toStringAsFixed(0)}');
    }
    return parts.isEmpty ? 'Fund state updated' : parts.join(', ');
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------
final firestoreDatasourceProvider = Provider<FirestoreDatasource>((ref) {
  return FirestoreDatasource(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});
