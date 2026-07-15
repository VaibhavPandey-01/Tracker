import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/enums/expense_category.dart';
import '../../domain/enums/entry_type.dart';
import '../../domain/models/ledger_entry.dart';

/// A single ledger entry row — shows in both History and Home screens.
/// Supports tap to edit and swipe/long-press to delete.
class LedgerListItem extends StatelessWidget {
  const LedgerListItem({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
    this.showBalanceAfter = false,
  });

  final LedgerEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showBalanceAfter;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 24),
      ),
      confirmDismiss: (_) async {
        if (onDelete == null) return false;
        return _confirmDelete(context);
      },
      onDismissed: (_) => onDelete?.call(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              _buildIcon(context),
              const SizedBox(width: 14),
              Expanded(
                child: _buildContent(context),
              ),
              _buildAmount(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFundUpdate = entry.type == EntryType.fundUpdate;
    final cat = entry.category;

    final color = isFundUpdate
        ? AppColors.success
        : (cat?.color ?? AppColors.catOther);
    final icon = isFundUpdate
        ? Icons.swap_vert_circle_rounded
        : (cat?.icon ?? Icons.receipt_rounded);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _title,
          style: AppTextStyles.bodyLarge(context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              DateFormatter.formatTime(entry.timestamp),
              style: AppTextStyles.bodySmall(context),
            ),
            if (showBalanceAfter) ...[
              Text(' · ', style: AppTextStyles.bodySmall(context)),
              Text(
                'Balance: ${CurrencyFormatter.formatCompact(entry.balanceAfter)}',
                style: AppTextStyles.bodySmall(context),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAmount(BuildContext context) {
    final isFundUpdate = entry.type == EntryType.fundUpdate;
    final color = isFundUpdate ? AppColors.success : AppColors.error;
    final prefix = isFundUpdate ? '+' : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$prefix${CurrencyFormatter.format(entry.amount)}',
          style: AppTextStyles.labelLarge(context).copyWith(color: color),
        ),
        if (onTap != null)
          const Icon(Icons.chevron_right_rounded, size: 14,
              color: AppColors.darkTextMuted),
      ],
    );
  }

  String get _title {
    if (entry.type == EntryType.fundUpdate) {
      return entry.note ?? 'Fund Update';
    }
    return entry.note ?? (entry.category?.label ?? 'Expense');
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Entry?'),
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
    return result ?? false;
  }
}
