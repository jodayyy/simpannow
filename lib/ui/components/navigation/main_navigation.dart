import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:simpannow/ui/screens/home/home_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  // Holds all available screens; only Home is functional for now
  final List<Widget> _screens = [
    const HomePage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Displays the selected screen and bottom navigation
    return Scaffold(
      body: _currentIndex == 0 ? _screens[0] : const Center(child: Text('Coming Soon')),
      bottomNavigationBar: BottomNavigationBar(
        // Controls which tab is active
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary, // Updated to dynamic color
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), // Updated to dynamic color
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house),
            label: 'Home',
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
    );
  }
}
