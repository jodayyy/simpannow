import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:simpannow/core/services/auth_service.dart';
import 'package:simpannow/core/services/account_service.dart';
import 'package:simpannow/core/utils/toast_utils.dart';
import 'package:simpannow/data/models/account_model.dart';

class AddAccountDialog extends StatefulWidget {
  const AddAccountDialog({super.key});

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = Account.typeSpending;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountService = Provider.of<AccountService>(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(FontAwesomeIcons.plus),
                  const SizedBox(width: 8),
                  const Text(
                    'Add Account',
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
              
              // Account Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Account Name',
                  prefixIcon: Icon(FontAwesomeIcons.tag, size: 16),
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
              
              // Account Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Account Type',
                  prefixIcon: Icon(FontAwesomeIcons.list, size: 16),
                  border: OutlineInputBorder(),
                ),
                items: accountService.getAccountTypes().map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Text(
                          accountService.getAccountTypeIcon(type),
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
              
              // Balance Field
              TextFormField(
                controller: _balanceController,
                decoration: const InputDecoration(
                  labelText: 'Initial Balance',
                  prefixIcon: Icon(FontAwesomeIcons.dollarSign, size: 16),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an initial balance';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(FontAwesomeIcons.noteSticky, size: 16),
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
              
              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveAccount,
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
                        'Save Account',
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
    );
  }

  void _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final accountService = Provider.of<AccountService>(context, listen: false);

    if (authService.user == null) {
      ToastUtils.showErrorToast(context, "User not authenticated");
      setState(() => _isLoading = false);
      return;
    }

    final account = Account(
      id: '', // Will be set by Firestore
      userId: authService.user!.uid,
      name: _nameController.text.trim(),
      type: _selectedType,
      balance: double.parse(_balanceController.text.trim()),
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await accountService.addAccount(account);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ToastUtils.showSuccessToast(context, "Account added successfully!");
        Navigator.of(context).pop();
      } else {
        ToastUtils.showErrorToast(context, accountService.errorMessage ?? "Failed to add account");
      }
    }
  }
}
