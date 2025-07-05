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

  static const List<String> _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Get historical monthly data for a user
  Stream<List<MonthlyNetFlow>> getMonthlyHistoryStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('monthly_summaries')
        .orderBy('capturedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final monthlyData = snapshot.docs
          .map((doc) => MonthlyNetFlow.fromMap(doc.data()))
          .toList();
      
      // Sort by year and month manually since we can't use composite index
      monthlyData.sort((a, b) {
        if (a.year != b.year) {
          return b.year.compareTo(a.year); // Descending by year
        }
        return b.month.compareTo(a.month); // Descending by month
      });
      
      _historicalData = monthlyData;
      return monthlyData;
    });
  }

  // NEW: Main function to check and capture all missing monthly data
  Future<void> checkAndCaptureAllMissingMonths(
    String userId,
    List<Transaction> allTransactions,
    List<Account> currentAccounts,
  ) async {
    if (allTransactions.isEmpty) return;

    _isLoading = true;
    // Remove notifyListeners() from here to avoid setState during build
    
    try {
      final now = DateTime.now();
      
      // Find the earliest transaction date
      final sortedTransactions = List<Transaction>.from(allTransactions)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final firstTransactionDate = sortedTransactions.first.createdAt;
      
      // Start from previous month and go backwards
      DateTime checkDate = DateTime(now.year, now.month - 1, 1);
      final oneYearAgo = DateTime(now.year - 1, now.month, 1);
      
      // Find the earliest month we should check (first transaction's month)
      final firstTransactionMonth = DateTime(firstTransactionDate.year, firstTransactionDate.month, 1);
      final earliestCheck = firstTransactionMonth.isBefore(oneYearAgo) ? oneYearAgo : firstTransactionMonth;
      
      List<Future<void>> processingTasks = [];
      int monthsChecked = 0;
      
      while (checkDate.isAfter(earliestCheck.subtract(const Duration(days: 1))) || checkDate.isAtSameMomentAs(earliestCheck)) {
        monthsChecked++;
        
        // Check if we already have data for this month
        final docId = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}';
        
        final existingDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('monthly_summaries')
            .doc(docId)
            .get();
        
        if (!existingDoc.exists) {
          // Check if month has any transactions
          final monthHasTransactions = _monthHasTransactions(checkDate, allTransactions);
          
          if (monthHasTransactions) {
            // Add to processing queue
            processingTasks.add(_calculateAndSaveMonthData(
              userId,
              checkDate.year,
              checkDate.month,
              allTransactions,
              currentAccounts,
            ));
          }
        } else {
          // Check if existing data has new fields, if not regenerate
          final data = existingDoc.data();
          if (data != null && (!data.containsKey('netWorthAtEndOfMonth') || !data.containsKey('netWorthGrowthPercentage'))) {
            // Old format, regenerate
            final monthHasTransactions = _monthHasTransactions(checkDate, allTransactions);
            if (monthHasTransactions) {
              processingTasks.add(_calculateAndSaveMonthData(
                userId,
                checkDate.year,
                checkDate.month,
                allTransactions,
                currentAccounts,
              ));
            }
          }
        }
        
        // Move to previous month
        if (checkDate.month == 1) {
          checkDate = DateTime(checkDate.year - 1, 12, 1);
        } else {
          checkDate = DateTime(checkDate.year, checkDate.month - 1, 1);
        }
        
        // Safety check - don't check more than 24 months
        if (monthsChecked >= 24) {
          break;
        }
      }
      
      // Process all missing months
      if (processingTasks.isNotEmpty) {
        await Future.wait(processingTasks);
      }
      
    } catch (e) {
      _errorMessage = "Failed to process monthly data: $e";
      debugPrint('Error processing monthly data: $e');
    }

    _isLoading = false;
    // Only notify after processing is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Check if a month has any transactions
  bool _monthHasTransactions(DateTime monthDate, List<Transaction> allTransactions) {
    final monthStart = DateTime(monthDate.year, monthDate.month, 1);
    final monthEnd = DateTime(monthDate.year, monthDate.month + 1, 1).subtract(const Duration(seconds: 1));
    
    return allTransactions.any((t) =>
      t.createdAt.isAfter(monthStart.subtract(const Duration(seconds: 1))) &&
      t.createdAt.isBefore(monthEnd.add(const Duration(seconds: 1)))
    );
  }

  // Calculate and save data for a specific month
  Future<void> _calculateAndSaveMonthData(
    String userId,
    int year,
    int month,
    List<Transaction> allTransactions,
    List<Account> currentAccounts,
  ) async {
    try {
      // Define month date range
      final monthStart = DateTime(year, month, 1);
      final monthEnd = DateTime(year, month + 1, 1).subtract(const Duration(seconds: 1));
      
      // Filter transactions for this month
      final monthTransactions = allTransactions.where((t) =>
        t.createdAt.isAfter(monthStart.subtract(const Duration(seconds: 1))) &&
        t.createdAt.isBefore(monthEnd.add(const Duration(seconds: 1)))
      ).toList();
      
      // Calculate net flow
      final income = monthTransactions
          .where((t) => t.type == TransactionType.INCOME)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      final expenses = monthTransactions
          .where((t) => t.type == TransactionType.EXPENSE)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      final netFlow = income - expenses;
      
      // Calculate net worth at END of this month
      final netWorthAtEndOfMonth = await _calculateNetWorthAtEndOfMonth(
        year,
        month,
        allTransactions,
        currentAccounts,
      );
      
      // Calculate net worth at END of previous month
      final previousMonth = month == 1 ? 12 : month - 1;
      final previousYear = month == 1 ? year - 1 : year;
      final previousNetWorth = await _calculateNetWorthAtEndOfMonth(
        previousYear,
        previousMonth,
        allTransactions,
        currentAccounts,
      );
      
      // Calculate percentages
      // Check if this is the first month with accounts (previous month had no accounts)
      final isFirstMonthWithAccounts = previousNetWorth == 0 && netWorthAtEndOfMonth > 0;
      
      double netWorthChangePercentage;
      double netWorthGrowthPercentage;
      
      if (isFirstMonthWithAccounts) {
        // For first month, use initial account balances as baseline
        final initialNetWorth = _calculateInitialNetWorth(currentAccounts, allTransactions);
        
        // Net Flow as percentage of initial net worth
        netWorthChangePercentage = initialNetWorth != 0 
            ? (netFlow / initialNetWorth) * 100
            : 0.0;
        
        // Growth is same as flow for first month (relative to initial balances)
        netWorthGrowthPercentage = netWorthChangePercentage;
      } else {
        // Normal month-to-month calculation
        netWorthChangePercentage = previousNetWorth != 0 
            ? (netFlow / previousNetWorth) * 100
            : (netFlow != 0 ? 100.0 : 0.0);
        
        // Actual net worth growth percentage (month-over-month)
        netWorthGrowthPercentage = previousNetWorth != 0
            ? ((netWorthAtEndOfMonth - previousNetWorth) / previousNetWorth) * 100
            : (netWorthAtEndOfMonth != 0 ? 100.0 : 0.0);
      }
      
      // Save the data
      await _saveMonthlyData(
        userId,
        year,
        month,
        _monthNames[month],
        netFlow,
        netWorthAtEndOfMonth,
        netWorthChangePercentage,
        netWorthGrowthPercentage,
      );
      
    } catch (e) {
      debugPrint('Error calculating month data for $year-$month: $e');
    }
  }

  // Calculate net worth at the end of a specific month
  Future<double> _calculateNetWorthAtEndOfMonth(
    int year,
    int month,
    List<Transaction> allTransactions,
    List<Account> currentAccounts,
  ) async {
    final endOfMonth = DateTime(year, month + 1, 1).subtract(const Duration(seconds: 1));
    
    // Get transactions up to the end of the specified month
    final transactionsUpToEndOfMonth = allTransactions.where((t) =>
      t.createdAt.isBefore(endOfMonth.add(const Duration(seconds: 1)))
    ).toList();
    
    double totalNetWorth = 0.0;
    
    for (final account in currentAccounts) {
      final accountBalance = _calculateAccountBalanceAtDate(
        account,
        endOfMonth,
        transactionsUpToEndOfMonth,
      );
      totalNetWorth += accountBalance;
    }
    
    return totalNetWorth;
  }

  // Calculate account balance at a specific date
  double _calculateAccountBalanceAtDate(
    Account account,
    DateTime targetDate,
    List<Transaction> allTransactions,
  ) {
    // If target date is before account creation, balance is 0
    if (targetDate.isBefore(account.createdAt)) {
      return 0.0;
    }
    
    // Start with the account's current balance, then work backwards
    double balance = account.balance;
    
    // Get all transactions for this account AFTER the target date
    final futureTransactions = allTransactions.where((t) =>
      t.accountId == account.id &&
      t.createdAt.isAfter(targetDate)
    ).toList();
    
    // Remove the effect of future transactions to get balance at target date
    for (final transaction in futureTransactions) {
      if (transaction.type == TransactionType.INCOME) {
        balance -= transaction.amount; // Remove future income
      } else {
        balance += transaction.amount; // Add back future expenses
      }
    }
    
    return balance;
  }

  // Save monthly data to Firestore
  Future<void> _saveMonthlyData(
    String userId,
    int year,
    int month,
    String monthName,
    double netFlow,
    double netWorthAtEndOfMonth,
    double netWorthChangePercentage,
    double netWorthGrowthPercentage,
  ) async {
    try {
      final monthlyData = MonthlyNetFlow(
        year: year,
        month: month,
        monthName: monthName,
        netFlow: netFlow,
        netWorthChangePercentage: netWorthChangePercentage,
        netWorthAtEndOfMonth: netWorthAtEndOfMonth,
        netWorthGrowthPercentage: netWorthGrowthPercentage,
        capturedAt: DateTime.now(),
      );

      final docId = '${year}-${month.toString().padLeft(2, '0')}';
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('monthly_summaries')
          .doc(docId)
          .set(monthlyData.toMap());
      
    } catch (e) {
      debugPrint('Error saving monthly data: $e');
      rethrow;
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
      debugPrint('Error getting last saved month: $e');
      return null;
    }
  }

  // Calculate initial net worth (sum of all account balances minus all transactions)
  double _calculateInitialNetWorth(List<Account> accounts, List<Transaction> allTransactions) {
    double totalInitialBalance = 0.0;
    
    for (final account in accounts) {
      // Get all transactions for this account
      final accountTransactions = allTransactions.where((t) => t.accountId == account.id).toList();
      
      // Calculate total transaction effect
      double totalTransactionEffect = 0.0;
      for (final transaction in accountTransactions) {
        if (transaction.type == TransactionType.INCOME) {
          totalTransactionEffect += transaction.amount;
        } else {
          totalTransactionEffect -= transaction.amount;
        }
      }
      
      // Initial balance = current balance - transaction effects
      final initialBalance = account.balance - totalTransactionEffect;
      totalInitialBalance += initialBalance;
    }
    
    return totalInitialBalance;
  }
}
