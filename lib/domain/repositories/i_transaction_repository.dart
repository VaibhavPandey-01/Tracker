import '../models/transaction.dart';

abstract class ITransactionRepository {
  List<Transaction> getAll();
  void add(Transaction transaction);
  void update(Transaction transaction);
  void delete(String id);
}
