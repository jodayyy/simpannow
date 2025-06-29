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

      // Update account balance if transaction is linked to an account
      if (transaction.accountId != null && transaction.accountId!.isNotEmpty) {
        await _updateAccountBalance(transaction);
      }

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
      // Get transaction data before deletion to update account balance
      final transactionDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .get();

      models.Transaction? transaction;
      if (transactionDoc.exists) {
        transaction = models.Transaction.fromMap(transactionDoc.data()!);
      }

      // Delete the transaction
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .delete();

      // Update account balance if transaction was linked to an account
      if (transaction != null && transaction.accountId != null && transaction.accountId!.isNotEmpty) {
        await _revertAccountBalance(transaction);
      }

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

  // Update a transaction
  Future<bool> updateTransaction(String userId, models.Transaction updatedTransaction, models.Transaction originalTransaction) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Update the transaction in Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(updatedTransaction.id)
          .update(updatedTransaction.toMap());

      // Handle account balance updates
      await _handleAccountBalanceUpdate(originalTransaction, updatedTransaction);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to update transaction: $e";
      notifyListeners();
      return false;
    }
  }

  // Handle account balance update when transaction is updated
  Future<void> _handleAccountBalanceUpdate(models.Transaction originalTransaction, models.Transaction updatedTransaction) async {
    // If both transactions have the same account, update the balance difference
    if (originalTransaction.accountId == updatedTransaction.accountId) {
      if (originalTransaction.accountId != null && originalTransaction.accountId!.isNotEmpty) {
        await _updateAccountBalanceForEdit(originalTransaction, updatedTransaction);
      }
    } else {
      // Different accounts, revert original and apply new
      if (originalTransaction.accountId != null && originalTransaction.accountId!.isNotEmpty) {
        await _revertAccountBalance(originalTransaction);
      }
      if (updatedTransaction.accountId != null && updatedTransaction.accountId!.isNotEmpty) {
        await _updateAccountBalance(updatedTransaction);
      }
    }
  }

  // Update account balance for transaction edit (same account)
  Future<void> _updateAccountBalanceForEdit(models.Transaction originalTransaction, models.Transaction updatedTransaction) async {
    try {
      final accountRef = _firestore
          .collection('users')
          .doc(updatedTransaction.userId)
          .collection('accounts')
          .doc(updatedTransaction.accountId);

      final accountDoc = await accountRef.get();
      if (accountDoc.exists) {
        final currentBalance = (accountDoc.data()!['balance'] ?? 0.0).toDouble();
        double balanceChange = 0.0;

        // Calculate the difference between original and updated transaction
        // First, revert the original transaction effect
        if (originalTransaction.type == models.TransactionType.INCOME) {
          balanceChange -= originalTransaction.amount; // Remove original income
        } else {
          balanceChange += originalTransaction.amount; // Add back original expense
        }

        // Then, apply the updated transaction effect
        if (updatedTransaction.type == models.TransactionType.INCOME) {
          balanceChange += updatedTransaction.amount; // Add new income
        } else {
          balanceChange -= updatedTransaction.amount; // Subtract new expense
        }

        final newBalance = currentBalance + balanceChange;
        await accountRef.update({'balance': newBalance});
      }
    } catch (e) {
      debugPrint('Error updating account balance for edit: $e');
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

  // Update account balance when transaction is added/deleted
  Future<void> _updateAccountBalance(models.Transaction transaction) async {
    try {
      final accountRef = _firestore
          .collection('users')
          .doc(transaction.userId)
          .collection('accounts')
          .doc(transaction.accountId);

      final accountDoc = await accountRef.get();
      if (accountDoc.exists) {
        final currentBalance = (accountDoc.data()!['balance'] ?? 0.0).toDouble();
        double newBalance;

        if (transaction.type == models.TransactionType.INCOME) {
          newBalance = currentBalance + transaction.amount;
        } else {
          newBalance = currentBalance - transaction.amount;
        }

        await accountRef.update({'balance': newBalance});
      }
    } catch (e) {
      debugPrint('Error updating account balance: $e');
    }
  }

  // Revert account balance when transaction is deleted
  Future<void> _revertAccountBalance(models.Transaction transaction) async {
    try {
      final accountRef = _firestore
          .collection('users')
          .doc(transaction.userId)
          .collection('accounts')
          .doc(transaction.accountId);

      final accountDoc = await accountRef.get();
      if (accountDoc.exists) {
        final currentBalance = (accountDoc.data()!['balance'] ?? 0.0).toDouble();
        double newBalance;

        // Reverse the transaction effect
        if (transaction.type == models.TransactionType.INCOME) {
          newBalance = currentBalance - transaction.amount; // Remove income
        } else {
          newBalance = currentBalance + transaction.amount; // Add back expense
        }

        await accountRef.update({'balance': newBalance});
      }
    } catch (e) {
      debugPrint('Error reverting account balance: $e');
    }
  }
}
