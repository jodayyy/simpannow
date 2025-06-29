import 'package:flutter/material.dart';
import 'package:simpannow/core/services/account_service.dart';
import 'package:simpannow/core/utils/toast_utils.dart';

class DeleteAccountDialog extends StatefulWidget {
  final String accountName;
  final String userId;
  final String accountId;
  final VoidCallback onConfirm;

  const DeleteAccountDialog({
    super.key,
    required this.accountName,
    required this.userId,
    required this.accountId,
    required this.onConfirm,
  });

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  int? _transactionCount;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactionCount();
  }

  Future<void> _loadTransactionCount() async {
    final accountService = AccountService();
    final count = await accountService.getLinkedTransactionCount(widget.userId, widget.accountId);
    setState(() {
      _transactionCount = count;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: _isLoading
          ? const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to delete "${widget.accountName}"?'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withAlpha(50)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Warning',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This action cannot be undone.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_transactionCount != null && _transactionCount! > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'You will also be deleting ${_transactionCount!} transaction${_transactionCount! == 1 ? '' : 's'} linked to this account.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isLoading ? null : () {
            Navigator.of(context).pop();
            widget.onConfirm();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
void deleteAccount(
  BuildContext context,
  AccountService accountService,
  String userId,
  String accountId,
  String accountName,
) {
  showDialog(
    context: context,
    builder: (context) => DeleteAccountDialog(
      accountName: accountName,
      userId: userId,
      accountId: accountId,
      onConfirm: () async {
        final success = await accountService.deleteAccount(userId, accountId);
        if (context.mounted) {
          if (success) {
            ToastUtils.showSuccessToast(context, "Account and linked transactions deleted successfully!");
          } else {
            ToastUtils.showErrorToast(context, accountService.errorMessage ?? "Failed to delete account");
          }
        }
      },
    ),
  );
}
