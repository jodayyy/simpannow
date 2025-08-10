import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:simpannow/core/services/account_service.dart';
import 'package:simpannow/core/utils/toast_utils.dart';
import 'package:simpannow/data/models/account_model.dart';

class EditAccountDialog extends StatefulWidget {
  final Account account;

  const EditAccountDialog({
    super.key,
    required this.account,
  });

  @override
  State<EditAccountDialog> createState() => _EditAccountDialogState();
}

class _EditAccountDialogState extends State<EditAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late String _selectedType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with existing account data
    _nameController.text = widget.account.name;
    _balanceController.text = widget.account.balance.toStringAsFixed(2);
    _descriptionController.text = widget.account.description;
    _selectedType = widget.account.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.9, // Max 90% of screen height
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
                    const Icon(FontAwesomeIcons.penToSquare),
                    const SizedBox(width: 8),
                    const Text(
                      'Edit Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                
                // Account Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an account name';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Account Type dropdown
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Account Type',
                    border: OutlineInputBorder(),
                  ),
                  items: Account.accountTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Text(
                            Account.getTypeIcon(type),
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(type),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Initial Balance field
                TextFormField(
                  controller: _balanceController,
                  decoration: const InputDecoration(
                    labelText: 'Current Balance',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a balance';
                    }
                    final balance = double.tryParse(value);
                    if (balance == null) {
                      return 'Please enter a valid balance';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Update button
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateAccount,
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
                          'Update Account',
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

  Future<void> _updateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final accountService = Provider.of<AccountService>(context, listen: false);

      final balance = double.parse(_balanceController.text);
      
      final updatedAccount = Account(
        id: widget.account.id,
        userId: widget.account.userId,
        name: _nameController.text.trim(),
        type: _selectedType,
        balance: balance,
        description: _descriptionController.text.trim(),
        createdAt: widget.account.createdAt,
      );

      final success = await accountService.updateAccount(updatedAccount);

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ToastUtils.showSuccessToast(context, "Account updated successfully!");
        } else {
          ToastUtils.showErrorToast(context, accountService.errorMessage ?? "Failed to update account");
        }
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast(context, "Error: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}