import 'package:flutter/material.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/category.dart';
import '../../domain/models/account.dart';
import '../../core/utils/formatters.dart';
import '../widgets/neumorphic.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final Category category;
  final Account account;
  final VoidCallback? onDelete;

  const TransactionTile({
    required this.transaction,
    required this.category,
    required this.account,
    super.key,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: NeumorphicContainer(
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Raised circular category icon
              NeumorphicContainer(
                width: 44,
                height: 44,
                borderRadius: 22,
                child: Center(
                  child: Icon(
                    category.icon,
                    size: 18,
                    color: const Color(0xFFB8B8C0),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              
              // Note & Account details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.note.isEmpty ? category.name : transaction.note,
                      style: tt.bodyLarge?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${category.name} · ${account.name}',
                      style: tt.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Amount & Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-${formatCurrency(transaction.amount)}',
                    style: tt.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFF5F5F7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatDate(transaction.date),
                    style: tt.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
