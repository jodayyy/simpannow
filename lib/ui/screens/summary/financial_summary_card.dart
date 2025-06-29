import 'package:flutter/material.dart';
import 'package:simpannow/data/models/financial_summary_model.dart';

class FinancialSummaryCard extends StatefulWidget {
  final FinancialSummary summary;

  const FinancialSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  State<FinancialSummaryCard> createState() => _FinancialSummaryCardState();
}

class _FinancialSummaryCardState extends State<FinancialSummaryCard> {
  bool _showBalance = false;

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
            // Financial Summary text
            Center(
              child: const Text(
                'Financial Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Income',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Expenses',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RM${widget.summary.totalIncome.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'RM${widget.summary.totalExpenses.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
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
            if (_showBalance) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Balance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${widget.summary.balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.summary.balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showBalance = !_showBalance;
                  });
                },
                child: Text(
                  _showBalance ? 'Show Less' : 'Show More',
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