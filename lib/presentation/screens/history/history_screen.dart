import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/ledger_provider.dart';
import '../../widgets/ledger_list_item.dart';
import '../../app_router.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ledgerProvider.notifier).loadFirstPage();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(ledgerProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ledgerState = ref.watch(ledgerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: ledgerState.entries.isEmpty && ledgerState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ledgerState.entries.isEmpty
              ? _buildEmptyState(context)
              : _buildList(context, ledgerState),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text('No transactions yet',
              style: AppTextStyles.headlineSmall(context)),
          const SizedBox(height: 8),
          Text(
            'Your expenses and fund updates\nwill appear here',
            style: AppTextStyles.bodyMedium(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.addExpense),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add First Expense'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, LedgerState state) {
    // Group entries by date
    final grouped = <String, List<_IndexedEntry>>{};
    for (var i = 0; i < state.entries.length; i++) {
      final entry = state.entries[i];
      final key = DateFormatter.relativeDate(entry.timestamp);
      grouped.putIfAbsent(key, () => []).add(_IndexedEntry(index: i, entry: entry));
    }

    final groups = grouped.entries.toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(ledgerProvider.notifier).loadFirstPage(),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: groups.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, groupIndex) {
          if (groupIndex == groups.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final group = groups[groupIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  group.key,
                  style: AppTextStyles.labelLarge(context)
                      .copyWith(color: AppColors.primary),
                ),
              ),
              ...group.value.map((ie) => LedgerListItem(
                    entry: ie.entry,
                    onTap: ie.entry.isExpense
                        ? () => context.push(
                              AppRoutes.editExpense,
                              extra: ie.entry,
                            )
                        : null,
                    onDelete: ie.entry.isExpense
                        ? () async {
                            final confirm = await _confirmDelete(context);
                            if (confirm == true) {
                              await ref
                                  .read(ledgerProvider.notifier)
                                  .deleteEntry(ie.entry);
                            }
                          }
                        : null,
                  )),
              const Divider(height: 1, indent: 20, endIndent: 20),
            ],
          );
        },
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Transaction?'),
        content: const Text(
            'This will remove the transaction and restore the amount to your balance.'),
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

class _IndexedEntry {
  const _IndexedEntry({required this.index, required this.entry});
  final int index;
  final dynamic entry;
}
