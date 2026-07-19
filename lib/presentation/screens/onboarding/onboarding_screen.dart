import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../widgets/neumorphic.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/account.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController(text: 'Alex');
  final _principalController = TextEditingController(text: '85000');
  final _lockedController = TextEditingController(text: '60000');

  double get _principal => double.tryParse(_principalController.text.trim()) ?? 0;
  double get _locked => double.tryParse(_lockedController.text.trim()) ?? 0;
  double get _spendable => (_principal - _locked).clamp(0.0, double.infinity);

  void _getStarted() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    // Set first account's principal/locked balances
    final accounts = ref.read(accountsProvider);
    if (accounts.isNotEmpty) {
      final mainAccount = accounts.firstWhere((a) => a.id == 'acc_1', orElse: () => accounts.first);
      ref.read(accountsProvider.notifier).update(
            mainAccount.copyWith(
              principalAmount: _principal,
              lockedAmount: _locked,
            ),
          );
    } else {
      // Fallback
      ref.read(accountsProvider.notifier).add(
            Account(
              id: 'acc_1',
              name: 'Bank Account',
              principalAmount: _principal,
              lockedAmount: _locked,
              color: const Color(0xFF6366F1),
              icon: Icons.account_balance,
            ),
          );
    }

    ref.read(isOnboardedProvider.notifier).state = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _principalController.dispose();
    _lockedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'SafeSpend',
                style: tt.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'A molded soft-neumorphic experience.',
                style: tt.labelMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Name Field
              NeumorphicTextField(
                labelText: 'Your Name',
                hintText: 'Enter name',
                controller: _nameController,
              ),
              const SizedBox(height: 20),

              // Principal Input
              NeumorphicTextField(
                labelText: 'Principal Amount (Total Balance)',
                hintText: 'e.g. 50000',
                controller: _principalController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // Locked Input
              NeumorphicTextField(
                labelText: 'Locked Amount (Savings Goal)',
                hintText: 'e.g. 30000',
                controller: _lockedController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 36),

              // Big Spendable Preview Card
              Text(
                'SPENDABLE BALANCE',
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              NeumorphicContainer(
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      formatCurrency(_spendable),
                      style: tt.displaySmall?.copyWith(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ready to spend safely',
                      style: tt.labelMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Save / Submit Button
              NeumorphicButton(
                showRainbowBorder: true, // Thin rainbow gradient sliver on top
                onTap: _getStarted,
                child: Text(
                  'Get Started',
                  style: tt.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF5F5F7),
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
