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

  Future<void> _loadExpenses() async {
    _expenseService.expensesStream.listen((expenses) {
      _expenses = expenses;
      notifyListeners();
    });
  }

  Future<void> refreshExpenses() async {
    try {
      // Force a refresh by re-subscribing to the stream
      await _loadExpenses();
      // Alternatively, if using Firestore directly:
      // final freshExpenses = await _expenseService.getExpenses();
      // _expenses = freshExpenses;
      // notifyListeners();
    } catch (e) {
      throw Exception('Failed to refresh expenses: $e');
    }
  }

  Future<void> addExpense(Expense newExpense) async {
    try {
      // Add to local state immediately for responsive UI
      _expenses.add(newExpense);
      notifyListeners();

      // Sync with Firestore
      await _expenseService.addExpense(newExpense);
    } catch (e) {
      // Revert if Firestore fails
      _expenses.remove(newExpense);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateExpense(String id, Expense updatedExpense) async {
    await _expenseService.updateExpense(updatedExpense);
  }

  Future<void> deleteExpense(String id) async {
    await _expenseService.deleteExpense(id);
  }
}
