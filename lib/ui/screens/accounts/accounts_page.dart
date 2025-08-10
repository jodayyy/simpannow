import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:simpannow/core/services/auth_service.dart';
import 'package:simpannow/core/services/user_service.dart';
import 'package:simpannow/core/services/account_service.dart';
import 'package:simpannow/ui/components/navigation/side_navigation.dart';
import 'package:simpannow/ui/components/navigation/top_bar.dart';
import 'package:simpannow/data/models/account_model.dart';
import 'package:simpannow/ui/features/accounts/add_account_dialog.dart';
import 'package:simpannow/ui/features/accounts/delete_account_dialog.dart';
import 'package:simpannow/ui/features/accounts/edit_account_dialog.dart';
import 'package:simpannow/ui/features/transfers/transfer_dialog.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<UserService, AuthService, AccountService>(
      builder: (context, userService, authService, accountService, _) {
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
                      'My Accounts',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 18),
                  
                  // Accounts List
                  StreamBuilder<List<Account>>(
                    stream: accountService.getUserAccountsStream(authService.user!.uid),
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

                      final accounts = snapshot.data ?? [];

                      if (accounts.isEmpty) {
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
                                  FontAwesomeIcons.piggyBank,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No accounts yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the + button to add your first account',
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
                          // Account count
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              '${accounts.length} Account${accounts.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Accounts list
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: accounts.length,
                            itemBuilder: (context, index) {
                              final account = accounts[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildAccountCard(account),
                              );
                            },
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
          floatingActionButton: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Transfer FAB (left)
              FloatingActionButton(
                heroTag: 'transferFab',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const TransferDialog(),
                  );
                },
                tooltip: 'Transfer',
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: CircleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                ),
                child: Icon(
                  FontAwesomeIcons.rightLeft,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              // Add Account FAB (right)
              FloatingActionButton(
                heroTag: 'addAccountFab',
                onPressed: () => _showAddAccountDialog(context),
                tooltip: 'Add Account',
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: CircleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                ),
                child: Icon(
                  FontAwesomeIcons.plus,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountCard(Account account) {
    final borderRadius = BorderRadius.circular(12);
    
    final dismissibleContent = Dismissible(
      key: Key(account.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: borderRadius,
        ),
        child: const Icon(
          FontAwesomeIcons.penToSquare,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: borderRadius,
        ),
        child: const Icon(
          FontAwesomeIcons.trash,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        final authService = Provider.of<AuthService>(context, listen: false);
        final accountService = Provider.of<AccountService>(context, listen: false);

        if (direction == DismissDirection.endToStart) {
          // Delete account (swipe left)
          deleteAccount(
            context,
            accountService,
            authService.user!.uid,
            account.id,
            account.name,
          );
        } else if (direction == DismissDirection.startToEnd) {
          // Edit account (swipe right)
          showDialog(
            context: context,
            builder: (context) => EditAccountDialog(account: account),
          );
        }
        return false; // Prevent automatic dismissal
      },
      onDismissed: (direction) {
        // This won't be called due to return false above, but keeping for consistency
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Account type icon
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                Account.getTypeIcon(account.type),
                style: const TextStyle(fontSize: 24),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Account details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account name with type
                  Text(
                    '${account.name} (${account.type})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Description
                  if (account.description.isNotEmpty)
                    Text(
                      account.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Balance
            Text(
              account.balance >= 0 
                ? 'RM${account.balance.toStringAsFixed(2)}'
                : '-RM${account.balance.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: account.balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );

    // Wrap in a card with proper clipping (matching transaction pattern)
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: dismissibleContent,
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddAccountDialog(),
    );
  }
}
