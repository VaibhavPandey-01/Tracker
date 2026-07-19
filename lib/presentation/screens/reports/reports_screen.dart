import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/neumorphic.dart';
import '../../providers/providers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    // Calculate totals per category
    final Map<String, double> categoryTotals = {};
    for (final txn in transactions) {
      categoryTotals[txn.categoryId] = (categoryTotals[txn.categoryId] ?? 0) + txn.amount;
    }

    final totalSpent = categoryTotals.values.fold(0.0, (sum, val) => sum + val);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'Reports',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),
              NeumorphicContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Total Spent',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormat.format(totalSpent),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 60,
                          sections: categoryTotals.entries.map((entry) {
                            final cat = categories.firstWhere((c) => c.id == entry.key);
                            final percentage = (entry.value / totalSpent) * 100;
                            return PieChartSectionData(
                              color: cat.color,
                              value: entry.value,
                              title: '${percentage.toStringAsFixed(0)}%',
                              radius: 20,
                              titleStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Top Categories',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: categoryTotals.length,
                  itemBuilder: (context, index) {
                    final sortedEntries = categoryTotals.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));
                    
                    final entry = sortedEntries[index];
                    final cat = categories.firstWhere((c) => c.id == entry.key);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: NeumorphicContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            NeumorphicContainer(
                              isInset: true,
                              width: 40,
                              height: 40,
                              borderRadius: 20,
                              child: Icon(cat.icon, color: cat.color, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              currencyFormat.format(entry.value),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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
