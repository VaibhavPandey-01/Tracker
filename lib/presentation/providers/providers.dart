import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/mock/mock_account_repository.dart';
import '../../data/mock/mock_category_repository.dart';
import '../../data/mock/mock_transaction_repository.dart';
import '../../data/mock/mock_recurring_repository.dart';
import '../../domain/models/account.dart';
import '../../domain/models/category.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/recurring_rule.dart';
import '../../domain/repositories/i_account_repository.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../../domain/repositories/i_recurring_repository.dart';

const _uuid = Uuid();

// ─── Repository Providers ───────────────────────────────────────────────────

final accountRepositoryProvider = Provider<IAccountRepository>(
  (ref) => MockAccountRepository(),
);

final categoryRepositoryProvider = Provider<ICategoryRepository>(
  (ref) => MockCategoryRepository(),
);

final transactionRepositoryProvider = Provider<ITransactionRepository>(
  (ref) => MockTransactionRepository(),
);

final recurringRepositoryProvider = Provider<IRecurringRepository>(
  (ref) => MockRecurringRepository(),
);

// ─── Onboarding State ────────────────────────────────────────────────────────

final isOnboardedProvider = StateProvider<bool>((ref) => false);

// ─── Theme Provider (Dark mode locked) ───────────────────────────────────────

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

// ─── Accounts ────────────────────────────────────────────────────────────────

class AccountsNotifier extends StateNotifier<List<Account>> {
  final IAccountRepository _repo;

  AccountsNotifier(this._repo) : super(_repo.getAll());

  void add(Account account) {
    _repo.add(account);
    state = _repo.getAll();
  }

  void update(Account account) {
    _repo.update(account);
    state = _repo.getAll();
  }

  void delete(String id) {
    _repo.delete(id);
    state = _repo.getAll();
  }

  String generateId() => _uuid.v4();
}

final accountsProvider =
    StateNotifierProvider<AccountsNotifier, List<Account>>((ref) {
  return AccountsNotifier(ref.watch(accountRepositoryProvider));
});

// ─── Categories ──────────────────────────────────────────────────────────────

class CategoriesNotifier extends StateNotifier<List<Category>> {
  final ICategoryRepository _repo;

  CategoriesNotifier(this._repo) : super(_repo.getAll());

  void add(Category category) {
    _repo.add(category);
    state = _repo.getAll();
  }

  void update(Category category) {
    _repo.update(category);
    state = _repo.getAll();
  }

  void delete(String id) {
    _repo.delete(id);
    state = _repo.getAll();
  }

  String generateId() => _uuid.v4();
}

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
  return CategoriesNotifier(ref.watch(categoryRepositoryProvider));
});

// ─── Transactions ────────────────────────────────────────────────────────────

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  final ITransactionRepository _repo;

  TransactionsNotifier(this._repo) : super(_repo.getAll());

  void add(Transaction transaction) {
    _repo.add(transaction);
    state = _repo.getAll();
  }

  void update(Transaction transaction) {
    _repo.update(transaction);
    state = _repo.getAll();
  }

  void delete(String id) {
    _repo.delete(id);
    state = _repo.getAll();
  }

  String generateId() => _uuid.v4();
}

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
  return TransactionsNotifier(ref.watch(transactionRepositoryProvider));
});

// ─── Recurring Rules ─────────────────────────────────────────────────────────

class RecurringNotifier extends StateNotifier<List<RecurringRule>> {
  final IRecurringRepository _repo;

  RecurringNotifier(this._repo) : super(_repo.getAll());

  void add(RecurringRule rule) {
    _repo.add(rule);
    state = _repo.getAll();
  }

  void update(RecurringRule rule) {
    _repo.update(rule);
    state = _repo.getAll();
  }

  void delete(String id) {
    _repo.delete(id);
    state = _repo.getAll();
  }

  void toggleActive(String id) {
    final rule = state.firstWhere((r) => r.id == id);
    update(rule.copyWith(isActive: !rule.isActive));
  }

  String generateId() => _uuid.v4();
}

final recurringProvider =
    StateNotifierProvider<RecurringNotifier, List<RecurringRule>>((ref) {
  return RecurringNotifier(ref.watch(recurringRepositoryProvider));
});

// ─── Computed / Derived Providers ────────────────────────────────────────────

final totalSpendableProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts.fold(0.0, (sum, a) => sum + a.spendableAmount);
});

final totalPrincipalProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts.fold(0.0, (sum, a) => sum + a.principalAmount);
});

final totalLockedProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts.fold(0.0, (sum, a) => sum + a.lockedAmount);
});

final thisMonthSpendProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final now = DateTime.now();
  return transactions
      .where((t) => t.date.year == now.year && t.date.month == now.month)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final spendByCategoryProvider =
    Provider.family<Map<String, double>, DateTime>((ref, month) {
  final transactions = ref.watch(transactionsProvider);
  final map = <String, double>{};
  for (final t in transactions) {
    if (t.date.year == month.year && t.date.month == month.month) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
  }
  return map;
});

final spendPerDayProvider =
    Provider.family<Map<int, double>, DateTime>((ref, month) {
  final transactions = ref.watch(transactionsProvider);
  final map = <int, double>{};
  for (final t in transactions) {
    if (t.date.year == month.year && t.date.month == month.month) {
      map[t.date.day] = (map[t.date.day] ?? 0) + t.amount;
    }
  }
  return map;
});
