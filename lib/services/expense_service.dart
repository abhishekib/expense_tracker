import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExpenseService {
  final CollectionReference _expensesCollection = FirebaseFirestore.instance
      .collection('expenses');

  Future<void> addExpense(Expense expense) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _expensesCollection.doc(expense.id).set({
      ...expense.toMap(),
      'userId': user.uid, // Add user ID to each expense
    });
  }

  Future<List<Expense>> getExpenses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final snapshot =
          await _expensesCollection
              .where('userId', isEqualTo: user.uid)
              .orderBy('date', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        return Expense.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
      throw Exception('Failed to load expenses');
    }
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

  Stream<List<Expense>> get expensesStream {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    try {
      return _expensesCollection
          .where('userId', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .snapshots()
          .handleError((error) {
            debugPrint('Firestore stream error: $error');
            // You can add error reporting here (e.g., Crashlytics)
          })
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) {
                  return Expense.fromMap({
                    'id': doc.id,
                    ...doc.data() as Map<String, dynamic>,
                  });
                }).toList(),
          );
    } catch (e) {
      debugPrint('Error creating stream: $e');
      return Stream.value([]);
    }
  }
}
