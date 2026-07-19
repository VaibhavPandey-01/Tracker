import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/providers.dart';
import '../../widgets/neumorphic.dart';
import '../../widgets/empty_state.dart';
import '../../../core/utils/formatters.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final categories = ref.watch(categoriesProvider);
    final categoryMap = {for (final c in categories) c.id: c};
    
    final spendByCategory = ref.watch(spendByCategoryProvider(_selectedMonth));
    final spendPerDay = ref.watch(spendPerDayProvider(_selectedMonth));

    final totalSpend = spendByCategory.values.fold(0.0, (a, b) => a + b);

    // Filter categories with > 0 spend
    final activeSpends = spendByCategory.entries.where((e) => e.value > 0).toList();

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
                  Text(
                    'Reports',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Color(0xFFB8B8C0)),
                        onPressed: () => setState(() {
                          _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                        }),
                      ),
                      Text(
                        formatMonth(_selectedMonth),
                        style: tt.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFFF5F5F7)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Color(0xFFB8B8C0)),
                        onPressed: () => setState(() {
                          _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                        }),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (totalSpend <= 0) ...[
                const NeumorphicEmptyState(
                  icon: Icons.pie_chart_outline,
                  text: 'No transaction data found for this month.\nTry adding some expenses first!',
                ),
              ] else ...[
                // ── Donut Chart Card ──────────────────────────────────────────
                Text(
                  'SPEND BY CATEGORY',
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                NeumorphicContainer(
                  borderRadius: 28,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Soft background track
                            NeumorphicContainer(
                              width: 176,
                              height: 176,
                              borderRadius: 88,
                              isInset: true,
                              child: const SizedBox(),
                            ),
                            // Slices
                            PieChart(
                              PieChartData(
                                sections: List.generate(activeSpends.length, (index) {
                                  final entry = activeSpends[index];
                                  
                                  // Pick color from rainbow sequence
                                  final color = rainbowColors[index % rainbowColors.length];

                                  return PieChartSectionData(
                                    value: entry.value,
                                    color: color,
                                    radius: 12,
                                    title: '',
                                    badgeWidget: null,
                                  );
                                }),
                                centerSpaceRadius: 76,
                                sectionsSpace: 4,
                                startDegreeOffset: -90,
                              ),
                            ),
                            // Center Text Info
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  formatCurrency(totalSpend),
                                  style: tt.titleLarge?.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFF5F5F7),
                                  ),
                                ),
                                Text(
                                  'Total Spend',
                                  style: tt.labelSmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Segment indicators with Category labels
                      ...List.generate(activeSpends.length, (index) {
                        final entry = activeSpends[index];
                        final cat = categoryMap[entry.key];
                        final pct = (entry.value / totalSpend) * 100;
                        final color = rainbowColors[index % rainbowColors.length];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(cat?.icon ?? Icons.category_outlined, size: 14, color: const Color(0xFF8A8A93)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cat?.name ?? 'Unknown',
                                  style: tt.bodyMedium?.copyWith(fontSize: 13),
                                ),
                              ),
                              Text(
                                '${pct.toStringAsFixed(0)}% · ${formatCurrency(entry.value)}',
                                style: tt.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Monochrome Daily Trend Chart Card ─────────────────────────
                Text(
                  'DAILY SPENDING TREND',
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                NeumorphicContainer(
                  borderRadius: 28,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Spend over time',
                        style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      Text(
                        'Daily transactions represented as raised pills',
                        style: tt.labelSmall,
                      ),
                      const SizedBox(height: 28),
                      // Custom Neumorphic vertical bar chart
                      _NeumorphicBarChart(spendPerDay: spendPerDay, month: _selectedMonth),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeumorphicBarChart extends StatelessWidget {
  final Map<int, double> spendPerDay;
  final DateTime month;

  const _NeumorphicBarChart({required this.spendPerDay, required this.month});

  @override
  Widget build(BuildContext context) {
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    
    // Group days into 6 chunks of ~5 days each for screen space
    const chunksCount = 6;
    final chunkSize = (days / chunksCount).ceil();
    final chunkSums = List.filled(chunksCount, 0.0);

    for (var d = 1; d <= days; d++) {
      final chunkIdx = ((d - 1) / chunkSize).floor();
      if (chunkIdx < chunksCount) {
        chunkSums[chunkIdx] += spendPerDay[d] ?? 0.0;
      }
    }

    final maxVal = chunkSums.isEmpty ? 1.0 : chunkSums.reduce((a, b) => a > b ? a : b);
    final limit = maxVal <= 0 ? 1.0 : maxVal;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(chunksCount, (i) {
        final val = chunkSums[i];
        final ratio = (val / limit).clamp(0.05, 1.0);
        final startDay = i * chunkSize + 1;
        final endDay = ((i + 1) * chunkSize).clamp(1, days);

        return Column(
          children: [
            SizedBox(
              height: 120,
              width: 24,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Inset track
                  NeumorphicContainer(
                    isInset: true,
                    borderRadius: 12,
                    child: const SizedBox.expand(),
                  ),
                  // Raised pill value indicator
                  FractionallySizedBox(
                    heightFactor: ratio,
                    child: NeumorphicContainer(
                      borderRadius: 12,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$startDay-$endDay',
              style: const TextStyle(fontSize: 8, color: Color(0xFF8A8A93)),
            ),
          ],
        );
      }),
    );
  }
}
