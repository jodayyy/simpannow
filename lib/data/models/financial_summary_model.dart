import 'package:simpannow/data/models/transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

class MonthlyNetFlow {
  final int year;
  final int month;
  final String monthName;
  final double netFlow;
  final double netWorthChangePercentage;
  final double netWorthAtEndOfMonth;
  final double netWorthGrowthPercentage;
  final DateTime capturedAt;

  MonthlyNetFlow({
    required this.year,
    required this.month,
    required this.monthName,
    required this.netFlow,
    required this.netWorthChangePercentage,
    required this.netWorthAtEndOfMonth,
    required this.netWorthGrowthPercentage,
    required this.capturedAt,
  });

  factory MonthlyNetFlow.fromMap(Map<String, dynamic> map) {
    return MonthlyNetFlow(
      year: map['year'] ?? 0,
      month: map['month'] ?? 0,
      monthName: map['monthName'] ?? '',
      netFlow: (map['netFlow'] ?? 0.0).toDouble(),
      netWorthChangePercentage: (map['netWorthChangePercentage'] ?? 0.0).toDouble(),
      netWorthAtEndOfMonth: (map['netWorthAtEndOfMonth'] ?? 0.0).toDouble(),
      // Handle missing field for backward compatibility
      netWorthGrowthPercentage: (map['netWorthGrowthPercentage'] ?? 0.0).toDouble(),
      capturedAt: (map['capturedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'monthName': monthName,
      'netFlow': netFlow,
      'netWorthChangePercentage': netWorthChangePercentage,
      'netWorthAtEndOfMonth': netWorthAtEndOfMonth,
      'netWorthGrowthPercentage': netWorthGrowthPercentage,
      'capturedAt': Timestamp.fromDate(capturedAt),
    };
  }
}

class FinancialSummary {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final double growthPercentage;
  final List<Transaction> recentTransactions;

  FinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.growthPercentage,
    required this.recentTransactions,
  });

  factory FinancialSummary.fromTransactions(List<Transaction> transactions, double currentNetWorth) {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    
    // Only include current month transactions, and exclude transfers
    final currentMonthTransactions = transactions.where((t) => 
      t.createdAt.isAfter(currentMonthStart.subtract(const Duration(seconds: 1))) &&
      t.createdAt.isBefore(DateTime(now.year, now.month + 1, 1)) &&
      t.category != 'Transfer'
    );
    
    final income = currentMonthTransactions
        .where((t) => t.type == TransactionType.INCOME)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final expenses = currentMonthTransactions
        .where((t) => t.type == TransactionType.EXPENSE)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final balance = income - expenses;
    
    // Calculate growth percentage based on starting net worth of the month
    // Starting net worth = current net worth - current month's net flow
    final startingNetWorth = currentNetWorth - balance;
    final growthPercentage = startingNetWorth != 0 
        ? (balance / startingNetWorth) * 100 
        : (balance != 0 ? 100.0 : 0.0);
    
    // Get recent transactions (last 10, sorted by date), excluding transfers
    final recentTransactions = List<Transaction>.from(transactions)
      ..removeWhere((t) => t.category == 'Transfer')
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
      ..take(10);

    return FinancialSummary(
      totalIncome: income,
      totalExpenses: expenses,
      balance: balance,
      growthPercentage: growthPercentage,
      recentTransactions: recentTransactions.take(10).toList(),
    );
  }
}
