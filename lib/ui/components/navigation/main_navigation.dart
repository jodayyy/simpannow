import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:simpannow/ui/screens/summary/summary_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {  int _currentIndex = 0;
  
  // Holds all available screens; only Summary is functional for now
  final List<Widget> _screens = [
    const SummaryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Displays the selected screen and bottom navigation
    return Scaffold(
      body: _currentIndex == 0 ? _screens[0] : const Center(child: Text('Coming Soon')),
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
          // ignore: deprecated_member_use
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), // Updated to dynamic color
          items: const [
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.chartLine),
              label: 'Summary',
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.moneyBillWave),
              label: 'Transactions',
            ),
          ],
          onTap: (index) {
            setState(() {
              // Provide actual navigation for index 0; placeholders for others
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
