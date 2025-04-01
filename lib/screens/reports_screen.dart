import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/budget_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final expenses = Provider.of<ExpenseProvider>(context).expenses;

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMonthlySpendingCard(expenses),
            const SizedBox(height: 20),
            _buildCategoryPieChartCard(expenses),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetProgress(List<Expense> expenses, BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final remaining = budgetProvider.getRemainingBudget(expenses);
    final double percentage =
        budgetProvider.monthlyBudget > 0
            ? (1 - (remaining / budgetProvider.monthlyBudget)).clamp(0, 1)
            : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Budget Progress',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              color: percentage > 0.9 ? Colors.red : Colors.green,
            ),
            SizedBox(height: 10),
            Text(
              'Remaining: \$${remaining.toStringAsFixed(2)}',
              style: TextStyle(
                color: remaining < 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySpendingCard(List<Expense> expenses) {
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

    final monthlyEntries = monthlyData.entries.toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Spending',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              monthlyEntries[value.toInt()].key,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('\$${value.toInt()}');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    monthlyEntries.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: monthlyEntries[index].value,
                          color: Colors.blue,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChartCard(List<Expense> expenses) {
    // Group expenses by category
    final categoryData = <String, double>{};

    for (var expense in expenses) {
      categoryData.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    final categoryEntries = categoryData.entries.toList();
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 60,
                  sections: List.generate(
                    categoryEntries.length,
                    (index) => PieChartSectionData(
                      color: colors[index % colors.length],
                      value: categoryEntries[index].value,
                      title:
                          '${categoryEntries[index].key}\n'
                          '\$${categoryEntries[index].value.toStringAsFixed(0)}',
                      radius: 20,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {},
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
