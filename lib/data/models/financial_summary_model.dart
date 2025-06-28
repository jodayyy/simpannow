import 'package:simpannow/data/models/transaction_model.dart';

class FinancialSummary {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final List<Transaction> recentTransactions;

  FinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.recentTransactions,
  });

  factory FinancialSummary.fromTransactions(List<Transaction> transactions) {
    final income = transactions
        .where((t) => t.type == TransactionType.INCOME)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final expenses = transactions
        .where((t) => t.type == TransactionType.EXPENSE)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final balance = income - expenses;
    
    // Get recent transactions (last 10, sorted by date)
    final recentTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt))
      ..take(10);

    return FinancialSummary(
      totalIncome: income,
      totalExpenses: expenses,
      balance: balance,
      recentTransactions: recentTransactions.take(10).toList(),
    );
  }
}
