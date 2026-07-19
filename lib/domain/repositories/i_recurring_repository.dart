import '../models/recurring_rule.dart';

abstract class IRecurringRepository {
  List<RecurringRule> getAll();
  void add(RecurringRule rule);
  void update(RecurringRule rule);
  void delete(String id);
}
