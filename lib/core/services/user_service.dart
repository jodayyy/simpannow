import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simpannow/data/models/user_model.dart';

class UserService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch user data from Firestore
  Future<void> fetchUserData(String uid) async {
    if (_isLoading) return; // Prevent multiple simultaneous fetches
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        _currentUser = UserModel.fromMap({
          'uid': uid,
          ...data,
        });
      } else {
        // Create user document if it doesn't exist
        _currentUser = UserModel(uid: uid, email: '');
        await ensureUserDocumentExists();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to load user data. Please check your connection.";
      notifyListeners();
    }
  }

  // Get display name (username or email)
  String getDisplayName() {
    if (_currentUser == null) {
      return 'User';
    }
    
    return _currentUser!.username ?? _currentUser!.email;
  }

  // Ensure user document exists
  Future<bool> ensureUserDocumentExists() async {
    if (_currentUser == null) {
      _errorMessage = "No user logged in";
      return false;
    }
    
    try {
      // Check if document exists
      final docSnapshot = await _firestore.collection('users').doc(_currentUser!.uid).get();
      
      if (!docSnapshot.exists) {
        // Create the document
        await _firestore.collection('users').doc(_currentUser!.uid).set({
          'email': _currentUser!.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return true;
    } catch (e) {
      _errorMessage = "Failed to access user profile";
      return false;
    }
  }

  // Update username - use set with merge instead of update
  Future<bool> updateUsername(String username) async {
    if (_currentUser == null) {
      _errorMessage = "No user logged in";
      return false;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Use set with merge instead of update to handle non-existent documents
      await _firestore.collection('users').doc(_currentUser!.uid).set({
        'username': username,
      }, SetOptions(merge: true));
      
      // Update local model
      _currentUser = UserModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        username: username,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (e is FirebaseException) {
        if (e.code == 'permission-denied') {
          _errorMessage = "Permission denied. Check Firebase rules.";
        } else if (e.code == 'not-found') {
          _errorMessage = "User document not found.";
        } else {
          _errorMessage = "Firebase error: ${e.message}";
        }
      } else {
        _errorMessage = "Failed to update username";
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
