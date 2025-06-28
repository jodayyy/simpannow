import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simpannow/data/models/transaction_model.dart' as models;
import 'package:simpannow/data/models/financial_summary_model.dart';

class TransactionService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    List<models.Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<models.Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Predefined categories
  static const Map<String, String> categories = {
    'Food': '🍕',
    'Transport': '🚗',
    'Entertainment': '🎬',
    'Shopping': '🛒',
    'Healthcare': '🏥',
    'Education': '📚',
    'Work': '💼',
    'Bills': '💳',
    'Other': '📝',
  };
  // Add a new transaction
  Future<bool> addTransaction(models.Transaction transaction) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Ensure user document exists first
      final userDocRef = _firestore.collection('users').doc(transaction.userId);
      final userDoc = await userDocRef.get();
      
      if (!userDoc.exists) {
        debugPrint('User document does not exist, creating it...');
        await userDocRef.set({
          'email': '', // Will be updated by user service
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint('User document created successfully');
      }

      final docRef = _firestore
          .collection('users')
          .doc(transaction.userId)
          .collection('transactions')
          .doc();

      debugPrint('Firestore Path: users/${transaction.userId}/transactions/${docRef.id}');
      debugPrint('Transaction Data: ${transaction.toMap()}');
      final transactionWithId = transaction.copyWith(id: docRef.id);
      await docRef.set(transactionWithId.toMap());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to add transaction: $e";
      debugPrint('Error: $e');
      notifyListeners();
      return false;
    }
  }  // Get transactions stream for a user
  Stream<List<models.Transaction>> getUserTransactionsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final transactions = snapshot.docs
          .map((doc) => models.Transaction.fromMap(doc.data()))
          .toList();
      _transactions = transactions;
      return transactions;
    });
  }

  // Get financial summary
  FinancialSummary getFinancialSummary(List<models.Transaction> transactions) {
    return FinancialSummary.fromTransactions(transactions);
  }

  // Delete a transaction
  Future<bool> deleteTransaction(String userId, String transactionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .delete();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to delete transaction: $e";
      notifyListeners();
      return false;
    }
  }

  // Get category icon
  String getCategoryIcon(String category) {
    return categories[category] ?? '📝';
  }

  // Get all category names
  List<String> getCategoryNames() {
    return categories.keys.toList();
  }
}
