import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/fund_state_repository.dart';
import '../../data/repositories/ledger_repository.dart';
import '../../domain/models/fund_state.dart';
import '../../domain/models/ledger_entry.dart';
import '../../domain/logic/spendable_calculator.dart';

// ---------------------------------------------------------------------------
// Ledger pagination state
// ---------------------------------------------------------------------------
class LedgerState {
  const LedgerState({
    this.entries = const [],
    this.lastDoc,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  final List<LedgerEntry> entries;
  final QueryDocumentSnapshot? lastDoc;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  LedgerState copyWith({
    List<LedgerEntry>? entries,
    QueryDocumentSnapshot? lastDoc,
    bool? isLoading,
    bool? hasMore,
    String? error,
    bool clearError = false,
    bool clearLastDoc = false,
  }) {
    return LedgerState(
      entries: entries ?? this.entries,
      lastDoc: clearLastDoc ? null : (lastDoc ?? this.lastDoc),
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Ledger notifier
// ---------------------------------------------------------------------------
class LedgerNotifier extends StateNotifier<LedgerState> {
  LedgerNotifier(this._repo, this._fundStateRepo) : super(const LedgerState());

  final LedgerRepository _repo;
  final FundStateRepository _fundStateRepo;

  /// Load first page
  Future<void> loadFirstPage() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await _repo.fetchFirstPageWithDocs();
      state = LedgerState(
        entries: results.map((r) => r.entry).toList(),
        lastDoc: results.isNotEmpty ? results.last.doc : null,
        hasMore: results.length >= 20,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load next page (append)
  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore || state.lastDoc == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.fetchNextPage(state.lastDoc!);
      state = state.copyWith(
        entries: [...state.entries, ...result.entries],
        lastDoc: result.lastDoc,
        hasMore: result.entries.length >= 20,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Add expense — optimistically updates UI, then commits to Firestore
  Future<void> addExpense({
    required FundState currentState,
    required double amount,
    String? note,
    String? category,
    DateTime? timestamp,
  }) async {
    try {
      await _repo.addExpense(
        currentState: currentState,
        amount: amount,
        note: note,
        category: category,
        timestamp: timestamp,
      );
      // Reload first page to reflect new entry
      await loadFirstPage();
    } catch (e) {
      state = state.copyWith(error: 'Failed to add expense: ${e.toString()}');
      rethrow;
    }
  }

  /// Delete entry
  Future<void> deleteEntry(LedgerEntry entry) async {
    final fundState = await _fundStateRepo.getFundState();
    if (fundState == null) return;
    try {
      await _repo.deleteEntry(entry: entry, currentState: fundState);
      state = state.copyWith(
        entries: state.entries.where((e) => e.id != entry.id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete: ${e.toString()}');
      rethrow;
    }
  }

  /// Update expense
  Future<void> updateExpense({
    required LedgerEntry original,
    required double newAmount,
    String? newNote,
    String? newCategory,
    DateTime? newTimestamp,
  }) async {
    final fundState = await _fundStateRepo.getFundState();
    if (fundState == null) return;
    try {
      await _repo.updateExpense(
        originalEntry: original,
        currentState: fundState,
        newAmount: newAmount,
        newNote: newNote,
        newCategory: newCategory,
        newTimestamp: newTimestamp,
      );
      await loadFirstPage();
    } catch (e) {
      state = state.copyWith(error: 'Failed to update: ${e.toString()}');
      rethrow;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ---------------------------------------------------------------------------
// Monthly summary state
// ---------------------------------------------------------------------------
class MonthlySummaryState {
  const MonthlySummaryState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
  });

  final List<LedgerEntry> entries;
  final bool isLoading;
  final String? error;

  double get totalSpent => SpendableCalculator.totalSpent(
        entries.where((e) => e.isExpense).map((e) => e.amount).toList(),
      );

  List<LedgerEntry> get expensesOnly =>
      entries.where((e) => e.isExpense).toList();

  /// Group expenses by category value
  Map<String, double> get byCategory {
    final map = <String, double>{};
    for (final e in expensesOnly) {
      final key = e.category?.value ?? 'other';
      map[key] = (map[key] ?? 0) + e.amount;
    }
    return map;
  }

  /// Group expenses by day (ISO date string)
  Map<String, double> get byDay {
    final map = <String, double>{};
    for (final e in expensesOnly) {
      final key =
          '${e.timestamp.year}-${e.timestamp.month.toString().padLeft(2, '0')}-${e.timestamp.day.toString().padLeft(2, '0')}';
      map[key] = (map[key] ?? 0) + e.amount;
    }
    return map;
  }
}

class MonthlySummaryNotifier extends StateNotifier<MonthlySummaryState> {
  MonthlySummaryNotifier(this._repo) : super(const MonthlySummaryState());

  final LedgerRepository _repo;

  Future<void> load() async {
    state = const MonthlySummaryState(isLoading: true);
    try {
      final entries = await _repo.fetchThisMonthEntries();
      state = MonthlySummaryState(entries: entries);
    } catch (e) {
      state = MonthlySummaryState(error: e.toString());
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------
final ledgerProvider =
    StateNotifierProvider<LedgerNotifier, LedgerState>((ref) {
  return LedgerNotifier(
    ref.watch(ledgerRepositoryProvider),
    ref.watch(fundStateRepositoryProvider),
  );
});

final monthlySummaryProvider =
    StateNotifierProvider<MonthlySummaryNotifier, MonthlySummaryState>((ref) {
  return MonthlySummaryNotifier(ref.watch(ledgerRepositoryProvider));
});
