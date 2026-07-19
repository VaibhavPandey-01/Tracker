import '../../domain/models/account.dart';
import '../../domain/repositories/i_account_repository.dart';
import 'seed_data.dart';

class MockAccountRepository implements IAccountRepository {
  final List<Account> _accounts = List.from(seedAccounts);

  @override
  List<Account> getAll() => List.unmodifiable(_accounts);

  @override
  void add(Account account) => _accounts.add(account);

  @override
  void update(Account account) {
    final i = _accounts.indexWhere((a) => a.id == account.id);
    if (i != -1) _accounts[i] = account;
  }

  @override
  void delete(String id) => _accounts.removeWhere((a) => a.id == id);
}
