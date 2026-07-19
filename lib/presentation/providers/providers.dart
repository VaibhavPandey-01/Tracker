import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock/mock_account_repository.dart';
import '../../data/mock/mock_category_repository.dart';
import '../../data/mock/mock_transaction_repository.dart';
import '../../data/mock/mock_recurring_repository.dart';
import '../../domain/models/account.dart';
import '../../domain/models/category.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/recurring_rule.dart';

// Repositories
final accountRepositoryProvider = Provider((ref) => MockAccountRepository());
final categoryRepositoryProvider = Provider((ref) => MockCategoryRepository());
final transactionRepositoryProvider = Provider((ref) => MockTransactionRepository());
final recurringRepositoryProvider = Provider((ref) => MockRecurringRepository());

// State Notifiers
class AccountsNotifier extends StateNotifier<List<Account>> {
  final MockAccountRepository _repository;
  AccountsNotifier(this._repository) : super(_repository.getAll());

  void add(Account account) {
    _repository.add(account);
    state = _repository.getAll();
  }

  void updateAccount(Account account) {
    _repository.update(account);
    state = _repository.getAll();
  }

  void deleteAccount(String id) {
    _repository.delete(id);
    state = _repository.getAll();
  }
}

final accountsProvider = StateNotifierProvider<AccountsNotifier, List<Account>>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return AccountsNotifier(repo);
});

class CategoriesNotifier extends StateNotifier<List<Category>> {
  final MockCategoryRepository _repository;
  CategoriesNotifier(this._repository) : super(_repository.getAll());

  void add(Category category) {
    _repository.add(category);
    state = _repository.getAll();
  }

  void updateCategory(Category category) {
    _repository.update(category);
    state = _repository.getAll();
  }
}

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return CategoriesNotifier(repo);
});

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  final MockTransactionRepository _repository;
  TransactionsNotifier(this._repository) : super(_repository.getAll());

  void add(Transaction transaction) {
    _repository.add(transaction);
    state = _repository.getAll();
  }

  void updateTransaction(Transaction transaction) {
    _repository.update(transaction);
    state = _repository.getAll();
  }

  void deleteTransaction(String id) {
    _repository.delete(id);
    state = _repository.getAll();
  }
}

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return TransactionsNotifier(repo);
});

class RecurringRulesNotifier extends StateNotifier<List<RecurringRule>> {
  final MockRecurringRepository _repository;
  RecurringRulesNotifier(this._repository) : super(_repository.getAll());

  void add(RecurringRule rule) {
    _repository.add(rule);
    state = _repository.getAll();
  }

  void updateRule(RecurringRule rule) {
    _repository.update(rule);
    state = _repository.getAll();
  }

  void deleteRule(String id) {
    _repository.delete(id);
    state = _repository.getAll();
  }
}

final recurringRulesProvider = StateNotifierProvider<RecurringRulesNotifier, List<RecurringRule>>((ref) {
  final repo = ref.watch(recurringRepositoryProvider);
  return RecurringRulesNotifier(repo);
});

// Derived Providers
final totalBalanceProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts.fold(0.0, (sum, acc) => sum + acc.principalAmount);
});

final totalSafeToSpendProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts.fold(0.0, (sum, acc) => sum + (acc.principalAmount - acc.lockedAmount));
});
