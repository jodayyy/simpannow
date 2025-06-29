import 'package:flutter/material.dart';
import 'package:simpannow/core/services/transaction_service.dart';
import 'package:simpannow/core/utils/toast_utils.dart';

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
          // ignore: use_build_context_synchronously
          ToastUtils.showSuccessToast(context, "Transaction deleted successfully");
        } else {
          // ignore: use_build_context_synchronously
          ToastUtils.showErrorToast(context, transactionService.errorMessage ?? "Failed to delete transaction");
        }
      },
    ),
  );
}
