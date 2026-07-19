import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../widgets/neumorphic.dart';
import '../../../core/utils/formatters.dart';
import '../accounts/accounts_screen.dart';
import '../categories/categories_screen.dart';
import '../recurring/recurring_screen.dart';
import '../funds/edit_funds_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final totalSpendable = ref.watch(totalSpendableProvider);
    final thisMonthSpend = ref.watch(thisMonthSpendProvider);
    final totalLocked = ref.watch(totalLockedProvider);
    final accounts = ref.watch(accountsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, Alex',
                        style: tt.labelMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        'SafeSpend',
                        style: tt.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      NeumorphicContainer(
                        width: 44,
                        height: 44,
                        borderRadius: 22,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile details coming soon')),
                          );
                        },
                        child: const Icon(
                          Icons.person_outline,
                          color: Color(0xFFB8B8C0),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      NeumorphicContainer(
                        width: 44,
                        height: 44,
                        borderRadius: 22,
                        onTap: () => _showNavigationMenu(context, ref),
                        child: const Icon(
                          Icons.menu,
                          color: Color(0xFFB8B8C0),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Hero Card: Combined Spendable ──────────────────────────────
              Text(
                'TOTAL SPENDABLE',
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              NeumorphicContainer(
                borderRadius: 28,
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatCurrency(totalSpendable),
                            style: tt.displaySmall?.copyWith(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Across all account funds',
                            style: tt.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    NeumorphicContainer(
                      width: 52,
                      height: 52,
                      borderRadius: 26,
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Color(0xFFB8B8C0),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Stats Horizontal Row ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.trending_down_outlined,
                      label: 'Spent',
                      value: formatCurrency(thisMonthSpend),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.lock_outline_rounded,
                      label: 'Locked',
                      value: formatCurrency(totalLocked),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.account_balance_outlined,
                      label: 'Accounts',
                      value: '${accounts.length}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Horizontally Scrollable Accounts List ───────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Accounts',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AccountsScreen()),
                    ),
                    child: Text(
                      'View All',
                      style: tt.labelMedium?.copyWith(
                        color: const Color(0xFFB8B8C0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: accounts.length,
                  itemBuilder: (context, i) {
                    final a = accounts[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: NeumorphicContainer(
                        width: 160,
                        borderRadius: 24,
                        padding: const EdgeInsets.all(16),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditFundsScreen(initialAccountId: a.id),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(a.icon, size: 16, color: const Color(0xFFB8B8C0)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    a.name,
                                    style: tt.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFF5F5F7),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              formatCurrency(a.spendableAmount),
                              style: tt.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Spendable',
                              style: tt.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 36),

              // ── Quick Add Expense Banner (Primary CTA gradient slice) ─────
              NeumorphicContainer(
                borderRadius: 24,
                showRainbowBorder: true, // Thin rainbow gradient sliver across the top edge
                padding: const EdgeInsets.all(20),
                onTap: () {
                  // Navigate to Add Expense Screen
                  // We simulate index change by notifying or dispatching.
                  // Since we are in DashboardScreen, let's open it using Navigator.
                  // Wait, or we can use custom navigation.
                  // A full-screen dialog / screen push is extremely clean.
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick add expense',
                            style: tt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Record a new payment immediately',
                            style: tt.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFFB8B8C0),
                      size: 16,
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

  void _showNavigationMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final tt = Theme.of(context).textTheme;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Navigation Menu',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.account_balance_outlined),
                title: const Text('Accounts'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountsScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('Categories'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.repeat_rounded),
                title: const Text('Recurring Expenses'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RecurringScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.savings_outlined),
                title: const Text('Edit Funds'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EditFundsScreen()));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.refresh_rounded, color: Color(0xFFEF4444)),
                title: const Text('Reset Onboarding', style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(isOnboardedProvider.notifier).state = false;
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return NeumorphicContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFB8B8C0)),
          const SizedBox(height: 6),
          Text(
            value,
            style: tt.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: tt.labelSmall,
          ),
        ],
      ),
    );
  }
}
