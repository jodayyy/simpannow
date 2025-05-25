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
            apiKey: "YOUR_GOOGLE_API_KEY",
            authDomain: "YOUR_AUTH_DOMAIN",
            projectId: "YOUR_PROJECT_ID",
            storageBucket: "YOUR_STORAGE_BUCKET",
            messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
            appId: "YOUR_APP_ID",
            measurementId: "YOUR_MEASUREMENT_ID",
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
