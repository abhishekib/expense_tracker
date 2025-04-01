import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  void addExpense(Expense newExpense) {
    _expenses.add(newExpense);
    notifyListeners();
  }

  void updateExpense(String id, Expense updatedExpense) {
    final index = _expenses.indexWhere((expense) => expense.id == id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
      notifyListeners();
    }
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }
}
