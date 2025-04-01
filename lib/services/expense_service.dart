import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/expense.dart';

class ExpenseService {
  final CollectionReference _expensesCollection =
      FirebaseFirestore.instance.collection('expenses');

  // Add new expense
  Future<void> addExpense(Expense expense) async {
    await _expensesCollection.doc(expense.id).set({
      'title': expense.title,
      'amount': expense.amount,
      'date': expense.date.toIso8601String(),
      'category': expense.category,
      'userId': '', // We'll add auth later
    });
  }

  // Update existing expense
  Future<void> updateExpense(Expense expense) async {
    await _expensesCollection.doc(expense.id).update({
      'title': expense.title,
      'amount': expense.amount,
      'date': expense.date.toIso8601String(),
      'category': expense.category,
    });
  }

  // Delete expense
  Future<void> deleteExpense(String id) async {
    await _expensesCollection.doc(id).delete();
  }

  // Get expenses stream
  Stream<List<Expense>> get expensesStream {
    return _expensesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Expense.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    });
  }
}