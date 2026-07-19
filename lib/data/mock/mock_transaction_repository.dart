import '../../domain/models/transaction.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import 'seed_data.dart';

class MockTransactionRepository implements ITransactionRepository {
  final List<Transaction> _transactions = List.from(seedTransactions);

  @override
  List<Transaction> getAll() {
    final list = List<Transaction>.from(_transactions);
    list.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(list);
  }

  @override
  void add(Transaction transaction) => _transactions.add(transaction);

  @override
  void update(Transaction transaction) {
    final i = _transactions.indexWhere((t) => t.id == transaction.id);
    if (i != -1) _transactions[i] = transaction;
  }

  @override
  void delete(String id) => _transactions.removeWhere((t) => t.id == id);
}
