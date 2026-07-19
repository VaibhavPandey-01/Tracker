import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/neumorphic.dart';
import '../../providers/providers.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBalance = ref.watch(totalBalanceProvider);
    final safeToSpend = ref.watch(totalSafeToSpendProvider);
    
    // Example calculation for gauge
    final double safePercentage = totalBalance > 0 ? (safeToSpend / totalBalance).clamp(0.0, 1.0) : 0.0;
    
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning,',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        'Alex',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ],
                  ),
                  NeumorphicContainer(
                    width: 48,
                    height: 48,
                    borderRadius: 24,
                    child: const Icon(Icons.person, color: AppTheme.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Center(
                child: RainbowGauge(
                  percentage: safePercentage,
                  size: 240,
                  strokeWidth: 20,
                  centerWidget: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Safe to Spend',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(safeToSpend),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: NeumorphicContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.account_balance_wallet, color: AppTheme.textSecondary),
                          const SizedBox(height: 12),
                          Text(
                            'Total Balance',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat.format(totalBalance),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NeumorphicContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lock, color: AppTheme.textSecondary),
                          const SizedBox(height: 12),
                          Text(
                            'Locked Funds',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat.format(totalBalance - safeToSpend),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final txns = ref.watch(transactionsProvider);
                    if (txns.isEmpty) {
                      return const Center(child: Text('No recent transactions'));
                    }
                    return ListView.builder(
                      itemCount: txns.length > 5 ? 5 : txns.length,
                      itemBuilder: (context, index) {
                        final txn = txns[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: NeumorphicContainer(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                NeumorphicContainer(
                                  isInset: true,
                                  width: 40,
                                  height: 40,
                                  borderRadius: 20,
                                  child: const Icon(Icons.receipt, size: 20, color: AppTheme.textSecondary),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(txn.note, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                                      Text(DateFormat('MMM dd').format(txn.date), style: Theme.of(context).textTheme.labelMedium),
                                    ],
                                  ),
                                ),
                                Text(
                                  '-${currencyFormat.format(txn.amount)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
