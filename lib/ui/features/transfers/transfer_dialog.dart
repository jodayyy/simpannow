import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:simpannow/core/services/auth_service.dart';
import 'package:simpannow/core/services/account_service.dart';
import 'package:simpannow/core/services/transfer_service.dart';
import 'package:simpannow/core/utils/toast_utils.dart';
import 'package:simpannow/data/models/account_model.dart';

class TransferDialog extends StatefulWidget {
  const TransferDialog({super.key});

  @override
  State<TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _feeController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _fromAccountId;
  String? _toAccountId;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _feeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountService = Provider.of<AccountService>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.rightLeft),
                    const SizedBox(width: 8),
                    const Text(
                      'Transfer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(FontAwesomeIcons.xmark),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Fee (Optional)
                TextFormField(
                  controller: _feeController,
                  decoration: const InputDecoration(
                    labelText: 'Fee (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final fee = double.tryParse(value);
                    if (fee == null || fee < 0) return 'Please enter a valid fee';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // From account
                StreamBuilder<List<Account>>(
                  stream: accountService.getUserAccountsStream(
                    Provider.of<AuthService>(context, listen: false).user!.uid,
                  ),
                  builder: (context, snapshot) {
                    final accounts = snapshot.data ?? [];
                    return DropdownButtonFormField<String>(
                      value: _fromAccountId,
                      decoration: const InputDecoration(
                        labelText: 'Transfer From',
                        border: OutlineInputBorder(),
                      ),
                      items: accounts.map((a) => DropdownMenuItem(
                        value: a.id,
                        child: Row(
                          children: [
                            Text(Account.getTypeIcon(a.type), style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(a.name),
                          ],
                        ),
                      )).toList(),
                      onChanged: (v) => setState(() => _fromAccountId = v),
                      validator: (v) => v == null || v.isEmpty ? 'Please select a source account' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // To account
                StreamBuilder<List<Account>>(
                  stream: accountService.getUserAccountsStream(
                    Provider.of<AuthService>(context, listen: false).user!.uid,
                  ),
                  builder: (context, snapshot) {
                    final accounts = snapshot.data ?? [];
                    // Exclude selected from account
                    final toAccounts = accounts.where((a) => a.id != _fromAccountId).toList();
                    return DropdownButtonFormField<String>(
                      value: _toAccountId,
                      decoration: const InputDecoration(
                        labelText: 'Transfer To',
                        border: OutlineInputBorder(),
                      ),
                      items: toAccounts.map((a) => DropdownMenuItem(
                        value: a.id,
                        child: Row(
                          children: [
                            Text(Account.getTypeIcon(a.type), style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(a.name),
                          ],
                        ),
                      )).toList(),
                      onChanged: (v) => setState(() => _toAccountId = v),
                      validator: (v) => v == null || v.isEmpty ? 'Please select a destination account' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Submit
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Transfer',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.trim());
    final fee = _feeController.text.trim().isEmpty ? 0.0 : double.parse(_feeController.text.trim());
    if (_fromAccountId == _toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('From and To accounts must be different')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthService>(context, listen: false);
      await TransferService().transferFunds(
        userId: auth.user!.uid,
        fromAccountId: _fromAccountId!,
        toAccountId: _toAccountId!,
        amount: amount,
        fee: fee,
        title: _titleController.text,
        description: _descriptionController.text,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ToastUtils.showSuccessToast(context, 'Transfer completed');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(context, e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
