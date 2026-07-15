import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/fund_state.dart';
import '../../providers/ledger_provider.dart';
import '../../../data/repositories/fund_state_repository.dart';
import '../../app_router.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/ledger_list_item.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimController;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    // Load initial ledger page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ledgerProvider.notifier).loadFirstPage();
      _fabAnimController.forward();
    });
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fundStateAsync = ref.watch(fundStateStreamProvider);
    final ledgerState = ref.watch(ledgerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(fundStateStreamProvider);
            await ref.read(ledgerProvider.notifier).loadFirstPage();
          },
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main balance card
                      fundStateAsync.when(
                        data: (state) => state != null
                            ? BalanceCard(fundState: state)
                            : _buildEmptyBalanceCard(context),
                        loading: () => _buildBalanceCardShimmer(context),
                        error: (e, _) => _buildErrorCard(context, e.toString()),
                      ),
                      const SizedBox(height: 28),
                      // Today's spend summary
                      fundStateAsync.whenData((state) {
                        if (state == null) return const SizedBox();
                        return _buildTodaysSummary(context, ledgerState);
                      }).valueOrNull ?? const SizedBox(),
                      const SizedBox(height: 20),
                      // Recent transactions header
                      _buildSectionHeader(context, 'Recent', AppRoutes.history),
                    ],
                  ),
                ),
              ),
              // Ledger entries
              _buildLedgerList(context, ledgerState),
              // Load more indicator
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: ledgerState.isLoading && ledgerState.entries.isNotEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : const SizedBox(),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildFAB(context, fundStateAsync.valueOrNull),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.accentGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Text('Safe-to-Spend', style: AppTextStyles.headlineSmall(context)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bar_chart_rounded),
          onPressed: () => context.push(AppRoutes.summary),
          tooltip: 'Monthly Summary',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit_fund',
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, size: 18),
                  SizedBox(width: 12),
                  Text('Edit Balance'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history_rounded, size: 18),
                  SizedBox(width: 12),
                  Text('Full History'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'sign_out',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 18),
                  SizedBox(width: 12),
                  Text('Sign Out'),
                ],
              ),
            ),
          ],
          onSelected: (val) async {
            switch (val) {
              case 'edit_fund':
                context.push(AppRoutes.editFund);
                break;
              case 'history':
                context.push(AppRoutes.history);
                break;
              case 'sign_out':
                await ref.read(authRepositoryProvider).signOut();
                break;
            }
          },
        ),
      ],
    );
  }

  Widget _buildTodaysSummary(BuildContext context, LedgerState ledgerState) {
    final todayEntries = ledgerState.entries.where((e) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final entryDay = DateTime(
          e.timestamp.year, e.timestamp.month, e.timestamp.day);
      return entryDay == today && e.isExpense;
    }).toList();

    final todayTotal = todayEntries.fold(0.0, (sum, e) => sum + e.amount);
    final monthEntries = ledgerState.entries.where((e) =>
        DateFormatter.isThisMonth(e.timestamp) && e.isExpense);
    final monthTotal = monthEntries.fold(0.0, (sum, e) => sum + e.amount);

    return Row(
      children: [
        Expanded(
          child: _summaryTile(
            context,
            label: "Today's spend",
            value: CurrencyFormatter.format(todayTotal),
            icon: Icons.today_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryTile(
            context,
            label: 'This month',
            value: CurrencyFormatter.format(monthTotal),
            icon: Icons.calendar_month_rounded,
            color: AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _summaryTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: AppColors.darkBorder)
            : null,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: AppTextStyles.labelSmall(context)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.headlineSmall(context)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String route) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.headlineMedium(context)),
        TextButton(
          onPressed: () => context.push(route),
          child: Text(
            'See all',
            style: AppTextStyles.labelMedium(context)
                .copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  SliverList _buildLedgerList(BuildContext context, LedgerState ledgerState) {
    if (ledgerState.isLoading && ledgerState.entries.isEmpty) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => const _ShimmerListItem(),
          childCount: 5,
        ),
      );
    }

    if (ledgerState.entries.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text('No transactions yet',
                    style: AppTextStyles.headlineSmall(context)),
                const SizedBox(height: 8),
                Text('Tap + to add your first expense',
                    style: AppTextStyles.bodyMedium(context)),
              ],
            ),
          ),
        ),
      );
    }

    // Show only first 5 on home screen
    final preview = ledgerState.entries.take(5).toList();
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return LedgerListItem(
              entry: preview[index],
              onTap: () => context.push(
                AppRoutes.editExpense,
                extra: preview[index],
              ),
              onDelete: () async {
                final confirm = await _confirmDelete(context);
                if (confirm == true) {
                  await ref
                      .read(ledgerProvider.notifier)
                      .deleteEntry(preview[index]);
                }
              },
            );
          },
          childCount: preview.length,
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context, FundState? fundState) {
    return ScaleTransition(
      scale: CurvedAnimation(
          parent: _fabAnimController, curve: Curves.elasticOut),
      child: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addExpense),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 1:
            context.push(AppRoutes.history);
            break;
          case 2:
            context.push(AppRoutes.summary);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_rounded),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_rounded),
          label: 'Summary',
        ),
      ],
    );
  }

  Widget _buildEmptyBalanceCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  size: 48, color: AppColors.primary),
              const SizedBox(height: 12),
              Text('No balance set up',
                  style: AppTextStyles.headlineSmall(context)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.setup),
                child: const Text('Set Up Balance'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCardShimmer(BuildContext context) {
    return const _ShimmerBox(height: 220);
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Card(
      color: AppColors.error.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Failed to load balance. Pull to refresh.',
                style: AppTextStyles.bodyMedium(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Entry?'),
        content: const Text(
            'This will remove the transaction and restore the amount to your spendable balance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer widgets
// ---------------------------------------------------------------------------
class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({this.height = 60, this.width = double.infinity});
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFE8E8F0),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _ShimmerListItem extends StatelessWidget {
  const _ShimmerListItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          const _ShimmerBox(height: 44, width: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(height: 14, width: MediaQuery.of(context).size.width * 0.4),
                const SizedBox(height: 6),
                _ShimmerBox(height: 12, width: MediaQuery.of(context).size.width * 0.25),
              ],
            ),
          ),
          const _ShimmerBox(height: 16, width: 60),
        ],
      ),
    );
  }
}
