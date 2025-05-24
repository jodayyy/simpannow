import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:simpannow/ui/screens/profile/profile_page.dart';
import 'package:simpannow/core/services/auth_service.dart';
import 'package:simpannow/core/services/user_service.dart';
import 'package:simpannow/ui/features/dark_mode_toggle.dart';

import 'package:provider/provider.dart';

class SideNavigation extends StatelessWidget {
  const SideNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    // Access user data to display in the drawer header
    final userService = Provider.of<UserService>(context);
    final authService = Provider.of<AuthService>(context);
    final user = userService.currentUser;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0), // Add vertical margin
      child: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    // Shows user’s display name and profile icon
                    accountName: Text(userService.getDisplayName()),
                    accountEmail: Text(user?.email ?? ''),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        FontAwesomeIcons.user,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(FontAwesomeIcons.user),
                    title: const Text('Profile'),
                    onTap: () {
                      // Navigate to profile details
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()),
                      );
                    },
                  ),
                  const Divider(),
                ],
              ),
            ),
            // Bottom row with dark mode toggle and logout button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const DarkModeToggle(),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(FontAwesomeIcons.rightFromBracket),
                        onPressed: () => authService.signOut(),
                      ),
                      const Text('Logout', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
