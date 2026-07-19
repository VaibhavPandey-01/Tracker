import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/neumorphic.dart';
import '../../providers/providers.dart';
import '../../../domain/models/transaction.dart';
import 'package:uuid/uuid.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedAccountId;
  String? _selectedCategoryId;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || _selectedAccountId == null || _selectedCategoryId == null) {
      // Show some error indication
      return;
    }

    final newTxn = Transaction(
      id: const Uuid().v4(),
      accountId: _selectedAccountId!,
      categoryId: _selectedCategoryId!,
      amount: amount,
      note: _noteController.text.isNotEmpty ? _noteController.text : 'New Expense',
      date: DateTime.now(),
    );

    ref.read(transactionsProvider.notifier).add(newTxn);
    
    // Also deduct from account balance for demo
    final accounts = ref.read(accountsProvider);
    final account = accounts.firstWhere((a) => a.id == _selectedAccountId);
    final updatedAccount = account.copyWith(
      principalAmount: account.principalAmount - amount,
    );
    ref.read(accountsProvider.notifier).updateAccount(updatedAccount);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final categories = ref.watch(categoriesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.baseColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Add Expense',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              NeumorphicTextField(
                labelText: 'Amount',
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                hintText: '0.00',
              ),
              const SizedBox(height: 16),
              NeumorphicTextField(
                labelText: 'Note',
                controller: _noteController,
                hintText: 'What was this for?',
              ),
              const SizedBox(height: 24),
              Text(
                'Account',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    final isSelected = _selectedAccountId == account.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedAccountId = account.id),
                        child: NeumorphicContainer(
                          isInset: isSelected,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          borderRadius: 16,
                          child: Center(
                            child: Text(
                              account.name,
                              style: TextStyle(
                                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Category',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = _selectedCategoryId == cat.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategoryId = cat.id),
                        child: NeumorphicContainer(
                          isInset: isSelected,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          borderRadius: 16,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(cat.icon, size: 16, color: isSelected ? cat.color : AppTheme.textSecondary),
                              const SizedBox(width: 8),
                              Text(
                                cat.name,
                                style: TextStyle(
                                  color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              NeumorphicButton(
                onTap: _saveExpense,
                width: double.infinity,
                child: const Text(
                  'Save Expense',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
