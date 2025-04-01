import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';

class BudgetProvider with ChangeNotifier {
  double _monthlyBudget = 0;
  final Map<String, double> _categoryBudgets = {};

  double get monthlyBudget => _monthlyBudget;
  Map<String, double> get categoryBudgets => _categoryBudgets;

  void setMonthlyBudget(double amount) {
    _monthlyBudget = amount;
    notifyListeners();
  }

  void setCategoryBudget(String category, double amount) {
    _categoryBudgets[category] = amount;
    notifyListeners();
  }

  double getRemainingBudget(List<Expense> expenses) {
    final monthlySpent = expenses
        .where((e) => e.date.month == DateTime.now().month)
        .fold(0.0, (sum, e) => sum + e.amount);
    return _monthlyBudget - monthlySpent;
  }

  double getRemainingCategoryBudget(String category, List<Expense> expenses) {
    final categorySpent = expenses
        .where((e) => e.category == category)
        .fold(0.0, (sum, e) => sum + e.amount);
    return (_categoryBudgets[category] ?? 0) - categorySpent;
  }
}
