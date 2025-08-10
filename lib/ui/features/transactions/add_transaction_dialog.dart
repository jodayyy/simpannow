import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:simpannow/core/services/auth_service.dart';
import 'package:simpannow/core/services/transaction_service.dart';
import 'package:simpannow/core/services/account_service.dart';
import 'package:simpannow/core/utils/toast_utils.dart';
import 'package:simpannow/data/models/transaction_model.dart';
import 'package:simpannow/data/models/account_model.dart';

class AddTransactionDialog extends StatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TransactionType _selectedType = TransactionType.EXPENSE;
  String _selectedCategory = 'Food';
  String? _selectedAccountId; // NEW: Optional account selection
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionService = Provider.of<TransactionService>(context);
    final accountService = Provider.of<AccountService>(context);
    
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
                    const Icon(FontAwesomeIcons.plus),
                    const SizedBox(width: 8),
                    const Text(
                      'Add Transaction',
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
              
                // Transaction Type Toggle
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedType = TransactionType.INCOME),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.INCOME 
                                  ? Colors.green 
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.arrowTrendUp,
                                  color: _selectedType == TransactionType.INCOME 
                                      ? Colors.white 
                                      : Colors.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Income',
                                  style: TextStyle(
                                    color: _selectedType == TransactionType.INCOME 
                                        ? Colors.white 
                                        : Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedType = TransactionType.EXPENSE),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedType == TransactionType.EXPENSE 
                                  ? Colors.red 
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.arrowTrendDown,
                                  color: _selectedType == TransactionType.EXPENSE 
                                      ? Colors.white 
                                      : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Expense',
                                  style: TextStyle(
                                    color: _selectedType == TransactionType.EXPENSE 
                                        ? Colors.white 
                                        : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
                const SizedBox(height: 16),
              
                // Title Field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
              
                const SizedBox(height: 16),
              
                // Amount Field
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
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
              
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: transactionService.getCategoryNames().map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Text(
                            transactionService.getCategoryIcon(category),
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(category),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
              
                const SizedBox(height: 16),
              
                // Account Dropdown (Optional)
                StreamBuilder<List<Account>>(
                  stream: accountService.getUserAccountsStream(
                    Provider.of<AuthService>(context, listen: false).user?.uid ?? ''
                  ),
                  builder: (context, snapshot) {
                    final accounts = snapshot.data ?? [];
                    
                    if (accounts.isEmpty) {
                      return const SizedBox.shrink(); // Don't show if no accounts
                    }
                    
                    return DropdownButtonFormField<String?>(
                      value: _selectedAccountId,
                      decoration: const InputDecoration(
                        labelText: 'Account (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Row(
                            children: [
                              Text('💰', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text('General (No Account)'),
                            ],
                          ),
                        ),
                        ...accounts.map((account) {
                          return DropdownMenuItem<String?>(
                            value: account.id,
                            child: Row(
                              children: [
                                Text(
                                  Account.getTypeIcon(account.type),
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Text(account.name),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedAccountId = value);
                      },
                    );
                  },
                ),
              
                const SizedBox(height: 16),
              
                // Description Field (Optional)
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              
                const SizedBox(height: 24),
              
                // Save Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveTransaction,
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
                          'Save Transaction',
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

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final transactionService = Provider.of<TransactionService>(context, listen: false);

    if (authService.user == null) {
      ToastUtils.showErrorToast(context, "User not authenticated");
      setState(() => _isLoading = false);
      return;
    }    final transaction = Transaction(
      id: '', // Will be set by Firestore
      userId: authService.user!.uid,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      type: _selectedType,
      category: _selectedCategory,
      createdAt: DateTime.now(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      accountId: _selectedAccountId, // NEW: Optional account reference
    );

    final success = await transactionService.addTransaction(transaction);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ToastUtils.showSuccessToast(context, "Transaction added successfully!");
        Navigator.of(context).pop();
      } else {
        ToastUtils.showErrorToast(context, transactionService.errorMessage ?? "Failed to add transaction");
      }
    }
  }
}
