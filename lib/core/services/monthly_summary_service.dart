import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/material.dart';
import 'package:simpannow/data/models/financial_summary_model.dart';
import 'package:simpannow/data/models/transaction_model.dart';
import 'package:simpannow/data/models/account_model.dart';

class MonthlySummaryService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<MonthlyNetFlow> _historicalData = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MonthlyNetFlow> get historicalData => _historicalData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get historical monthly data for a user
  Stream<List<MonthlyNetFlow>> getMonthlyHistoryStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('monthly_summaries')
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .snapshots()
        .map((snapshot) {
      final monthlyData = snapshot.docs
          .map((doc) => MonthlyNetFlow.fromMap(doc.data()))
          .toList();
      _historicalData = monthlyData;
      return monthlyData;
    });
  }

  // Save monthly summary data (called at start of new month)
  Future<bool> saveMonthlyData(
    String userId,
    int year,
    int month,
    String monthName,
    double netFlow,
    double currentNetWorth,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Calculate percentage based on current net worth
      final netWorthChangePercentage = currentNetWorth != 0 
          ? (netFlow / currentNetWorth) * 100
          : (netFlow != 0 ? 100.0 : 0.0);

      final monthlyData = MonthlyNetFlow(
        year: year,
        month: month,
        monthName: monthName,
        netFlow: netFlow,
        netWorthChangePercentage: netWorthChangePercentage,
        capturedAt: DateTime.now(),
      );

      // Use year-month as document ID to prevent duplicates
      final docId = '${year}-${month.toString().padLeft(2, '0')}';
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('monthly_summaries')
          .doc(docId)
          .set(monthlyData.toMap());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to save monthly data: $e";
      notifyListeners();
      return false;
    }
  }

  // Check if we need to save data for previous month
  Future<void> checkAndSaveMonthlyData(
    String userId,
    List<Transaction> transactions,
    List<Account> accounts,
  ) async {
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    
    // Check if it's the first day of the month
    if (now.day == 1) {
      final previousMonth = currentMonth == 1 ? 12 : currentMonth - 1;
      final previousYear = currentMonth == 1 ? currentYear - 1 : currentYear;
      
      // Check if we already have data for the previous month
      final docId = '${previousYear}-${previousMonth.toString().padLeft(2, '0')}';
      final existingDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('monthly_summaries')
          .doc(docId)
          .get();
      
      if (!existingDoc.exists) {
        // Calculate net flow for previous month
        final previousMonthStart = DateTime(previousYear, previousMonth, 1);
        final previousMonthEnd = DateTime(currentYear, currentMonth, 1).subtract(const Duration(days: 1));
        
        final previousMonthTransactions = transactions.where((t) =>
          t.createdAt.isAfter(previousMonthStart) &&
          t.createdAt.isBefore(previousMonthEnd.add(const Duration(days: 1)))
        ).toList();
        
        final income = previousMonthTransactions
            .where((t) => t.type == TransactionType.INCOME)
            .fold(0.0, (sum, t) => sum + t.amount);
        
        final expenses = previousMonthTransactions
            .where((t) => t.type == TransactionType.EXPENSE)
            .fold(0.0, (sum, t) => sum + t.amount);
        
        final netFlow = income - expenses;
        final currentNetWorth = accounts.fold(0.0, (sum, account) => sum + account.balance);
        
        final monthNames = [
          '', 'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        
        await saveMonthlyData(
          userId,
          previousYear,
          previousMonth,
          monthNames[previousMonth],
          netFlow,
          currentNetWorth,
        );
      }
    }
  }

  // Get the last saved monthly data for display purposes
  Future<MonthlyNetFlow?> getLastSavedMonth(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('monthly_summaries')
          .orderBy('year', descending: true)
          .orderBy('month', descending: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return MonthlyNetFlow.fromMap(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
