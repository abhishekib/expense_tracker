import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/providers/budget_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedTimePeriod = 'Last 6 Months';

  Widget _buildTimePeriodSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text('Time Period: ', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _selectedTimePeriod,
            items:
                ['Last Month', 'Last 3 Months', 'Last 6 Months', 'This Year']
                    .map(
                      (period) =>
                          DropdownMenuItem(value: period, child: Text(period)),
                    )
                    .toList(),
            onChanged: (value) {
              // Implement time period filtering
              setState(() => _selectedTimePeriod = value!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingInsights(List<Expense> expenses) {
    if (expenses.isEmpty) return SizedBox();

    final highestExpense = expenses.reduce(
      (a, b) => a.amount > b.amount ? a : b,
    );
    final averageSpending =
        expenses.fold(0.0, (sum, e) => sum + e.amount) / expenses.length;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending Insights',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.arrow_upward, color: Colors.red),
              title: Text('Highest Expense'),
              subtitle: Text(
                '\$${highestExpense.amount.toStringAsFixed(2)} - ${highestExpense.title}',
              ),
            ),
            ListTile(
              leading: Icon(Icons.calculate, color: Colors.blue),
              title: Text('Average Daily Spending'),
              subtitle: Text('\$${averageSpending.toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenses = Provider.of<ExpenseProvider>(context).expenses;
    final budgetProvider = Provider.of<BudgetProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Spending Analytics')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMonthlySpendingChart(expenses),
            SizedBox(height: 20),
            _buildCategoryBreakdown(expenses),
            SizedBox(height: 20),
            _buildBudgetCompliance(budgetProvider, expenses),
            SizedBox(height: 20),
            _buildSpendingInsights(expenses),
            SizedBox(height: 20),
            _buildTimePeriodSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySpendingChart(List<Expense> expenses) {
    // Group expenses by month
    final monthlyData = <DateTime, double>{};
    final now = DateTime.now();

    for (var expense in expenses) {
      final monthStart = DateTime(expense.date.year, expense.date.month);
      monthlyData.update(
        monthStart,
        (total) => total + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    // Get last 6 months
    final months = List.generate(
      6,
      (i) => DateTime(now.year, now.month - 5 + i),
    );

    final spots =
        months.map((month) {
          return FlSpot(month.month.toDouble(), monthlyData[month] ?? 0);
        }).toList();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Spending Trend',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            DateFormat(
                              'MMM',
                            ).format(DateTime(now.year, value.toInt())),
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.3),
                      ),
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

  Widget _buildCategoryBreakdown(List<Expense> expenses) {
    final categoryData = <String, double>{};

    for (var expense in expenses) {
      categoryData.update(
        expense.category,
        (total) => total + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections:
                      categoryData.entries.map((entry) {
                        return PieChartSectionData(
                          value: entry.value,
                          title:
                              '${entry.key}\n\$${entry.value.toStringAsFixed(0)}',
                          color: _getCategoryColor(entry.key),
                          radius: 60,
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCompliance(
    BudgetProvider budgetProvider,
    List<Expense> expenses,
  ) {
    final remainingBudget = budgetProvider.getRemainingBudget(expenses);
    final double percentageUsed =
        budgetProvider.monthlyBudget > 0
            ? (1 - (remainingBudget / budgetProvider.monthlyBudget)).clamp(0, 1)
            : 0;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Compliance',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: percentageUsed,
              minHeight: 20,
              backgroundColor: Colors.grey[200],
              color: percentageUsed > 0.9 ? Colors.red : Colors.green,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remaining: \$${remainingBudget.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: remainingBudget < 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total Budget: \$${budgetProvider.monthlyBudget.toStringAsFixed(2)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Food': Colors.blue,
      'Transportation': Colors.green,
      'Entertainment': Colors.orange,
      'Bills': Colors.red,
      'Shopping': Colors.purple,
      'Healthcare': Colors.teal,
      'Other': Colors.grey,
    };
    return colors[category] ?? Colors.amber;
  }
}
