import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/fund_state.dart';
import '../../domain/models/ledger_entry.dart';
import '../datasources/firestore_datasource.dart';

/// Repository for ledger CRUD with pagination support.
class LedgerRepository {
  const LedgerRepository(this._datasource);

  final FirestoreDatasource _datasource;

  Future<void> addExpense({
    required FundState currentState,
    required double amount,
    String? note,
    String? category,
    DateTime? timestamp,
  }) =>
      _datasource.addExpense(
        currentState: currentState,
        amount: amount,
        note: note,
        category: category,
        timestamp: timestamp,
      );

  Future<void> deleteEntry({
    required LedgerEntry entry,
    required FundState currentState,
  }) =>
      _datasource.deleteEntry(
        entry: entry,
        currentState: currentState,
      );

  Future<void> updateExpense({
    required LedgerEntry originalEntry,
    required FundState currentState,
    required double newAmount,
    String? newNote,
    String? newCategory,
    DateTime? newTimestamp,
  }) =>
      _datasource.updateExpense(
        originalEntry: originalEntry,
        currentState: currentState,
        newAmount: newAmount,
        newNote: newNote,
        newCategory: newCategory,
        newTimestamp: newTimestamp,
      );

  /// Fetch first page of ledger entries
  Future<List<LedgerEntry>> fetchFirstPage() async {
    final snap = await _datasource.ledgerQuery.get();
    return snap.docs
        .map((d) => LedgerEntry.fromFirestore(d.id, d.data()))
        .toList();
  }

  /// Fetch next page starting after the given document snapshot
  Future<({List<LedgerEntry> entries, QueryDocumentSnapshot? lastDoc})>
      fetchNextPage(QueryDocumentSnapshot lastDoc) async {
    final snap = await _datasource.ledgerQueryAfter(lastDoc).get();
    return (
      entries: snap.docs
          .map((d) => LedgerEntry.fromFirestore(d.id, d.data()))
          .toList(),
      lastDoc: snap.docs.isNotEmpty ? snap.docs.last : null,
    );
  }

  /// Raw query reference for initial page (for raw document snapshots)
  Future<List<({LedgerEntry entry, QueryDocumentSnapshot doc})>>
      fetchFirstPageWithDocs() async {
    final snap = await _datasource.ledgerQuery.get();
    return snap.docs
        .map((d) => (
              entry: LedgerEntry.fromFirestore(d.id, d.data()),
              doc: d,
            ))
        .toList();
  }

  /// This month's expenses for summary
  Future<List<LedgerEntry>> fetchThisMonthEntries() async {
    final snap = await _datasource.ledgerThisMonth().get();
    return snap.docs
        .map((d) => LedgerEntry.fromFirestore(d.id, d.data()))
        .toList();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  return LedgerRepository(ref.watch(firestoreDatasourceProvider));
});
