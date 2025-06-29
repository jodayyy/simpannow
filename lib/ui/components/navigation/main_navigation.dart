import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:simpannow/ui/screens/summary/summary_page.dart';
import 'package:simpannow/ui/screens/transactions/transactions_page.dart';
import 'package:simpannow/ui/screens/accounts/accounts_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {  int _currentIndex = 0;
  
  // Holds all available screens
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      SummaryPage(
        onNavigateToTransactions: () {
          setState(() {
            _currentIndex = 1; // Switch to Transactions tab
          });
        },
      ),
      const TransactionsPage(),
      const AccountsPage(), // NEW: Accounts page
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Displays the selected screen and bottom navigation
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          // Controls which tab is active
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,          selectedItemColor: Theme.of(context).colorScheme.primary, // Updated to dynamic color
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), // Updated to dynamic color
          items: const [
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.chartLine),
              label: 'Summary',
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.moneyBillWave),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.piggyBank),
              label: 'Accounts',
            ),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
