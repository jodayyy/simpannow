import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:simpannow/data/models/transaction_model.dart' as models;

class TransferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> transferFunds({
    required String userId,
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    double fee = 0.0,
    String? title,
    String? description,
    DateTime? createdAt,
  }) async {
    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }
    if (fee < 0) {
      throw Exception('Fee cannot be negative');
    }
    if (fromAccountId == toAccountId) {
      throw Exception('From and To accounts must be different');
    }

    await _firestore.runTransaction((transaction) async {
      final fromRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc(fromAccountId);
      final toRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc(toAccountId);

      final fromSnap = await transaction.get(fromRef);
      final toSnap = await transaction.get(toRef);

      if (!fromSnap.exists || !toSnap.exists) {
        throw Exception('Account not found');
      }

      final fromData = fromSnap.data()!;
      final toData = toSnap.data()!;

      final fromBalance = (fromData["balance"] ?? 0.0).toDouble();
      final toBalance = (toData["balance"] ?? 0.0).toDouble();
      final fromName = (fromData["name"] ?? '').toString();
      final toName = (toData["name"] ?? '').toString();

      final totalDebit = amount + fee;
      if (fromBalance < totalDebit) {
        throw Exception('Insufficient funds');
      }

      final now = createdAt ?? DateTime.now();
      final txCollection = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions');

      // Pre-create documents to know their IDs
      final expenseDoc = txCollection.doc();
      final incomeDoc = txCollection.doc();
      // Generate a shared transfer group id
      final transferGroupId = txCollection.doc().id;
      final trimmedTitle = (title ?? '').trim();

      // Transfer out (expense)
      final expense = models.Transaction(
        id: expenseDoc.id,
        userId: userId,
        title: trimmedTitle.isEmpty ? 'Transfer to $toName' : trimmedTitle,
        amount: amount,
        type: models.TransactionType.EXPENSE,
        category: 'Transfer',
        createdAt: now,
        description: (description ?? '').trim().isEmpty ? null : description!.trim(),
        accountId: fromAccountId,
        transferGroupId: transferGroupId,
        linkedTransactionId: incomeDoc.id,
      );

      // Transfer in (income)
      final income = models.Transaction(
        id: incomeDoc.id,
        userId: userId,
        title: trimmedTitle.isEmpty ? 'Transfer from $fromName' : trimmedTitle,
        amount: amount,
        type: models.TransactionType.INCOME,
        category: 'Transfer',
        createdAt: now,
        description: (description ?? '').trim().isEmpty ? null : description!.trim(),
        accountId: toAccountId,
        transferGroupId: transferGroupId,
        linkedTransactionId: expenseDoc.id,
      );

      // Optional fee (expense) on from account
      models.Transaction? feeTx;
      DocumentReference<Map<String, dynamic>>? feeDoc;
      if (fee > 0) {
        feeDoc = txCollection.doc();
        feeTx = models.Transaction(
          id: feeDoc.id,
          userId: userId,
          title: 'Transfer Fee',
          amount: fee,
          type: models.TransactionType.EXPENSE,
          category: 'Fees',
          createdAt: now,
          description: (description ?? '').trim().isEmpty ? null : description!.trim(),
          accountId: fromAccountId,
          transferGroupId: transferGroupId,
          isTransferFee: true,
        );
      }

      // Write transactions
      transaction.set(expenseDoc, expense.toMap());
      transaction.set(incomeDoc, income.toMap());
      if (feeTx != null && feeDoc != null) {
        transaction.set(feeDoc, feeTx.toMap());
      }

      // Update balances
      transaction.update(fromRef, { 'balance': fromBalance - totalDebit });
      transaction.update(toRef, { 'balance': toBalance + amount });
    }).catchError((e, st) {
      debugPrint('Transfer failed: $e');
      throw Exception(e.toString());
    });
  }

  Future<void> deleteTransferByTransactionId({
    required String userId,
    required String transactionId,
  }) async {
    final txCollection = _firestore.collection('users').doc(userId).collection('transactions');

    // Fetch primary transaction and group metadata
    final primaryDocRef = txCollection.doc(transactionId);
    final primarySnap = await primaryDocRef.get();
    if (!primarySnap.exists) {
      throw Exception('Transaction not found');
    }
    final primaryData = primarySnap.data()!;
    final groupId = primaryData['transferGroupId'];
    if (groupId == null) {
      throw Exception('This transaction is not linked to a transfer');
    }

    // Find all docs in the group (2 or 3 docs)
    final groupQuery = await txCollection.where('transferGroupId', isEqualTo: groupId).get();
    final groupDocs = groupQuery.docs;

    // Identify expense, income, and optional fee
    QueryDocumentSnapshot<Map<String, dynamic>>? expenseDoc;
    QueryDocumentSnapshot<Map<String, dynamic>>? incomeDoc;
    QueryDocumentSnapshot<Map<String, dynamic>>? feeDoc;
    for (final d in groupDocs) {
      final data = d.data();
      if ((data['isTransferFee'] ?? false) == true) {
        feeDoc = d;
      } else if (data['category'] == 'Transfer') {
        final type = (data['type'] ?? '').toString();
        if (type == 'EXPENSE') {
          expenseDoc = d;
        } else if (type == 'INCOME') {
          incomeDoc = d;
        }
      }
    }
    if (expenseDoc == null || incomeDoc == null) {
      throw Exception('Transfer records incomplete');
    }
    final QueryDocumentSnapshot<Map<String, dynamic>> expDoc = expenseDoc; // non-null via flow
    final QueryDocumentSnapshot<Map<String, dynamic>> incDoc = incomeDoc;  // non-null via flow

    await _firestore.runTransaction((tr) async {
      // Read account docs
      final fromAccountId = (expDoc.data()['accountId'] ?? '').toString();
      final toAccountId = (incDoc.data()['accountId'] ?? '').toString();
      final amount = (expDoc.data()['amount'] ?? 0).toDouble();
      final fee = feeDoc != null ? (feeDoc.data()['amount'] ?? 0).toDouble() : 0.0;

      final fromRef = _firestore.collection('users').doc(userId).collection('accounts').doc(fromAccountId);
      final toRef = _firestore.collection('users').doc(userId).collection('accounts').doc(toAccountId);

      final fromSnap = await tr.get(fromRef);
      final toSnap = await tr.get(toRef);
      if (!fromSnap.exists || !toSnap.exists) {
        throw Exception('Account not found');
      }

      final fromBalance = (fromSnap.data()!["balance"] ?? 0.0).toDouble();
      final toBalance = (toSnap.data()!["balance"] ?? 0.0).toDouble();

      // Revert balances: add back amount and fee to from, subtract amount from to
      final newFromBal = fromBalance + amount + fee;
      final newToBal = toBalance - amount;

      tr.update(fromRef, { 'balance': newFromBal });
      tr.update(toRef, { 'balance': newToBal });

      // Delete docs
      tr.delete(expDoc.reference);
      tr.delete(incDoc.reference);
      if (feeDoc != null) {
        tr.delete(feeDoc.reference);
      }
    }).catchError((e, st) {
      debugPrint('Delete transfer failed: $e');
      throw Exception(e.toString());
    });
  }

  Future<void> deleteTransferFeeByTransactionId({
    required String userId,
    required String feeTransactionId,
  }) async {
    final txCollection = _firestore.collection('users').doc(userId).collection('transactions');
    final feeDocRef = txCollection.doc(feeTransactionId);
    final feeSnap = await feeDocRef.get();
    if (!feeSnap.exists) {
      throw Exception('Fee transaction not found');
    }
    final feeData = feeSnap.data()!;
    if ((feeData['isTransferFee'] ?? false) != true) {
      throw Exception('Not a transfer fee transaction');
    }
    final groupId = feeData['transferGroupId'];
    if (groupId == null) {
      throw Exception('Fee transaction not linked to a transfer');
    }

    // Find the expense (from) doc to know the account
    final groupQuery = await txCollection.where('transferGroupId', isEqualTo: groupId).get();
    QueryDocumentSnapshot<Map<String, dynamic>>? expenseDoc;
    for (final d in groupQuery.docs) {
      final data = d.data();
      if ((data['isTransferFee'] ?? false) == true) continue;
      if (data['category'] == 'Transfer' && (data['type'] ?? '') == 'EXPENSE') {
        expenseDoc = d;
        break;
      }
    }
    if (expenseDoc == null) {
      throw Exception('Linked transfer not found');
    }

    await _firestore.runTransaction((tr) async {
      final fromAccountId = (expenseDoc!.data()['accountId'] ?? '').toString();
      final feeAmount = (feeData['amount'] ?? 0).toDouble();
      final fromRef = _firestore.collection('users').doc(userId).collection('accounts').doc(fromAccountId);

      final fromSnap = await tr.get(fromRef);
      if (!fromSnap.exists) {
        throw Exception('Account not found');
      }
      final fromBalance = (fromSnap.data()!["balance"] ?? 0.0).toDouble();
      final newFromBal = fromBalance + feeAmount; // revert fee
      tr.update(fromRef, { 'balance': newFromBal });

      // delete fee doc only
      tr.delete(feeDocRef);
    }).catchError((e, st) {
      debugPrint('Delete transfer fee failed: $e');
      throw Exception(e.toString());
    });
  }

  Future<void> updateTransferByTransaction({
    required String userId,
    required models.Transaction updatedTransaction,
  }) async {
    final txCollection = _firestore.collection('users').doc(userId).collection('transactions');

    // Load group
    final groupId = updatedTransaction.transferGroupId;
    if (groupId == null) {
      throw Exception('This transaction is not linked to a transfer');
    }
    final groupQuery = await txCollection.where('transferGroupId', isEqualTo: groupId).get();
    final docs = groupQuery.docs;

    QueryDocumentSnapshot<Map<String, dynamic>>? expenseDoc;
    QueryDocumentSnapshot<Map<String, dynamic>>? incomeDoc;
    QueryDocumentSnapshot<Map<String, dynamic>>? feeDoc;
    for (final d in docs) {
      final data = d.data();
      if ((data['isTransferFee'] ?? false) == true) {
        feeDoc = d;
      } else if (data['category'] == 'Transfer') {
        final type = (data['type'] ?? '').toString();
        if (type == 'EXPENSE') {
          expenseDoc = d;
        } else if (type == 'INCOME') {
          incomeDoc = d;
        }
      }
    }
    if (expenseDoc == null || incomeDoc == null) {
      throw Exception('Transfer records incomplete');
    }

    // If editing fee record, handle only fee adjustments
    if (updatedTransaction.isTransferFee || (feeDoc != null && updatedTransaction.id == feeDoc.id)) {
      final expDoc = expenseDoc; // from account holder
      await _firestore.runTransaction((tr) async {
        final fromAccountId = (expDoc.data()['accountId'] ?? '').toString();
        final fromRef = _firestore.collection('users').doc(userId).collection('accounts').doc(fromAccountId);

        // Old fee amount
        final double oldFee = feeDoc != null ? (feeDoc.data()['amount'] ?? 0).toDouble() : 0.0;
        final double newFee = updatedTransaction.amount;
        final double delta = newFee - oldFee;

        // Update balance: since fee is expense, increase fee -> subtract more (balance - delta)
        final fromSnap = await tr.get(fromRef);
        if (!fromSnap.exists) {
          throw Exception('Account not found');
        }
        final fromBalance = (fromSnap.data()!["balance"] ?? 0.0).toDouble();
        final newFromBal = fromBalance - delta;
        tr.update(fromRef, { 'balance': newFromBal });

        if (feeDoc != null) {
          // Update existing fee doc fields
          final String? desc = (updatedTransaction.description ?? '').trim().isEmpty
              ? null
              : updatedTransaction.description!.trim();
          final feeUpdate = {
            'amount': newFee,
            'createdAt': Timestamp.fromDate(updatedTransaction.createdAt),
            'description': desc,
            'title': updatedTransaction.title.trim().isEmpty ? 'Transfer Fee' : updatedTransaction.title.trim(),
          };
          tr.update(feeDoc.reference, feeUpdate);
        } else {
          // No existing fee doc: create one (rare path)
          final newFeeDoc = txCollection.doc();
          final feeTx = models.Transaction(
            id: newFeeDoc.id,
            userId: userId,
            title: updatedTransaction.title.trim().isEmpty ? 'Transfer Fee' : updatedTransaction.title.trim(),
            amount: newFee,
            type: models.TransactionType.EXPENSE,
            category: 'Fees',
            createdAt: updatedTransaction.createdAt,
            description: (updatedTransaction.description ?? '').trim().isEmpty ? null : updatedTransaction.description!.trim(),
            accountId: expDoc.data()['accountId'],
            transferGroupId: groupId,
            isTransferFee: true,
          );
          tr.set(newFeeDoc, feeTx.toMap());
        }
      }).catchError((e, st) {
        debugPrint('Update transfer fee failed: $e');
        throw Exception(e.toString());
      });
      return;
    }

    // Otherwise update both sides of transfer as before
    final QueryDocumentSnapshot<Map<String, dynamic>> expDoc = expenseDoc;
    final QueryDocumentSnapshot<Map<String, dynamic>> incDoc = incomeDoc;

    await _firestore.runTransaction((tr) async {
      // Re-read inside transaction
      final expenseSnap = await tr.get(expDoc.reference);
      final incomeSnap = await tr.get(incDoc.reference);
      final Map<String, dynamic> expenseData = expenseSnap.data() as Map<String, dynamic>;
      final Map<String, dynamic> incomeData = incomeSnap.data() as Map<String, dynamic>;

      final fromAccountId = (expenseData['accountId'] ?? '').toString();
      final toAccountId = (incomeData['accountId'] ?? '').toString();

      final oldAmount = (expenseData['amount'] ?? 0).toDouble();
      final newAmount = updatedTransaction.amount;
      final delta = newAmount - oldAmount;

      final fromRef = _firestore.collection('users').doc(userId).collection('accounts').doc(fromAccountId);
      final toRef = _firestore.collection('users').doc(userId).collection('accounts').doc(toAccountId);

      final fromSnap = await tr.get(fromRef);
      final toSnap = await tr.get(toRef);
      if (!fromSnap.exists || !toSnap.exists) {
        throw Exception('Account not found');
      }

      // Adjust balances: from decreases by delta, to increases by delta
      if (delta != 0) {
        final fromBalance = (fromSnap.data()!["balance"] ?? 0.0).toDouble();
        final toBalance = (toSnap.data()! ["balance"] ?? 0.0).toDouble();
        final newFromBal = fromBalance - delta; // if delta positive, subtract more
        final newToBal = toBalance + delta;     // if delta positive, add more
        tr.update(fromRef, { 'balance': newFromBal });
        tr.update(toRef, { 'balance': newToBal });
      }

      // Update both records metadata and amount
      final trimmedTitle = updatedTransaction.title.trim();
      final String? desc = (updatedTransaction.description ?? '').trim().isEmpty
          ? null
          : updatedTransaction.description!.trim();
      final createdAt = updatedTransaction.createdAt;

      final expenseUpdate = {
        'title': trimmedTitle.isEmpty ? expenseData['title'] : trimmedTitle,
        'amount': newAmount,
        'createdAt': Timestamp.fromDate(createdAt),
        'description': desc,
      };
      final incomeUpdate = {
        'title': trimmedTitle.isEmpty ? incomeData['title'] : trimmedTitle,
        'amount': newAmount,
        'createdAt': Timestamp.fromDate(createdAt),
        'description': desc,
      };

      tr.update(expDoc.reference, expenseUpdate);
      tr.update(incDoc.reference, incomeUpdate);

      // Optionally keep fee doc's description/createdAt in sync
      if (feeDoc != null) {
        final feeUpdate = {
          'createdAt': Timestamp.fromDate(createdAt),
          'description': desc,
        };
        tr.update(feeDoc.reference, feeUpdate);
      }

    }).catchError((e, st) {
      debugPrint('Update transfer failed: $e');
      throw Exception(e.toString());
    });
  }
}
