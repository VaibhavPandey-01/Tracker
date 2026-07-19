import '../models/account.dart';

abstract class IAccountRepository {
  List<Account> getAll();
  void add(Account account);
  void update(Account account);
  void delete(String id);
}
