import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/fund_state.dart';
import '../datasources/firestore_datasource.dart';

/// Repository for FundState CRUD — delegates to FirestoreDatasource.
class FundStateRepository {
  const FundStateRepository(this._datasource);

  final FirestoreDatasource _datasource;

  Stream<FundState?> watchFundState() => _datasource.watchFundState();
  Future<FundState?> getFundState() => _datasource.getFundState();

  Future<void> initializeFundState({
    required double principal,
    required double locked,
    String? note,
  }) =>
      _datasource.initializeFundState(
        principal: principal,
        locked: locked,
        note: note,
      );

  Future<void> updateFundState({
    required FundState currentState,
    required double newPrincipal,
    required double newLocked,
    String? note,
  }) =>
      _datasource.updateFundState(
        currentState: currentState,
        newPrincipal: newPrincipal,
        newLocked: newLocked,
        note: note,
      );
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final fundStateRepositoryProvider = Provider<FundStateRepository>((ref) {
  return FundStateRepository(ref.watch(firestoreDatasourceProvider));
});

/// Stream provider — live fund state from Firestore
final fundStateStreamProvider = StreamProvider<FundState?>((ref) {
  return ref.watch(fundStateRepositoryProvider).watchFundState();
});
