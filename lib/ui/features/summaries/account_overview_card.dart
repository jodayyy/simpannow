import 'package:flutter/material.dart';
import 'package:simpannow/data/models/account_model.dart';

class AccountOverviewCard extends StatelessWidget {
  final List<Account> accounts;

  const AccountOverviewCard({
    super.key,
    required this.accounts,
  });

  @override
  Widget build(BuildContext context) {
    final totalBalance = accounts.fold(0.0, (sum, account) => sum + account.balance);
    final accountTypeBreakdown = _calculateAccountTypeBreakdown(accounts, totalBalance);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Overview title with legend button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Account Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  onPressed: () => _showAccountLegendDialog(context),
                  icon: Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Total Net Worth
            Center(
              child: Column(
                children: [
                  const Text(
                    'Total Net Worth',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RM ${totalBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: totalBalance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Account type breakdown with Word (left) → Percentage (right), Graphic (below)
            ...accountTypeBreakdown.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  children: [
                    // Top row: Word (left) and Percentage (right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Account Type Name
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        // Right: Percentage
                        Text(
                          '${(entry.value['percentage'] ?? 0).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Bottom: Progress bar graphic
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey[200],
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (entry.value['percentage'] ?? 0) / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _getAccountTypeColor(entry.key),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            
            const SizedBox(height: 16),
            
            // Account summary with icons and amounts
            _buildAccountTypeSummary(accountTypeBreakdown),
          ],
        ),
      ),
    );
  }

  Map<String, Map<String, double>> _calculateAccountTypeBreakdown(List<Account> accounts, double totalBalance) {
    final Map<String, double> typeBalances = {};
    
    // Group accounts by type and sum balances
    for (final account in accounts) {
      typeBalances[account.type] = (typeBalances[account.type] ?? 0) + account.balance;
    }
    
    // Calculate percentages
    final Map<String, Map<String, double>> breakdown = {};
    typeBalances.forEach((type, balance) {
      breakdown[type] = {
        'balance': balance,
        'percentage': totalBalance > 0 ? (balance / totalBalance) * 100 : 0,
      };
    });
    
    // Sort by balance (highest first)
    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => (b.value['balance'] ?? 0).compareTo(a.value['balance'] ?? 0));
    
    return Map.fromEntries(sortedEntries);
  }

  Color _getAccountTypeColor(String accountType) {
    switch (accountType) {
      case Account.typeSavings:
        return Colors.blue;
      case Account.typeSpending:
        return Colors.orange;
      case Account.typeInvestment:
        return Colors.green;
      case Account.typeCash:
        return Colors.purple;
      case Account.typeEWallet:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAccountTypeSummary(Map<String, Map<String, double>> breakdown) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: breakdown.entries.take(3).map((entry) {
          return Expanded(
            child: Column(
              children: [
                Text(
                  Account.getTypeIcon(entry.key),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  _getShortTypeName(entry.key),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  'RM ${(entry.value['balance'] ?? 0).toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: (entry.value['balance'] ?? 0) >= 0 ? Colors.green : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getShortTypeName(String accountType) {
    switch (accountType) {
      case Account.typeSavings:
        return 'Savings';
      case Account.typeSpending:
        return 'Spending';
      case Account.typeInvestment:
        return 'Invest';
      case Account.typeCash:
        return 'Cash';
      case Account.typeEWallet:
        return 'E-Wallet';
      default:
        return accountType;
    }
  }

  void _showAccountLegendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Account Overview Guide'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      border: Border.all(color: Colors.blue.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Total Net Worth: Sum of all account balances',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      border: Border.all(color: Colors.green.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Account Types: Breakdown by category (Savings, Spending, etc.)',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      border: Border.all(color: Colors.orange.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Percentages: Each account type as % of total net worth',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}
