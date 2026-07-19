import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../widgets/neumorphic.dart';
import '../../../domain/models/account.dart';
import '../../../core/utils/formatters.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  String? _expandedAccountId;

  void _showAddAccountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddAccountSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final accounts = ref.watch(accountsProvider);
    final transactions = ref.watch(transactionsProvider);

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
                      'Accounts',
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

              // ── List of Accounts ───────────────────────────────────────────
              ...accounts.map((acc) {
                final isExpanded = _expandedAccountId == acc.id;

                // Calculate total spend on this account this month
                final now = DateTime.now();
                final monthlySpend = transactions
                    .where((t) => t.accountId == acc.id && t.date.year == now.year && t.date.month == now.month)
                    .fold(0.0, (sum, t) => sum + t.amount);

                final limit = acc.spendableAmount;
                final spendRatio = limit > 0 ? (monthlySpend / limit).clamp(0.0, 1.0) : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: NeumorphicContainer(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(20),
                    onTap: () {
                      setState(() {
                        _expandedAccountId = isExpanded ? null : acc.id;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            NeumorphicContainer(
                              width: 42,
                              height: 42,
                              borderRadius: 21,
                              child: Icon(acc.icon, size: 18, color: const Color(0xFFB8B8C0)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    acc.name,
                                    style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    'Spendable: ${formatCurrency(acc.spendableAmount)}',
                                    style: tt.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: const Color(0xFF8A8A93),
                            ),
                          ],
                        ),

                        // Expanded detail sub-card
                        if (isExpanded) ...[
                          const SizedBox(height: 20),
                          NeumorphicContainer(
                            borderRadius: 16,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _DetailRow(label: 'Principal Bank Balance', value: formatCurrency(acc.principalAmount)),
                                const SizedBox(height: 6),
                                _DetailRow(label: 'Locked Savings Goal', value: formatCurrency(acc.lockedAmount)),
                                const SizedBox(height: 6),
                                _DetailRow(label: 'Monthly Spend Limit Used', value: formatCurrency(monthlySpend)),
                                const SizedBox(height: 16),

                                // Inset Horizontal Progress Bar
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Spend Limit',
                                          style: TextStyle(fontSize: 11, color: Color(0xFF8A8A93)),
                                        ),
                                        Text(
                                          '${(spendRatio * 100).toStringAsFixed(0)}%',
                                          style: const TextStyle(fontSize: 11, color: Color(0xFFF5F5F7), fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      height: 10,
                                      child: Stack(
                                        children: [
                                          NeumorphicContainer(
                                            isInset: true,
                                            borderRadius: 5,
                                            child: const SizedBox.expand(),
                                          ),
                                          FractionallySizedBox(
                                            widthFactor: spendRatio,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFB8B8C0),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  ref.read(accountsProvider.notifier).delete(acc.id);
                                  setState(() {
                                    _expandedAccountId = null;
                                  });
                                },
                                icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                                label: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // ── Add Account Button ──────────────────────────────────────────
              NeumorphicContainer(
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(vertical: 20),
                onTap: () => _showAddAccountSheet(context),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Color(0xFFB8B8C0), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Add Account',
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A93)),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, color: Color(0xFFF5F5F7), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _AddAccountSheet extends ConsumerStatefulWidget {
  const _AddAccountSheet();

  @override
  ConsumerState<_AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends ConsumerState<_AddAccountSheet> {
  final _nameController = TextEditingController();
  final _principalController = TextEditingController(text: '0');
  final _lockedController = TextEditingController(text: '0');
  IconData _selectedIcon = Icons.account_balance;

  final _icons = [
    Icons.account_balance,
    Icons.savings,
    Icons.account_balance_wallet,
    Icons.credit_card,
    Icons.payment,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _principalController.dispose();
    _lockedController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final principal = double.tryParse(_principalController.text.trim()) ?? 0;
    final locked = double.tryParse(_lockedController.text.trim()) ?? 0;

    final notifier = ref.read(accountsProvider.notifier);
    notifier.add(Account(
      id: notifier.generateId(),
      name: name,
      principalAmount: principal,
      lockedAmount: locked,
      color: Colors.white, // In monochrome style color doesn't matter
      icon: _selectedIcon,
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

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
            'New Account',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          NeumorphicTextField(
            labelText: 'Account Name',
            hintText: 'e.g. Credit Card',
            controller: _nameController,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: NeumorphicTextField(
                  labelText: 'Principal (₹)',
                  controller: _principalController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: NeumorphicTextField(
                  labelText: 'Locked (₹)',
                  controller: _lockedController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Icon Type',
            style: tt.labelMedium,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _icons.map((icon) {
              final isSelected = _selectedIcon == icon;
              return NeumorphicContainer(
                width: 44,
                height: 44,
                borderRadius: 22,
                isInset: isSelected,
                onTap: () => setState(() => _selectedIcon = icon),
                child: Icon(icon, size: 20, color: isSelected ? const Color(0xFFF5F5F7) : const Color(0xFF8A8A93)),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          NeumorphicButton(
            onTap: _save,
            child: const Text(
              'Save Account',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
