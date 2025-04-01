import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/expense_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  List<Expense> _expenses = [];
  final List<Expense> _pendingExpenses = [];
  List<Expense> get expenses => [..._expenses, ..._pendingExpenses];

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
      final freshExpenses = await _expenseService.getExpenses();
      _expenses = freshExpenses;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to refresh expenses: $e');
    }
  }

  Future<void> addExpense(Expense newExpense) async {
    try {
      // Add to pending first for offline support
      _pendingExpenses.add(newExpense);
      notifyListeners();

      // Try to sync with Firebase
      await _expenseService.addExpense(newExpense);

      // If successful, move from pending to main list
      _pendingExpenses.remove(newExpense);
      _expenses.add(newExpense);
      notifyListeners();
    } catch (e) {
      // Keep in pending queue if offline
      debugPrint('Expense saved locally: ${e.toString()}');
    }
  }

  Future<void> syncPendingExpenses() async {
    try {
      for (final expense in List.of(_pendingExpenses)) {
        await _expenseService.addExpense(expense);
        _pendingExpenses.remove(expense);
        _expenses.add(expense);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Sync failed: ${e.toString()}');
    }
  }

  Stream<List<Expense>> get expensesStream {
    return _expenseService.expensesStream;
  }

  Future<void> updateExpense(String id, Expense updatedExpense) async {
    await _expenseService.updateExpense(updatedExpense);
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _expenseService.deleteExpense(id);
      _expenses.removeWhere((expense) => expense.id == id);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }
}
