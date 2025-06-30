import 'package:flutter/material.dart';

import 'package:simpannow/core/services/auth_service.dart';
import 'package:simpannow/core/services/user_service.dart';
import 'package:simpannow/core/services/transaction_service.dart';
import 'package:simpannow/core/services/account_service.dart';
import 'package:simpannow/core/services/monthly_summary_service.dart';
import 'package:simpannow/ui/components/navigation/side_navigation.dart';
import 'package:simpannow/ui/components/navigation/top_bar.dart';
import 'package:simpannow/ui/features/summaries/financial_summary_card.dart';
import 'package:simpannow/ui/features/summaries/account_overview_card.dart';
import 'package:simpannow/ui/features/transactions/transaction_card_group.dart';
import 'package:simpannow/ui/features/transactions/add_transaction_dialog.dart';
import 'package:simpannow/ui/features/transactions/delete_transaction_dialog.dart';
import 'package:simpannow/ui/screens/transactions/transactions_page.dart';
import 'package:simpannow/data/models/transaction_model.dart';
import 'package:simpannow/data/models/account_model.dart';
import 'package:simpannow/data/models/financial_summary_model.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';

class SummaryPage extends StatefulWidget {
  // Builds the main financial summary screen with transaction tracking functionality
  final VoidCallback? onNavigateToTransactions;
  
  const SummaryPage({super.key, this.onNavigateToTransactions});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  @override
  void initState() {
    super.initState();
    // Check monthly data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkMonthlyDataUpdate();
    });
  }

  void _checkMonthlyDataUpdate() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final transactionService = Provider.of<TransactionService>(context, listen: false);
    final accountService = Provider.of<AccountService>(context, listen: false);
    final monthlySummaryService = Provider.of<MonthlySummaryService>(context, listen: false);
    
    if (authService.user != null) {
      // Get current transactions and accounts
      final transactions = transactionService.transactions;
      final accounts = accountService.accounts;
      
      // Check if we need to update monthly data
      await monthlySummaryService.checkAndSaveMonthlyData(
        authService.user!.uid,
        transactions,
        accounts,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserService>(
      builder: (context, userService, _) {
        final authService = Provider.of<AuthService>(context);
        final transactionService = Provider.of<TransactionService>(context);
        final accountService = Provider.of<AccountService>(context);
        final monthlySummaryService = Provider.of<MonthlySummaryService>(context);
        if (authService.user == null) {
          return const Scaffold(
            body: Center(child: Text('Please log in')),
          );
        }

        return Scaffold(
          appBar: TopBar(authService: authService),
          drawer: const SideNavigation(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account Overview
                StreamBuilder<List<Account>>(
                  stream: accountService.getUserAccountsStream(authService.user!.uid),
                  builder: (context, accountSnapshot) {
                    if (accountSnapshot.connectionState == ConnectionState.waiting) {
                      return const Card(
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }
                    
                    final accounts = accountSnapshot.data ?? [];
                    
                    if (accounts.isEmpty) {
                      return const SizedBox.shrink(); // Hide if no accounts
                    }
                    
                    return AccountOverviewCard(accounts: accounts);
                  },
                ),
                
                const SizedBox(height: 18),
                  // Financial Summary with real-time data
                StreamBuilder<List<Transaction>>(
                  stream: transactionService.getUserTransactionsStream(authService.user!.uid),
                  builder: (context, transactionSnapshot) {
                    if (transactionSnapshot.connectionState == ConnectionState.waiting) {
                      return const Card(
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }
                    
                    final transactions = transactionSnapshot.data ?? [];
                    
                    // Get accounts for net worth calculation
                    return StreamBuilder<List<Account>>(
                      stream: accountService.getUserAccountsStream(authService.user!.uid),
                      builder: (context, accountSnapshot) {
                        final accounts = accountSnapshot.data ?? [];
                        final summary = transactionService.getFinancialSummary(transactions, accounts);
                        
                        // Get historical data from monthly summary service
                        return StreamBuilder<List<MonthlyNetFlow>>(
                          stream: monthlySummaryService.getMonthlyHistoryStream(authService.user!.uid),
                          builder: (context, historySnapshot) {
                            final historicalData = historySnapshot.data ?? [];
                            
                            return FinancialSummaryCard(
                              summary: summary,
                              historicalData: historicalData,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Recent Transactions Section
                StreamBuilder<List<Transaction>>(
                  stream: transactionService.getUserTransactionsStream(authService.user!.uid),
                  builder: (context, snapshot) {
                    final transactions = snapshot.data ?? [];
                    
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (transactions.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              if (widget.onNavigateToTransactions != null) {
                                widget.onNavigateToTransactions!();
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TransactionsPage(),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(FontAwesomeIcons.eye, size: 16),
                            label: const Text('View All'),
                          ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                  // Transaction List
                StreamBuilder<List<Transaction>>(
                  stream: transactionService.getUserTransactionsStream(authService.user!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final transactions = snapshot.data ?? [];
                    
                    if (transactions.isEmpty) {
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
                          width: double.infinity, // Make the card use full width
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                FontAwesomeIcons.wallet,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap the + button to add your first transaction',
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
                    
                    // Show recent transactions (limit to 5)
                    final recentTransactions = transactions.take(5).toList();
                    
                    return TransactionCardGroup(
                      transactions: recentTransactions,
                      onDelete: (transactionId, transactionTitle) => deleteTransaction(
                        context,
                        transactionService,
                        authService.user!.uid,
                        transactionId,
                        transactionTitle,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 100), // Space for FAB
              ],
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

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(),
    );
  }
}
