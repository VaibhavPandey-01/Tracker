import '../../domain/models/recurring_rule.dart';
import '../../domain/repositories/i_recurring_repository.dart';
import 'seed_data.dart';

class MockRecurringRepository implements IRecurringRepository {
  final List<RecurringRule> _rules = List.from(seedRecurringRules);

  @override
  List<RecurringRule> getAll() => List.unmodifiable(_rules);

  @override
  void add(RecurringRule rule) => _rules.add(rule);

  @override
  void update(RecurringRule rule) {
    final i = _rules.indexWhere((r) => r.id == rule.id);
    if (i != -1) _rules[i] = rule;
  }

  @override
  void delete(String id) => _rules.removeWhere((r) => r.id == id);
}
