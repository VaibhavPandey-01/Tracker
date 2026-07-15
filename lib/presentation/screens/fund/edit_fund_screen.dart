import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/repositories/fund_state_repository.dart';
import '../../../domain/logic/spendable_calculator.dart';
import '../../../domain/models/fund_state.dart';
import '../../providers/fund_state_provider.dart';

class EditFundScreen extends ConsumerStatefulWidget {
  const EditFundScreen({super.key});

  @override
  ConsumerState<EditFundScreen> createState() => _EditFundScreenState();
}

class _EditFundScreenState extends ConsumerState<EditFundScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _principalController;
  late TextEditingController _lockedController;
  final _noteController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  FundState? _currentState;

  @override
  void initState() {
    super.initState();
    _principalController = TextEditingController();
    _lockedController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(fundStateStreamProvider).valueOrNull;
      if (state != null) {
        _currentState = state;
        _principalController.text = state.principalAmount.toStringAsFixed(2);
        _lockedController.text = state.lockedAmount.toStringAsFixed(2);
      }
    });

    _principalController.addListener(() => setState(() {}));
    _lockedController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _principalController.dispose();
    _lockedController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _newPrincipal =>
      double.tryParse(_principalController.text.replaceAll(',', '')) ?? 0;
  double get _newLocked =>
      double.tryParse(_lockedController.text.replaceAll(',', '')) ?? 0;
  double get _newSpendable => _newPrincipal - _newLocked;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final validation = SpendableCalculator.validateFundState(
      principal: _newPrincipal,
      locked: _newLocked,
    );
    if (!validation.isValid) {
      setState(() => _errorMessage = validation.message);
      return;
    }

    if (_currentState == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(fundStateNotifierProvider.notifier).update(
            currentState: _currentState!,
            newPrincipal: _newPrincipal,
            newLocked: _newLocked,
            note: _noteController.text.isEmpty ? null : _noteController.text,
          );
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _errorMessage = 'Update failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fundStateAsync = ref.watch(fundStateStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Balance'),
      ),
      body: fundStateAsync.when(
        data: (state) {
          if (state == null) {
            return const Center(child: Text('No balance found'));
          }
          _currentState ??= state;
          return _buildForm(context, state);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildForm(BuildContext context, FundState current) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentSummary(context, current),
            const SizedBox(height: 28),
            if (_newPrincipal > 0 || _newLocked > 0) ...[
              _buildNewPreview(context),
              const SizedBox(height: 28),
            ],
            _buildInfoBanner(context),
            const SizedBox(height: 20),
            _buildAmountField(
              controller: _principalController,
              label: 'New Principal Amount',
              hint: current.principalAmount.toStringAsFixed(2),
              icon: Icons.account_balance_rounded,
            ),
            const SizedBox(height: 16),
            _buildAmountField(
              controller: _lockedController,
              label: 'New Locked Amount',
              hint: current.lockedAmount.toStringAsFixed(2),
              icon: Icons.lock_rounded,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Reason for change (optional)',
                hintText: 'e.g. August salary received',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Text(
                  _errorMessage!,
                  style: AppTextStyles.bodySmall(context)
                      .copyWith(color: AppColors.error),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Update Balance'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSummary(BuildContext context, FundState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Balance', style: AppTextStyles.labelMedium(context)),
          const SizedBox(height: 12),
          _balanceRow(context, 'Principal',
              state.principalAmount, AppColors.primary),
          const SizedBox(height: 8),
          _balanceRow(context, 'Locked', state.lockedAmount, AppColors.warning),
          const Divider(height: 20),
          _balanceRow(context, 'Spendable',
              state.spendableAmount, AppColors.accent),
        ],
      ),
    );
  }

  Widget _buildNewPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.accentGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preview after update',
              style: AppTextStyles.labelMedium(context)
                  .copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            'Spendable: ₹${_newSpendable.toStringAsFixed(2)}',
            style: AppTextStyles.headlineLarge(context)
                .copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This change will be logged as a "Fund Update" in your transaction history so you can track when and why your balance changed.',
              style: AppTextStyles.bodySmall(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceRow(
      BuildContext context, String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium(context)),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: AppTextStyles.labelLarge(context).copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildAmountField({
    required String id,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      id: id,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        prefixText: '₹ ',
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return '$label is required';
        final val = double.tryParse(v.replaceAll(',', ''));
        if (val == null || val < 0) return 'Enter a valid amount';
        return null;
      },
    );
  }
}
