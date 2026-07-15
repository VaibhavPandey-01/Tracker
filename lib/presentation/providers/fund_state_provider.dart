import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/fund_state_repository.dart';
import '../../domain/models/fund_state.dart';

// ---------------------------------------------------------------------------
// Fund state operations provider (for write operations)
// ---------------------------------------------------------------------------
class FundStateNotifier extends StateNotifier<AsyncValue<void>> {
  FundStateNotifier(this._repo) : super(const AsyncValue.data(null));

  final FundStateRepository _repo;

  Future<void> initialize({
    required double principal,
    required double locked,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.initializeFundState(
        principal: principal,
        locked: locked,
        note: note,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> update({
    required FundState currentState,
    required double newPrincipal,
    required double newLocked,
    String? note,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateFundState(
        currentState: currentState,
        newPrincipal: newPrincipal,
        newLocked: newLocked,
        note: note,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  void clearError() => state = const AsyncValue.data(null);
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------
final fundStateNotifierProvider =
    StateNotifierProvider<FundStateNotifier, AsyncValue<void>>((ref) {
  return FundStateNotifier(ref.watch(fundStateRepositoryProvider));
});

/// Convenience provider — current spendable amount (null if loading)
final spendableAmountProvider = Provider<double?>((ref) {
  return ref.watch(fundStateStreamProvider).valueOrNull?.spendableAmount;
});
