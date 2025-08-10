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

class EditTransactionDialog extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionDialog({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late TransactionType _selectedType;
  late String _selectedCategory;
  String? _selectedAccountId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with existing transaction data
    _titleController.text = widget.transaction.title;
    _amountController.text = widget.transaction.amount.toStringAsFixed(2);
    _descriptionController.text = widget.transaction.description ?? '';
    _selectedType = widget.transaction.type;
    _selectedCategory = widget.transaction.category;
    _selectedAccountId = widget.transaction.accountId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
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
                      'Edit Transaction',
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
                
                // Title field
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
                
                // Amount field
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
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
                
                // Category dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: TransactionService.categories.keys.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Text(
                            TransactionService.categories[category] ?? '📝',
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
                
                // Account dropdown
                StreamBuilder<List<Account>>(
                  stream: accountService.getUserAccountsStream(
                    Provider.of<AuthService>(context, listen: false).user!.uid,
                  ),
                  builder: (context, snapshot) {
                    final accounts = snapshot.data ?? [];
                    
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
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedAccountId = value);
                      },
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                
                const SizedBox(height: 24),
                
                // Update button
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateTransaction,
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
                          'Update Transaction',
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

  Future<void> _updateTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final transactionService = Provider.of<TransactionService>(context, listen: false);

      final amount = double.parse(_amountController.text);
      
      final updatedTransaction = Transaction(
        id: widget.transaction.id,
        title: _titleController.text.trim(),
        amount: amount,
        type: _selectedType,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        accountId: _selectedAccountId,
        userId: widget.transaction.userId,
        createdAt: widget.transaction.createdAt,
      );

      final success = await transactionService.updateTransaction(
        authService.user!.uid,
        updatedTransaction,
        widget.transaction, // Pass original transaction for balance calculations
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ToastUtils.showSuccessToast(context, "Transaction updated successfully!");
        } else {
          ToastUtils.showErrorToast(context, transactionService.errorMessage ?? "Failed to update transaction");
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