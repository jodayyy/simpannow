import 'package:flutter/material.dart';

import 'package:simpannow/core/services/auth_service.dart';
import 'package:simpannow/core/services/user_service.dart';
import 'package:simpannow/ui/components/navigation/side_navigation.dart';
import 'package:simpannow/ui/components/navigation/top_bar.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  // Builds the main home screen, displaying navigation and user data
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to explicitly listen to UserService changes
    return Consumer<UserService>(
      builder: (context, userService, _) {
        final authService = Provider.of<AuthService>(context);
        
        return Scaffold(
          // Replaced inline app bar with the new TopBar component
          appBar: TopBar(authService: authService),
          drawer: const SideNavigation(),
          body: RefreshIndicator(
            onRefresh: () async {
              // Refresh user data when pulled down
              if (authService.user != null) {
                await userService.fetchUserData(authService.user!.uid);
              }
            },
            child: ListView(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                'Welcome, ${userService.getDisplayName()}!',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            // Quick add transaction button
            onPressed: () {
              // Quick add transaction
            },
            tooltip: 'Add Transaction',
            child: const Icon(FontAwesomeIcons.plus),
          ),
        );
      },
    );
  }
}
