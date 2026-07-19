import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../widgets/neumorphic.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/transaction_tile.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isFilterPanelExpanded = false;
  String? _selectedAccountId;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final allTransactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final accounts = ref.watch(accountsProvider);
    final categoryMap = {for (final c in categories) c.id: c};
    final accountMap = {for (final a in accounts) a.id: a};

    final filtered = allTransactions.where((t) {
      if (_selectedAccountId != null && t.accountId != _selectedAccountId) {
        return false;
      }
      if (_selectedCategoryId != null && t.categoryId != _selectedCategoryId) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final cat = categoryMap[t.categoryId];
        final query = _searchQuery.toLowerCase();
        final noteMatch = t.note.toLowerCase().contains(query);
        final catMatch = cat != null && cat.name.toLowerCase().contains(query);
        final amountMatch = t.amount.toString().contains(query);
        if (!noteMatch && !catMatch && !amountMatch) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                'Transaction History',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),

            // ── Inset Search Bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: NeumorphicContainer(
                isInset: true,
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: TextField(
                  controller: _searchController,
                  style: tt.bodyLarge?.copyWith(
                    color: const Color(0xFFF5F5F7),
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    hintStyle: tt.bodyLarge?.copyWith(
                      color: const Color(0xFF8A8A93).withOpacity(0.4),
                    ),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF8A8A93), size: 18),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
            ),

            // ── Filter Pill Row ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: [
                          _FilterPill(
                            label: _selectedAccountId != null
                                ? (accountMap[_selectedAccountId]?.name ?? 'Account')
                                : 'Account',
                            isActive: _selectedAccountId != null,
                            onTap: () {
                              setState(() {
                                _isFilterPanelExpanded = !_isFilterPanelExpanded;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterPill(
                            label: _selectedCategoryId != null
                                ? (categoryMap[_selectedCategoryId]?.name ?? 'Category')
                                : 'Category',
                            isActive: _selectedCategoryId != null,
                            onTap: () {
                              setState(() {
                                _isFilterPanelExpanded = !_isFilterPanelExpanded;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterPill(
                            label: 'Date',
                            isActive: false,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Date filter coming soon')),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _FilterPill(
                            label: 'Amount',
                            isActive: false,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Amount filter coming soon')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  NeumorphicContainer(
                    width: 38,
                    height: 38,
                    borderRadius: 10,
                    isInset: _isFilterPanelExpanded,
                    onTap: () {
                      setState(() {
                        _isFilterPanelExpanded = !_isFilterPanelExpanded;
                      });
                    },
                    child: const Icon(Icons.tune, size: 16, color: Color(0xFFB8B8C0)),
                  ),
                ],
              ),
            ),

            // ── Expanded Filter Panel ────────────────────────────────────────
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: NeumorphicContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filter by Account', style: tt.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: _selectedAccountId == null,
                            onSelected: (_) => setState(() => _selectedAccountId = null),
                          ),
                          ...accounts.map((a) => ChoiceChip(
                                label: Text(a.name),
                                selected: _selectedAccountId == a.id,
                                onSelected: (_) => setState(() => _selectedAccountId = a.id),
                              )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Filter by Category', style: tt.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: _selectedCategoryId == null,
                            onSelected: (_) => setState(() => _selectedCategoryId = null),
                          ),
                          ...categories.map((c) => ChoiceChip(
                                label: Text(c.name),
                                selected: _selectedCategoryId == c.id,
                                onSelected: (_) => setState(() => _selectedCategoryId = c.id),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              crossFadeState: _isFilterPanelExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),

            // ── List of Transactions ─────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? const NeumorphicEmptyState(
                      icon: Icons.receipt_long_outlined,
                      text: 'No transactions found.\nAdjust your filters or query to find items.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 100),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final t = filtered[i];
                        final cat = categoryMap[t.categoryId];
                        final acc = accountMap[t.accountId];
                        if (cat == null || acc == null) return const SizedBox();

                        return TransactionTile(
                          transaction: t,
                          category: cat,
                          account: acc,
                          onDelete: () => ref.read(transactionsProvider.notifier).delete(t.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return NeumorphicContainer(
      borderRadius: 14,
      isInset: isActive,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Text(
        label,
        style: tt.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? const Color(0xFFF5F5F7) : const Color(0xFF8A8A93),
        ),
      ),
    );
  }
}
