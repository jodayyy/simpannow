import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static FirebaseAnalytics? analytics;
  
  static Future<void> initializeFirebase() async {
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyDDYM3Fc-QBgk2bUT05nqddjnXytyWvYWE",
            authDomain: "simpannow.firebaseapp.com",
            projectId: "simpannow",
            storageBucket: "simpannow.appspot.com",
            messagingSenderId: "215961662014",
            appId: "1:215961662014:web:8b9431a83eecbbc908d76f",
            measurementId: "G-EQ05NL6WZC",
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
      
      // Initialize Analytics
      analytics = FirebaseAnalytics.instance;
      
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
      if (e is FirebaseException) {
        debugPrint('Firebase error code: ${e.code}');
      }
    }
  }
}
