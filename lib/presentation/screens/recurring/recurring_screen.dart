import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../widgets/neumorphic.dart';
import '../../widgets/empty_state.dart';
import '../../../domain/models/recurring_rule.dart';
import '../../../core/utils/formatters.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  void _showAddRuleSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddRuleSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final rules = ref.watch(recurringProvider);
    final categories = ref.watch(categoriesProvider);
    final categoryMap = {for (final c in categories) c.id: c};

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Row(
                children: [
                  NeumorphicContainer(
                    width: 40,
                    height: 40,
                    borderRadius: 20,
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: Color(0xFFB8B8C0),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Recurring Rules',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF5F5F7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 32),

              if (rules.isEmpty) ...[
                const NeumorphicEmptyState(
                  icon: Icons.repeat,
                  text: 'No automated recurring transactions set up.\nTap Add Recurring Rule below to schedule payments.',
                ),
              ] else ...[
                // ── Rules List ────────────────────────────────────────────────
                ...rules.map((rule) {
                  final cat = categoryMap[rule.categoryId];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: NeumorphicContainer(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          NeumorphicContainer(
                            width: 42,
                            height: 42,
                            borderRadius: 21,
                            child: Icon(cat?.icon ?? Icons.repeat, size: 18, color: const Color(0xFFB8B8C0)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rule.note,
                                  style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    NeumorphicContainer(
                                      isInset: true,
                                      borderRadius: 6,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Text(
                                        rule.frequency.label,
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF8A8A93), fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Due: ${formatShortDate(rule.nextDate)}',
                                      style: tt.labelSmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatCurrency(rule.amount),
                                style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 15),
                              ),
                              const SizedBox(height: 8),
                              NeumorphicSwitch(
                                value: rule.isActive,
                                onChanged: (v) {
                                  ref.read(recurringProvider.notifier).toggleActive(rule.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],

              const SizedBox(height: 16),

              // ── Add Recurring Rule Button ─────────────────────────────────
              NeumorphicContainer(
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(vertical: 20),
                onTap: () => _showAddRuleSheet(context, ref),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Color(0xFFB8B8C0), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Add Recurring Rule',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF5F5F7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddRuleSheet extends ConsumerStatefulWidget {
  const _AddRuleSheet();

  @override
  ConsumerState<_AddRuleSheet> createState() => _AddRuleSheetState();
}

class _AddRuleSheetState extends ConsumerState<_AddRuleSheet> {
  final _noteController = TextEditingController();
  final _amountController = TextEditingController(text: '0');
  String? _selectedAccountId;
  String? _selectedCategoryId;
  RecurringFrequency _frequency = RecurringFrequency.monthly;

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final note = _noteController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (note.isEmpty || amount <= 0 || _selectedAccountId == null || _selectedCategoryId == null) return;

    final notifier = ref.read(recurringProvider.notifier);
    notifier.add(RecurringRule(
      id: notifier.generateId(),
      accountId: _selectedAccountId!,
      categoryId: _selectedCategoryId!,
      amount: amount,
      note: note,
      frequency: _frequency,
      nextDate: DateTime.now().add(const Duration(days: 30)),
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final accounts = ref.watch(accountsProvider);
    final categories = ref.watch(categoriesProvider);

    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }
    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New Recurring Rule',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          NeumorphicTextField(
            labelText: 'Description',
            hintText: 'e.g. Gym Membership',
            controller: _noteController,
          ),
          const SizedBox(height: 16),
          NeumorphicTextField(
            labelText: 'Amount (₹)',
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          Text(
            'Frequency',
            style: tt.labelMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: RecurringFrequency.values.map((freq) {
              final isSelected = _frequency == freq;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: NeumorphicContainer(
                    borderRadius: 10,
                    isInset: isSelected,
                    onTap: () => setState(() => _frequency = freq),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                      child: Text(
                        freq.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFFF5F5F7) : const Color(0xFF8A8A93),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          NeumorphicButton(
            onTap: _save,
            child: const Text(
              'Save Rule',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
