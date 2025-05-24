import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:simpannow/ui/screens/auth/login_page.dart';
import 'package:simpannow/ui/screens/auth/register_page.dart';
import 'package:simpannow/ui/components/navigation/main_navigation.dart';
import 'package:simpannow/core/services/auth_service.dart';
import 'package:simpannow/core/services/user_service.dart';
import 'package:simpannow/features/theme/dark_mode_toggle.dart';

class AuthWrapper extends StatefulWidget {
  // Decides whether user sees login/register or main navigation
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final PageController _pageController = PageController();
  // Controls slide animations between login and register pages

  void _goToLogin() {
    // Animates PageView to the login page
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToRegister() {
    // Animates PageView to the register page
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    // Fetches user data if the user is already logged in
    super.didChangeDependencies();
    final authService = Provider.of<AuthService>(context);
    
    if (authService.isLoggedIn && authService.user != null) {
      // Use Future.microtask to schedule the fetch after the build is complete
      Future.microtask(() {
        final userService = Provider.of<UserService>(context, listen: false);
        userService.fetchUserData(authService.user!.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Checks auth state to show correct screen
    final authService = Provider.of<AuthService>(context);
    
    // Show splash screen while checking auth state
    if (authService.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (authService.isLoggedIn && authService.user != null) {
      // Displays main navigation after fetching user data
      final userService = Provider.of<UserService>(context, listen: false);
      
      // Return a FutureBuilder to wait for user data to load
      return FutureBuilder(
        future: userService.fetchUserData(authService.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return const MainNavigation();
        },
      );
    } else {
      return Scaffold(
                body: Stack(
          children: [
PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            LoginPage(onSwitchToRegister: _goToRegister),
            RegisterPage(onSwitchToLogin: _goToLogin),
],
            ),
            const Positioned(
              top: 20,
              right: 20,
              child: DarkModeToggle(),
            ),
          ],
        ),
      );
    }
  }
}
