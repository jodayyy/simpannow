import 'package:flutter/material.dart';
import 'package:simpannow/data/models/financial_summary_model.dart';
import 'package:intl/intl.dart';

class FinancialSummaryCard extends StatefulWidget {
  final FinancialSummary summary;
  final List<MonthlyNetFlow>? historicalData;

  const FinancialSummaryCard({
    super.key,
    required this.summary,
    this.historicalData,
  });

  @override
  State<FinancialSummaryCard> createState() => _FinancialSummaryCardState();
}

class _FinancialSummaryCardState extends State<FinancialSummaryCard> {
  bool _showHistory = false;

  String get _currentMonth {
    return DateFormat('MMMM').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Financial Summary text with current month
            Center(
              child: Text(
                'Financial Summary ($_currentMonth)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Three-column layout: Income (left) | Net Flow (center) | Expenses (right)
            Row(
              children: [
                // Left: Income
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Income',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RM${widget.summary.totalIncome.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                // Center: Net Flow
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Net Flow',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: widget.summary.balance >= 0 
                                ? '+RM${widget.summary.balance.toStringAsFixed(2)}'
                                : '-RM${(-widget.summary.balance).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: widget.summary.balance >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: ' (${widget.summary.growthPercentage >= 0 ? '+' : ''}${widget.summary.growthPercentage.toStringAsFixed(1)}%)',
                              style: TextStyle(
                                color: widget.summary.growthPercentage >= 0 ? Colors.green : Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Right: Expenses
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Expenses',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'RM${widget.summary.totalExpenses.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: (widget.summary.totalIncome == 0 && widget.summary.totalExpenses == 0)
                        ? LinearGradient(
                            colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface],
                          )
                        : LinearGradient(
                            colors: [Colors.green, Colors.red],
                            stops: [
                              widget.summary.totalIncome / (widget.summary.totalIncome + widget.summary.totalExpenses),
                              widget.summary.totalIncome / (widget.summary.totalIncome + widget.summary.totalExpenses),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_showHistory) ...[
              const Divider(),
              const Text(
                'Monthly Trends:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.historicalData != null && widget.historicalData!.isNotEmpty) ...[
                ...widget.historicalData!.map((monthData) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      '${monthData.monthName}: ${monthData.netFlow >= 0 ? '+RM' : '-RM'}${monthData.netFlow.abs().toStringAsFixed(2)} (${monthData.netWorthChangePercentage >= 0 ? '+' : ''}${monthData.netWorthChangePercentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 13,
                        color: monthData.netFlow >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                }).toList(),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 32,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No monthly data available yet',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monthly data will be automatically saved on the 1st of each month',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          'Next update: July 1, 2025',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showHistory = !_showHistory;
                  });
                },
                child: Text(
                  _showHistory ? 'Show Less' : 'Show More',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}