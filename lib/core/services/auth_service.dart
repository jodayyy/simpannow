import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpannow/data/models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;

  // Keys for shared preferences
  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';

  // Getters
  User? get user => _user;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  // Setter for rememberMe
  set rememberMe(bool value) {
    _rememberMe = value;
    _saveRememberMePreference(value);
    notifyListeners();
  }

  bool get rememberMe => _rememberMe;

  // Constructor
  AuthService() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserModel();
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
    _loadRememberMePreference();
  }

  // Load remember me preference
  Future<void> _loadRememberMePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _rememberMe = prefs.getBool(_rememberMeKey) ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading remember me preference: $e');
    }
  }

  // Save remember me preference
  Future<void> _saveRememberMePreference(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, value);
    } catch (e) {
      debugPrint('Error saving remember me preference: $e');
    }
  }

  // Save email for remember me
  Future<void> saveEmail(String email) async {
    if (_rememberMe) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_savedEmailKey, email);
      } catch (e) {
        debugPrint('Error saving email: $e');
      }
    }
  }

  // Get saved email
  Future<String?> getSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return _rememberMe ? prefs.getString(_savedEmailKey) : null;
    } catch (e) {
      debugPrint('Error getting saved email: $e');
      return null;
    }
  }

  // Clear saved credentials
  Future<void> clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedEmailKey);
    } catch (e) {
      debugPrint('Error clearing saved credentials: $e');
    }
  }

  // Load user model from Firestore
  Future<void> _loadUserModel() async {
    if (_user == null) return;

    try {
      final docSnapshot = await _firestore.collection('users').doc(_user!.uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        _currentUser = UserModel.fromMap({
          'uid': _user!.uid,
          ...data,
        });
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user model: $e');
    }
  }

  // Register with email and password
  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'username': null, // Initialize username as null
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getMessageFromErrorCode(e.code);

      // Special handling for configuration-not-found error
      if (e.code == 'configuration-not-found' || e.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
        _errorMessage = "Firebase authentication is not properly configured. Please contact support.";
      }

      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "An unexpected error occurred: $e";
      notifyListeners();
      return false;
    }
  }

  // Update username
  Future<bool> updateUsername(String username) async {
    if (_user == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'username': username,
      });

      // Update local model
      if (_currentUser != null) {
        _currentUser = UserModel(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          username: username,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to update username: $e";
      notifyListeners();
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save email if remember me is enabled
      if (_rememberMe) {
        await saveEmail(email);
      } else {
        await clearSavedCredentials();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getMessageFromErrorCode(e.code);

      // Special handling for configuration-not-found error
      if (e.code == 'configuration-not-found' || e.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
        _errorMessage = "Firebase authentication is not properly configured. Please contact support.";
      }

      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "An unexpected error occurred: $e";
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (!_rememberMe) {
      await clearSavedCredentials();
    }
    await _auth.signOut();
  }

  // Helper method to get user-friendly error messages
  String _getMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case "user-not-found":
        return "No user found with this email.";
      case "wrong-password":
        return "Wrong password provided.";
      case "email-already-in-use":
        return "The email address is already in use.";
      case "invalid-email":
        return "The email address is not valid.";
      case "weak-password":
        return "The password is too weak.";
      case "operation-not-allowed":
        return "Email/password accounts are not enabled. Please contact support.";
      case "configuration-not-found":
        return "Firebase configuration error. Please contact support.";
      default:
        return "An undefined error occurred. Please try again later.";
    }
  }
}
