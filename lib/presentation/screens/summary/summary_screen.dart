import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/enums/expense_category.dart';
import '../../providers/ledger_provider.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(monthlySummaryProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryState = ref.watch(monthlySummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormatter.formatMonth(DateTime.now())),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'By Category'),
            Tab(text: 'By Day'),
          ],
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
        ),
      ),
      body: summaryState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : summaryState.error != null
              ? Center(child: Text('Error: ${summaryState.error}'))
              : summaryState.expensesOnly.isEmpty
                  ? _buildEmptyState(context)
                  : _buildContent(context, summaryState),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 72,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text('No expenses this month',
              style: AppTextStyles.headlineSmall(context)),
          const SizedBox(height: 8),
          Text(
            'Your spending summary will appear here\nonce you log some expenses.',
            style: AppTextStyles.bodyMedium(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, MonthlySummaryState state) {
    return Column(
      children: [
        _buildTotalCard(context, state),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryChart(context, state),
              _buildDayChart(context, state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCard(BuildContext context, MonthlySummaryState state) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total spent this month',
                  style: AppTextStyles.labelSmall(context)
                      .copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.format(state.totalSpent),
                  style: AppTextStyles.displaySmall(context).copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${state.expensesOnly.length}',
                style: AppTextStyles.displaySmall(context)
                    .copyWith(color: Colors.white, fontSize: 24),
              ),
              Text(
                'transactions',
                style: AppTextStyles.labelSmall(context)
                    .copyWith(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(BuildContext context, MonthlySummaryState state) {
    final byCategory = state.byCategory;
    if (byCategory.isEmpty) return const SizedBox();

    final total = state.totalSpent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sections = byCategory.entries.map((entry) {
      final cat = ExpenseCategory.fromValue(entry.key);
      return PieChartSectionData(
        value: entry.value,
        color: cat.color,
        title: '${(entry.value / total * 100).toStringAsFixed(0)}%',
        radius: 80,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 3,
                centerSpaceRadius: 50,
                startDegreeOffset: -90,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          ...byCategory.entries.map((entry) {
            final cat = ExpenseCategory.fromValue(entry.key);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: cat.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(cat.icon, size: 16, color: cat.color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(cat.label,
                        style: AppTextStyles.bodyMedium(context)),
                  ),
                  Text(
                    CurrencyFormatter.format(entry.value),
                    style: AppTextStyles.labelLarge(context),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDayChart(BuildContext context, MonthlySummaryState state) {
    final byDay = state.byDay;
    if (byDay.isEmpty) return const SizedBox();

    final sortedDays = byDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final maxY = sortedDays.fold(0.0, (m, e) => e.value > m ? e.value : m);

    final bars = sortedDays.asMap().entries.map((entry) {
      final index = entry.key;
      final day = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: day.value,
            gradient: const LinearGradient(
              colors: AppColors.accentGradient,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();

    final dayLabels = sortedDays.map((e) => e.key.split('-').last).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.2,
                barGroups: bars,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) => Text(
                        CurrencyFormatter.formatShort(value),
                        style: AppTextStyles.labelSmall(context),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= dayLabels.length) return const SizedBox();
                        return Text(
                          dayLabels[idx],
                          style: AppTextStyles.labelSmall(context),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles()),
                  rightTitles: const AxisTitles(sideTitles: SideTitles()),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        CurrencyFormatter.format(rod.toY),
                        const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Summary table
          ...sortedDays.map((entry) {
            final parts = entry.key.split('-');
            final label =
                '${parts[2]}/${parts[1]}/${parts[0]}'; // dd/mm/yyyy
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: AppTextStyles.bodyMedium(context)),
                  Text(
                    CurrencyFormatter.format(entry.value),
                    style: AppTextStyles.labelLarge(context),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
