import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/fund_state_repository.dart';
import '../../../domain/enums/expense_category.dart';
import '../../../domain/logic/spendable_calculator.dart';
import '../../../domain/models/fund_state.dart';
import '../../providers/ledger_provider.dart';
import 'package:flutter/services.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _warningMessage;

  late AnimationController _animController;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim =
        Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();

    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      setState(() => _warningMessage = null);
      return;
    }
    final fundState = ref.read(fundStateStreamProvider).valueOrNull;
    if (fundState == null) return;

    final validation = SpendableCalculator.validateExpense(
      amount: amount,
      currentSpendable: fundState.spendableAmount,
    );
    setState(() {
      _warningMessage = validation.isWarning ? validation.message : null;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit(FundState currentState) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);

    // Check for overspend warning and ask for confirmation
    if (_warningMessage != null) {
      final proceed = await _showOverspendDialog();
      if (proceed != true) return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(ledgerProvider.notifier).addExpense(
            currentState: currentState,
            amount: amount,
            note: _noteController.text.isEmpty ? null : _noteController.text,
            category: _selectedCategory.value,
            timestamp: _selectedDate,
          );

      // Haptic feedback
      HapticFeedback.mediumImpact();

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add expense: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showOverspendDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Overspending Warning'),
        content: Text(_warningMessage ?? 'This exceeds your spendable balance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Anyway'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time == null) return;
    setState(() {
      _selectedDate = DateTime(
        picked.year, picked.month, picked.day,
        time.hour, time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final fundStateAsync = ref.watch(fundStateStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: fundStateAsync.when(
        data: (state) => state != null
            ? _buildForm(context, state)
            : const Center(child: Text('Balance not set up')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildForm(BuildContext context, FundState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spendable remaining display
            _buildSpendableHeader(context, state),
            const SizedBox(height: 28),
            // Amount
            _buildAmountField(context, state),
            if (_warningMessage != null) ...[
              const SizedBox(height: 8),
              _buildWarningBanner(context),
            ],
            const SizedBox(height: 16),
            // Note
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g. Lunch at Sharma\'s',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 20),
            // Category
            Text('Category', style: AppTextStyles.labelLarge(context)),
            const SizedBox(height: 12),
            _buildCategoryGrid(context),
            const SizedBox(height: 20),
            // Date/time
            _buildDatePicker(context),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _submit(state),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Add Expense'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendableHeader(BuildContext context, FundState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: state.isOverspent
              ? AppColors.dangerGradient
              : AppColors.accentGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Spendable balance',
                    style: AppTextStyles.labelSmall(context)
                        .copyWith(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(state.spendableAmount),
                  style: AppTextStyles.headlineLarge(context)
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          if (state.isOverspent)
            const Icon(Icons.warning_amber_rounded,
                color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildAmountField(BuildContext context, FundState state) {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      autofocus: true,
      style: AppTextStyles.displaySmall(context)
          .copyWith(color: AppColors.primary),
      decoration: const InputDecoration(
        labelText: 'Amount',
        prefixText: '₹ ',
        prefixIcon: Icon(Icons.currency_rupee_rounded),
        hintText: '0.00',
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Amount is required';
        final val = double.tryParse(v);
        if (val == null || val <= 0) return 'Enter a valid amount';
        return null;
      },
    );
  }

  Widget _buildWarningBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.warning, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _warningMessage!,
              style: AppTextStyles.bodySmall(context)
                  .copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ExpenseCategory.values.map((cat) {
        final isSelected = _selectedCategory == cat;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedCategory = cat);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? cat.color.withOpacity(0.2)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? cat.color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat.icon,
                    size: 16,
                    color: isSelected ? cat.color : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 6),
                Text(
                  cat.label,
                  style: AppTextStyles.labelMedium(context).copyWith(
                    color: isSelected
                        ? cat.color
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Theme.of(context).brightness == Brightness.dark
              ? Border.all(color: AppColors.darkBorder)
              : null,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date & Time',
                      style: AppTextStyles.labelSmall(context)),
                  const SizedBox(height: 2),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}  '
                    '${_selectedDate.hour.toString().padLeft(2, '0')}:'
                    '${_selectedDate.minute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.bodyLarge(context),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
