import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/logic/spendable_calculator.dart';
import '../../providers/fund_state_provider.dart';
import '../../app_router.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _lockedController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    _lockedController.addListener(() => setState(() {}));
    _principalController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animController.dispose();
    _principalController.dispose();
    _lockedController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _principal =>
      double.tryParse(_principalController.text.replaceAll(',', '')) ?? 0;
  double get _locked =>
      double.tryParse(_lockedController.text.replaceAll(',', '')) ?? 0;
  double get _spendable => _principal - _locked;

  Future<void> _setup() async {
    if (!_formKey.currentState!.validate()) return;

    final validation = SpendableCalculator.validateFundState(
      principal: _principal,
      locked: _locked,
    );
    if (!validation.isValid) {
      setState(() => _errorMessage = validation.message);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(fundStateNotifierProvider.notifier).initialize(
            principal: _principal,
            locked: _locked,
            note: _noteController.text.isEmpty ? null : _noteController.text,
          );
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      setState(() => _errorMessage = 'Setup failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                _buildHeader(context),
                const SizedBox(height: 40),
                if (_principal > 0) ...[
                  _buildSpendablePreview(context),
                  const SizedBox(height: 32),
                ],
                _buildForm(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.accentGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.tune_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 24),
        Text('Set up your balance', style: AppTextStyles.displaySmall(context)),
        const SizedBox(height: 8),
        Text(
          'Enter your current bank balance and how much you want to lock away as savings. The rest is your safe-to-spend amount.',
          style: AppTextStyles.bodyMedium(context),
        ),
      ],
    );
  }

  Widget _buildSpendablePreview(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.accentGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your safe-to-spend will be',
            style: AppTextStyles.labelMedium(context)
                .copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${_spendable.toStringAsFixed(2)}',
            style: AppTextStyles.displayMedium(context).copyWith(
              color: Colors.white,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _previewChip('Principal', _principal),
              const SizedBox(width: 12),
              _previewChip('Locked', _locked),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewChip(String label, double amount) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text('₹${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildAmountField(
            controller: _principalController,
            label: 'Total Balance (Principal)',
            hint: 'e.g. 8000',
            icon: Icons.account_balance_rounded,
            helperText: 'Your current total bank balance',
          ),
          const SizedBox(height: 16),
          _buildAmountField(
            controller: _lockedController,
            label: 'Locked Amount (Savings)',
            hint: 'e.g. 6000',
            icon: Icons.lock_rounded,
            helperText: 'Amount you never want to touch',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteController,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              hintText: 'e.g. July salary setup',
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
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
              onPressed: _isLoading ? null : _setup,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Start Tracking'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField({
    required String id,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? helperText,
  }) {
    return TextFormField(
      id: id,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        prefixText: '₹ ',
        helperText: helperText,
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
