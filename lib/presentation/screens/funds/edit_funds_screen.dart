import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../widgets/neumorphic.dart';
import '../../../core/utils/formatters.dart';

class EditFundsScreen extends ConsumerStatefulWidget {
  final String? initialAccountId;

  const EditFundsScreen({super.key, this.initialAccountId});

  @override
  ConsumerState<EditFundsScreen> createState() => _EditFundsScreenState();
}

class _EditFundsScreenState extends ConsumerState<EditFundsScreen> {
  String? _selectedAccountId;
  final _principalController = TextEditingController(text: '0');
  final _lockedController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.initialAccountId;
    _principalController.addListener(_onChanged);
    _lockedController.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _principalController.removeListener(_onChanged);
    _lockedController.removeListener(_onChanged);
    _principalController.dispose();
    _lockedController.dispose();
    super.dispose();
  }

  double get _principal => double.tryParse(_principalController.text.trim()) ?? 0;
  double get _locked => double.tryParse(_lockedController.text.trim()) ?? 0;
  double get _spendable => (_principal - _locked).clamp(0.0, double.infinity);

  void _loadAccount(String id) {
    final accounts = ref.read(accountsProvider);
    final acc = accounts.firstWhere((a) => a.id == id, orElse: () => accounts.first);
    _principalController.text = acc.principalAmount.toStringAsFixed(0);
    _lockedController.text = acc.lockedAmount.toStringAsFixed(0);
  }

  void _save() {
    if (_selectedAccountId == null) return;
    final accounts = ref.read(accountsProvider);
    final acc = accounts.firstWhere((a) => a.id == _selectedAccountId);
    
    ref.read(accountsProvider.notifier).update(
          acc.copyWith(
            principalAmount: _principal,
            lockedAmount: _locked,
          ),
        );
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funds saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final accounts = ref.watch(accountsProvider);

    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAccount(_selectedAccountId!);
      });
    }

    final ratio = _principal > 0 ? (_spendable / _principal) : 0.0;

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
                      'Edit Funds',
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

              const SizedBox(height: 24),

              // ── Account chips ──────────────────────────────────────────────
              Text(
                'SELECT ACCOUNT',
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: accounts.map((acc) {
                  final isSelected = acc.id == _selectedAccountId;
                  return ChoiceChip(
                    label: Text(acc.name),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedAccountId = acc.id);
                      _loadAccount(acc.id);
                    },
                    backgroundColor: Colors.transparent,
                    selectedColor: const Color(0xFF141416),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFFF5F5F7) : const Color(0xFF8A8A93),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // ── Circular rainbow gauge ──────────────────────────────────────
              Center(
                child: RainbowGauge(
                  percentage: ratio,
                  centerWidget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formatCurrency(_spendable),
                        style: tt.titleLarge?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Spendable (${(ratio * 100).toStringAsFixed(0)}%)',
                        style: tt.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Principal Field ─────────────────────────────────────────────
              NeumorphicTextField(
                labelText: 'Principal Bank Balance',
                hintText: 'e.g. 50000',
                controller: _principalController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),

              const SizedBox(height: 20),

              // ── Locked Field ────────────────────────────────────────────────
              NeumorphicTextField(
                labelText: 'Locked Savings Goal',
                hintText: 'e.g. 30000',
                controller: _lockedController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),

              const SizedBox(height: 48),

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
