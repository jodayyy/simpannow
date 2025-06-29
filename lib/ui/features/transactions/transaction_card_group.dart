import 'package:flutter/material.dart';
import 'package:simpannow/data/models/transaction_model.dart';
import 'package:simpannow/ui/features/transactions/transaction_list_item.dart';

class TransactionCardGroup extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(String transactionId, String transactionTitle)? onDelete;

  const TransactionCardGroup({
    super.key,
    required this.transactions,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            for (int i = 0; i < transactions.length; i++) ...[
              TransactionListItem(
                transaction: transactions[i],
                borderRadius: _getBorderRadius(i, transactions.length),
                showCardWrapper: false, // Don't wrap in individual card
                onDelete: () => onDelete?.call(
                  transactions[i].id,
                  transactions[i].title,
                ),
              ),
              // Add divider between items (except for the last item)
              if (i < transactions.length - 1)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 1,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                ),
            ],
          ],
        ),
      ),
    );
  }

  BorderRadius _getBorderRadius(int index, int totalItems) {
    if (totalItems == 1) {
      return BorderRadius.circular(12); // All corners rounded
    } else if (index == 0) {
      return const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ); // Top corners only
    } else if (index == totalItems - 1) {
      return const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ); // Bottom corners only
    } else {
      return BorderRadius.zero; // No rounded corners
    }
  }
}
