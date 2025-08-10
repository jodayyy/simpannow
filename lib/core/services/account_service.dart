import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:simpannow/data/models/account_model.dart';
import 'package:simpannow/core/services/transfer_service.dart';

class AccountService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Add a new account
  Future<bool> addAccount(Account account) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final docRef = _firestore
          .collection('users')
          .doc(account.userId)
          .collection('accounts')
          .doc();

      final accountWithId = account.copyWith(id: docRef.id);
      await docRef.set(accountWithId.toMap());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to add account: $e";
      debugPrint('Error: $e');
      notifyListeners();
      return false;
    }
  }

  // Get accounts stream for a user
  Stream<List<Account>> getUserAccountsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      final accounts = snapshot.docs
          .map((doc) => Account.fromMap(doc.data()))
          .toList();
      _accounts = accounts;
      return accounts;
    });
  }

  // Update account
  Future<bool> updateAccount(Account account) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore
          .collection('users')
          .doc(account.userId)
          .collection('accounts')
          .doc(account.id)
          .update(account.toMap());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to update account: $e";
      debugPrint('Error: $e');
      notifyListeners();
      return false;
    }
  }

  // Delete account and all linked transactions
  Future<bool> deleteAccount(String userId, String accountId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Find all transactions linked to this account
      final transactionsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('accountId', isEqualTo: accountId)
          .get();

      // Keep track of processed transfer groups to avoid double-deletes
      final processedTransferGroups = <String>{};
      final transferService = TransferService();

      for (final doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final String groupId = (data['transferGroupId'] ?? '').toString();
        final String category = (data['category'] ?? '').toString();
        final bool isTransfer = category == 'Transfer' && groupId.isNotEmpty;
        final bool isTransferFee = (data['isTransferFee'] ?? false) == true;

        if (isTransfer) {
          // Delete the whole transfer group (both sides and optional fee) once
          if (!processedTransferGroups.contains(groupId)) {
            await transferService.deleteTransferByTransactionId(
              userId: userId,
              transactionId: doc.id,
            );
            processedTransferGroups.add(groupId);
          }
          continue;
        }

        // Skip fee docs here because they will be deleted together with the group
        if (isTransferFee) {
          // In practice, fee belongs to the from-account and will be removed when the group is deleted.
          // If somehow only a fee doc exists for this account without a visible transfer doc in the query,
          // you could uncomment the following to delete it standalone:
          // await transferService.deleteTransferFeeByTransactionId(userId: userId, feeTransactionId: doc.id);
          continue;
        }

        // Regular (non-transfer) transaction: delete the doc
        await doc.reference.delete();
      }

      // Finally, delete the account document itself
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc(accountId)
          .delete();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to delete account: $e";
      debugPrint('Error: $e');
      notifyListeners();
      return false;
    }
  }

  // Get count of transactions linked to an account
  Future<int> getLinkedTransactionCount(String userId, String accountId) async {
    try {
      final transactionsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('accountId', isEqualTo: accountId)
          .get();
      
      return transactionsSnapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting linked transaction count: $e');
      return 0;
    }
  }

  // Update account balance (when transaction is added/removed)
  Future<bool> updateAccountBalance(String userId, String accountId, double newBalance) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc(accountId)
          .update({'balance': newBalance});
      return true;
    } catch (e) {
      debugPrint('Error updating account balance: $e');
      return false;
    }
  }

  // Get account by ID
  Future<Account?> getAccountById(String userId, String accountId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc(accountId)
          .get();
      
      if (doc.exists) {
        return Account.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting account: $e');
      return null;
    }
  }

  // Get account type icon
  String getAccountTypeIcon(String type) {
    return Account.getTypeIcon(type);
  }

  // Get account types list
  List<String> getAccountTypes() {
    return Account.accountTypes;
  }
}
