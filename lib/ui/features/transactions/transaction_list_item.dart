import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:simpannow/core/services/auth_service.dart';
import 'package:simpannow/core/services/transaction_service.dart';
import 'package:simpannow/ui/features/transactions/delete_transaction_dialog.dart';
import 'package:simpannow/data/models/transaction_model.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;
  final BorderRadius? borderRadius;
  final bool showCardWrapper;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onDelete,
    this.borderRadius,
    this.showCardWrapper = true,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.INCOME;
    final color = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';

    final listTileContent = Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        child: const Icon(
          FontAwesomeIcons.trash,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        final authService = Provider.of<AuthService>(context, listen: false);
        final transactionService = Provider.of<TransactionService>(context, listen: false);

        deleteTransaction(
          context,
          transactionService,
          authService.user!.uid,
          transaction.id,
          transaction.title,
        );
        return false; // Prevent automatic dismissal
      },
      onDismissed: (direction) {
        onDelete?.call();
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(25),
          child: Text(
            TransactionService.categories[transaction.category] ?? '📝',
            style: const TextStyle(fontSize: 20),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.category,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              _formatDate(transaction.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Text(
          '${sign}RM${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    // If showCardWrapper is false, return the content directly
    if (!showCardWrapper) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: listTileContent,
      );
    }

    // Otherwise, wrap in a card (original behavior)
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: listTileContent,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);
    
    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
