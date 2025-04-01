import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Food';

  final List<String> _categories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Bills',
    'Shopping',
    'Healthcare',
    'Other',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitExpense() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newExpense = Expense(
          id: Uuid().v4(),
          title: _titleController.text,
          amount: double.parse(_amountController.text),
          date: _selectedDate,
          category: _selectedCategory,
        );

        await Provider.of<ExpenseProvider>(
          context,
          listen: false,
        ).addExpense(newExpense);

        // Reset form after successful submission
        _resetForm();

        // Show success message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Expense added successfully!')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _amountController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedCategory = 'Food';
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense'),
        actions: [
          IconButton(icon: Icon(Icons.check), onPressed: _submitExpense),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Date'),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items:
                    _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
