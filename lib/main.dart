import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:simpannow/core/services/auth_service.dart';
import 'package:simpannow/core/services/firebase_service.dart';
import 'package:simpannow/core/services/user_service.dart';
import 'package:simpannow/core/services/transaction_service.dart';
import 'package:simpannow/core/services/account_service.dart';
import 'package:simpannow/ui/screens/auth/auth_wrapper.dart';
import 'package:simpannow/ui/theme/app_theme.dart';
import 'package:simpannow/core/services/theme_service.dart';

import 'package:provider/provider.dart';

void main() async {
  // Ensures required Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force device orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Initialize Firebase services
  await FirebaseService.initializeFirebase();
  
  // Launch the main app widget
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provides AuthService, UserService, and ThemeNotifier throughout the app
    return MultiProvider(      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => UserService()),
        ChangeNotifierProvider(create: (_) => TransactionService()),
        ChangeNotifierProvider(create: (_) => AccountService()), // NEW: Account service
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, _) => MaterialApp(
          // Sets up the main theme and entry screen
          title: 'SimpanNow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getThemeData(themeNotifier.isDarkMode),
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}
