import 'package:simpannow/data/models/transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

class MonthlyNetFlow {
  final int year;
  final int month;
  final String monthName;
  final double netFlow;
  final double netWorthChangePercentage;
  final DateTime capturedAt;

  MonthlyNetFlow({
    required this.year,
    required this.month,
    required this.monthName,
    required this.netFlow,
    required this.netWorthChangePercentage,
    required this.capturedAt,
  });

  factory MonthlyNetFlow.fromMap(Map<String, dynamic> map) {
    return MonthlyNetFlow(
      year: map['year'] ?? 0,
      month: map['month'] ?? 0,
      monthName: map['monthName'] ?? '',
      netFlow: (map['netFlow'] ?? 0.0).toDouble(),
      netWorthChangePercentage: (map['netWorthChangePercentage'] ?? 0.0).toDouble(),
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
    
    // Only include current month transactions
    final currentMonthTransactions = transactions.where((t) => 
      t.createdAt.isAfter(currentMonthStart.subtract(const Duration(seconds: 1))) &&
      t.createdAt.isBefore(DateTime(now.year, now.month + 1, 1))
    );
    
    final income = currentMonthTransactions
        .where((t) => t.type == TransactionType.INCOME)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final expenses = currentMonthTransactions
        .where((t) => t.type == TransactionType.EXPENSE)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final balance = income - expenses;
    
    // Calculate growth percentage based on current net worth
    // This shows what percentage of current net worth the month's net flow represents
    final growthPercentage = currentNetWorth != 0 
        ? (balance / currentNetWorth) * 100 
        : (balance != 0 ? 100.0 : 0.0);
    
    // Get recent transactions (last 10, sorted by date)
    final recentTransactions = List<Transaction>.from(transactions)
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
