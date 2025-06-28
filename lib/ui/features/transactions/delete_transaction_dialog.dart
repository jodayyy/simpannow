import 'package:flutter/material.dart';
import 'package:simpannow/core/services/transaction_service.dart';

class DeleteTransactionDialog extends StatelessWidget {
  final String transactionTitle;
  final VoidCallback onConfirm;

  const DeleteTransactionDialog({
    super.key,
    required this.transactionTitle,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Transaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: Text('Are you sure you want to delete "$transactionTitle"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

void deleteTransaction(
  BuildContext context,
  TransactionService transactionService,
  String userId,
  String transactionId,
  String transactionTitle,
) async {
  showDialog(
    context: context,
    builder: (context) => DeleteTransactionDialog(
      transactionTitle: transactionTitle,
      onConfirm: () async {
        final success = await transactionService.deleteTransaction(userId, transactionId);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Transaction deleted successfully"),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(transactionService.errorMessage ?? "Failed to delete transaction"),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    ),
  );
}
