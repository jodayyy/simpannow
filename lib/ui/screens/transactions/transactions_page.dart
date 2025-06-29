import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:simpannow/core/services/auth_service.dart';
import 'package:simpannow/core/services/user_service.dart';
import 'package:simpannow/core/services/transaction_service.dart';
import 'package:simpannow/core/services/account_service.dart';
import 'package:simpannow/ui/components/navigation/side_navigation.dart';
import 'package:simpannow/ui/components/navigation/top_bar.dart';
import 'package:simpannow/data/models/transaction_model.dart';
import 'package:simpannow/data/models/account_model.dart';
import 'package:simpannow/ui/features/transactions/transaction_card_group.dart';
import 'package:simpannow/ui/features/transactions/add_transaction_dialog.dart';
import 'package:simpannow/ui/features/transactions/delete_transaction_dialog.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String _selectedFilter = 'All';
  String _selectedCategory = 'All';
  String _selectedAccount = 'All'; // NEW: Account filter
  String _sortBy = 'Date (Newest)';

  final List<String> _filterOptions = ['All', 'Income', 'Expense'];
  final List<String> _sortOptions = [
    'Date (Newest)',
    'Date (Oldest)',
    'Amount (High to Low)',
    'Amount (Low to High)',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserService, AuthService, TransactionService>(
      builder: (context, userService, authService, transactionService, _) {
        if (authService.user == null) {
          return const Scaffold(
            body: Center(child: Text('Please log in')),
          );
        }

        return Scaffold(
          appBar: TopBar(authService: authService),
          drawer: const SideNavigation(),
          body: RefreshIndicator(
            onRefresh: () async {
              await userService.fetchUserData(authService.user!.uid);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      'All Transactions',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 18),
                  
                  // Filter Card
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Filter Grid (2x2)
                          Column(
                            children: [
                              // First Row: Type and Category
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFilterDropdown(
                                      'Type',
                                      _selectedFilter,
                                      _filterOptions,
                                      (value) => setState(() => _selectedFilter = value!),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildCategoryDropdown(transactionService),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Second Row: Account and Sort
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildAccountDropdown(),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildFilterDropdown(
                                      'Sort',
                                      _sortBy,
                                      _sortOptions,
                                      (value) => setState(() => _sortBy = value!),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Transaction List
                  StreamBuilder<List<Transaction>>(
                    stream: transactionService.getUserTransactionsStream(authService.user!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Card(
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(child: Text('Error: ${snapshot.error}')),
                          ),
                        );
                      }

                      final allTransactions = snapshot.data ?? [];
                      final filteredTransactions = _filterAndSortTransactions(allTransactions);

                      if (filteredTransactions.isEmpty) {
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1,
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  FontAwesomeIcons.magnifyingGlass,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No transactions found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your filters or add a new transaction',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Transaction count
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              '${filteredTransactions.length} Transaction${filteredTransactions.length == 1 ? '' : 's'} Found',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Single card for all transactions
                          TransactionCardGroup(
                            transactions: filteredTransactions,
                            onDelete: (transactionId, transactionTitle) => deleteTransaction(
                              context,
                              transactionService,
                              authService.user!.uid,
                              transactionId,
                              transactionTitle,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddTransactionDialog(context),
            tooltip: 'Add Transaction',
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1,
              ),
            ),
            icon: Icon(
              FontAwesomeIcons.plus,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            label: Text(
              'Add Transaction',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.primary,
            ),
            isDense: true,
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(TransactionService transactionService) {
    final categories = ['All', ...transactionService.getCategoryNames()];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButton<String>(
            value: _selectedCategory,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.primary,
            ),
            isDense: true,
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    if (category != 'All') ...[
                      Text(
                        transactionService.getCategoryIcon(category),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDropdown() {
    return Consumer<AccountService>(
      builder: (context, accountService, _) {
        return StreamBuilder<List<Account>>(
          stream: accountService.getUserAccountsStream(
            Provider.of<AuthService>(context, listen: false).user?.uid ?? ''
          ),
          builder: (context, snapshot) {
            final accounts = snapshot.data ?? [];
            final accountOptions = [
              'All',
              'General (No Account)',
              ...accounts.map((account) => account.name)
            ];
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedAccount,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    isDense: true,
                    items: accountOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Row(
                          children: [
                            if (option == 'All') ...[
                              const Text('📊', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                            ] else if (option == 'General (No Account)') ...[
                              const Text('💰', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                            ] else ...[
                              // Find the account and show its icon
                              Builder(
                                builder: (context) {
                                  final account = accounts.firstWhere(
                                    (account) => account.name == option,
                                    orElse: () => Account(
                                      id: '', userId: '', name: '', type: 'Cash', 
                                      balance: 0, description: '', createdAt: DateTime.now()
                                    )
                                  );
                                  return Text(
                                    Account.getTypeIcon(account.type),
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedAccount = value!),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Transaction> _filterAndSortTransactions(List<Transaction> transactions) {
    var filtered = transactions.where((transaction) {
      // Filter by type
      if (_selectedFilter != 'All') {
        if (_selectedFilter == 'Income' && transaction.type != TransactionType.INCOME) {
          return false;
        }
        if (_selectedFilter == 'Expense' && transaction.type != TransactionType.EXPENSE) {
          return false;
        }
      }

      // Filter by category
      if (_selectedCategory != 'All' && transaction.category != _selectedCategory) {
        return false;
      }

      // Filter by account
      if (_selectedAccount != 'All') {
        if (_selectedAccount == 'General (No Account)') {
          // Show transactions with no account or empty accountId
          if (transaction.accountId != null && transaction.accountId!.isNotEmpty) {
            return false;
          }
        } else {
          // Show transactions linked to the selected account
          // Find the account by name and check if transaction.accountId matches
          final accountService = Provider.of<AccountService>(context, listen: false);
          
          // Get accounts synchronously from the current state
          final accounts = accountService.accounts;
          final selectedAccount = accounts.firstWhere(
            (account) => account.name == _selectedAccount,
            orElse: () => Account(
              id: '', userId: '', name: '', type: '', 
              balance: 0, description: '', createdAt: DateTime.now()
            )
          );
          
          if (selectedAccount.id.isEmpty || transaction.accountId != selectedAccount.id) {
            return false;
          }
        }
      }

      return true;
    }).toList();

    // Sort transactions
    switch (_sortBy) {
      case 'Date (Newest)':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Date (Oldest)':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'Amount (High to Low)':
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Amount (Low to High)':
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return filtered;
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(),
    );
  }
}
