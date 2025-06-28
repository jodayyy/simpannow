import 'package:flutter/material.dart';

import 'package:simpannow/core/services/auth_service.dart';
import 'package:simpannow/core/services/user_service.dart';
import 'package:simpannow/core/services/transaction_service.dart';
import 'package:simpannow/ui/components/navigation/side_navigation.dart';
import 'package:simpannow/ui/components/navigation/top_bar.dart';
import 'package:simpannow/ui/screens/summary/financial_summary_card.dart';
import 'package:simpannow/ui/features/transactions/transaction_list_item.dart';
import 'package:simpannow/ui/features/transactions/add_transaction_dialog.dart';
import 'package:simpannow/ui/features/transactions/delete_transaction_dialog.dart';
import 'package:simpannow/data/models/transaction_model.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';

class SummaryPage extends StatelessWidget {
  // Builds the main financial summary screen with transaction tracking functionality
  const SummaryPage({super.key});

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
                  // Welcome message
                  Center(
                    child: Text(
                      'Welcome, ${userService.getDisplayName()}!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 18),
                    // Financial Summary with real-time data
                  StreamBuilder<List<Transaction>>(
                    stream: transactionService.getUserTransactionsStream(authService.user!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        );
                      }
                      
                      final transactions = snapshot.data ?? [];
                      final summary = transactionService.getFinancialSummary(transactions);
                      
                      return FinancialSummaryCard(summary: summary);
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Transactions Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (transactionService.transactions.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            // TODO: Navigate to full transactions page
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Full transactions page coming soon!"),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                          icon: const Icon(FontAwesomeIcons.eye, size: 16),
                          label: const Text('View All'),
                        ),
                    ],
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
                      
                      // Show recent transactions (limit to 10)
                      final recentTransactions = transactions.take(10).toList();
                      
                      return Column(
                        children: recentTransactions.map((transaction) {
                          return TransactionListItem(
                            transaction: transaction,
                            onDelete: () => deleteTransaction(
                              context,
                              transactionService,
                              authService.user!.uid,
                              transaction.id,
                              transaction.title,
                            ),
                          );
                        }).toList(),
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

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(),
    );
  }
}
