import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/expense_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  ExpenseProvider() {
    _loadExpenses();
  }

  void _loadExpenses() {
    _expenseService.expensesStream.listen((expenses) {
      _expenses = expenses;
      notifyListeners();
    });
  }

  Future<void> addExpense(Expense newExpense) async {
    await _expenseService.addExpense(newExpense);
  }

  Future<void> updateExpense(String id, Expense updatedExpense) async {
    await _expenseService.updateExpense(updatedExpense);
  }

  Future<void> deleteExpense(String id) async {
    await _expenseService.deleteExpense(id);
  }
}
