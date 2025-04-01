import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = Provider.of<ExpenseProvider>(context).expenses;

    return Scaffold(
      appBar: AppBar(title: Text('Expense Reports')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMonthlySpendingChart(expenses),
            SizedBox(height: 30),
            _buildCategoryPieChart(expenses),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySpendingChart(List<Expense> expenses) {
    // Group expenses by month
    final monthlyData = <String, double>{};
    final dateFormat = DateFormat('MMM yyyy');

    for (var expense in expenses) {
      final monthKey = dateFormat.format(expense.date);
      monthlyData.update(
        monthKey,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final series = [
      charts.Series<MapEntry<String, double>, String>(
        id: 'Monthly Spending',
        domainFn: (entry, _) => entry.key,
        measureFn: (entry, _) => entry.value,
        data: monthlyData.entries.toList(),
        labelAccessorFn: (entry, _) => '\$${entry.value.toStringAsFixed(2)}',
      ),
    ];

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Spending',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 250,
              child: charts.BarChart(
                series,
                animate: true,
                vertical: false,
                barRendererDecorator: charts.BarLabelDecorator<String>(),
                domainAxis: charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(labelRotation: 45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(List<Expense> expenses) {
    // Group expenses by category
    final categoryData = <String, double>{};

    for (var expense in expenses) {
      categoryData.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final series = [
      charts.Series<MapEntry<String, double>, String>(
        id: 'Category Breakdown',
        domainFn: (entry, _) => entry.key,
        measureFn: (entry, _) => entry.value,
        data: categoryData.entries.toList(),
        labelAccessorFn:
            (entry, _) => '${entry.key}: \$${entry.value.toStringAsFixed(2)}',
      ),
    ];

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 300,
              child: charts.PieChart(
                series,
                animate: true,
                defaultRenderer: charts.ArcRendererConfig(
                  arcRendererDecorators: [
                    charts.ArcLabelDecorator(
                      labelPosition: charts.ArcLabelPosition.auto,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
