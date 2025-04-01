import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/budget_provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Budget Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Monthly Budget',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                budgetProvider.setMonthlyBudget(double.tryParse(value) ?? 0);
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  for (final category in ['Food', 'Transport', 'Entertainment'])
                    ListTile(
                      title: Text(category),
                      trailing: SizedBox(
                        width: 100,
                        child: TextField(
                          decoration: InputDecoration(prefixText: '\$'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            budgetProvider.setCategoryBudget(
                              category,
                              double.tryParse(value) ?? 0,
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
