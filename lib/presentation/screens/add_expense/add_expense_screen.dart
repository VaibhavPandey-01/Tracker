import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../widgets/neumorphic.dart';
import '../../../domain/models/transaction.dart';
import '../../../core/utils/formatters.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final bool isTab;

  const AddExpenseScreen({super.key, this.isTab = false});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _amountController = TextEditingController(text: '0');
  final _noteController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedAccountId;
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0;

  void _save() {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
      return;
    }

    final notifier = ref.read(transactionsProvider.notifier);
    notifier.add(Transaction(
      id: notifier.generateId(),
      accountId: _selectedAccountId!,
      categoryId: _selectedCategoryId!,
      amount: _amount,
      note: _noteController.text.trim(),
      date: DateTime.now(),
      isRecurring: _isRecurring,
    ));

    // Reset fields
    _amountController.text = '0';
    _noteController.clear();
    setState(() {
      _isRecurring = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense added!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final categories = ref.watch(categoriesProvider);
    final accounts = ref.watch(accountsProvider);
    final totalSpendable = ref.watch(totalSpendableProvider);

    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }
    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    final spendablePercent = totalSpendable > 0 ? (_amount / totalSpendable) : 0.0;

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
                    onTap: () {
                      if (widget.isTab) {
                        // Switch to Home tab
                        // For simplicity, do nothing or show snackbar
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: Color(0xFFB8B8C0),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Add Expense',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF5F5F7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40), // Balance header center
                ],
              ),

              const SizedBox(height: 24),

              // ── Inset Numeric Amount Input ──────────────────────────────────
              Text(
                'AMOUNT',
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              NeumorphicContainer(
                isInset: true,
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: tt.displaySmall?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    prefixText: '₹ ',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Rainbow circular gauge ──────────────────────────────────────
              Center(
                child: RainbowGauge(
                  percentage: spendablePercent,
                  centerWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formatCurrency(_amount),
                        style: tt.titleLarge?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFF5F5F7),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(spendablePercent * 100).toStringAsFixed(1)}% of fund',
                        style: tt.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Categories Row ──────────────────────────────────────────────
              Text(
                'CATEGORY',
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: categories.length,
                  itemBuilder: (context, i) {
                    final cat = categories[i];
                    final isSelected = cat.id == _selectedCategoryId;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          NeumorphicContainer(
                            width: 50,
                            height: 50,
                            borderRadius: 25,
                            isInset: isSelected,
                            onTap: () => setState(() => _selectedCategoryId = cat.id),
                            child: Icon(
                              cat.icon,
                              size: 18,
                              color: isSelected ? const Color(0xFFF5F5F7) : const Color(0xFF8A8A93),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat.name.split(' ').first,
                            style: tt.labelSmall?.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ── Account Selector Toggle Row ────────────────────────────────
              Text(
                'ACCOUNT',
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: accounts.map((acc) {
                  final isSelected = acc.id == _selectedAccountId;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: NeumorphicContainer(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        borderRadius: 16,
                        isInset: isSelected,
                        onTap: () => setState(() => _selectedAccountId = acc.id),
                        child: Center(
                          child: Text(
                            acc.name,
                            style: tt.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? const Color(0xFFF5F5F7) : const Color(0xFF8A8A93),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // ── Recurring Switch & Note Field ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recurring Payment',
                        style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      Text(
                        'Save as automated rule',
                        style: tt.labelSmall,
                      ),
                    ],
                  ),
                  NeumorphicSwitch(
                    value: _isRecurring,
                    onChanged: (v) => setState(() => _isRecurring = v),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              NeumorphicTextField(
                labelText: 'Note / Memo',
                hintText: 'e.g. Starbucks coffee',
                controller: _noteController,
              ),

              const SizedBox(height: 40),

              // ── Confirm/Save Button ────────────────────────────────────────
              Center(
                child: NeumorphicContainer(
                  width: 68,
                  height: 68,
                  borderRadius: 34,
                  onTap: _save,
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFFF5F5F7),
                    size: 28,
                  ),
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
