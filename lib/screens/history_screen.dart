import 'package:expense_tracker/services/export_service.dart';
import 'package:expense_tracker/widgets/safe_stream_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _sortBy = 'date';
  String _filterCategory = 'All';
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    final expenses = _getFilteredExpenses(context);

    return Scaffold(
      drawer: Drawer(
        // Your drawer implementation here
        child: ListView(
          children: [
            DrawerHeader(
              child: Text('Expense Tracker'),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            // Add more drawer items as needed
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Transaction History'),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          // Combined filter and sort button
          PopupMenuButton<String>(
            icon: Icon(Icons.tune),
            onSelected: (value) {
              if (value == 'export') {
                _exportToCSV(context);
              } else if (value == 'categories') {
                showDialog(
                  context: context,
                  builder: _buildCategoryFilterDialog,
                );
              } else if (value == 'date_range') {
                _selectDateRange(context);
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'categories',
                    child: ListTile(
                      leading: Icon(Icons.category),
                      title: Text('Filter by Category'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'date_range',
                    child: ListTile(
                      leading: Icon(Icons.date_range),
                      title: Text('Select Date Range'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Icons.upload),
                      title: Text('Export to CSV'),
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.sort),
                      title: Text('Sort Options'),
                    ),
                    enabled: false,
                  ),
                  ..._buildSortOptions(),
                ],
          ),
        ],
      ),
      body: SafeStreamBuilder<List<Expense>>(
        stream: Provider.of<ExpenseProvider>(context).expensesStream,
        initialData: [],
        builder: (context, snapshot) {
          final expenses = snapshot.data ?? [];

          if (expenses.isEmpty) {
            return Center(child: Text('No expenses found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              try {
                await context.read<ExpenseProvider>().refreshExpenses();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Refresh failed: ${e.toString()}')),
                );
                rethrow;
              }
            },
            child: ListView.builder(
              itemCount: expenses.length,
              itemBuilder:
                  (ctx, index) => ExpenseTile(expense: expenses[index]),
            ),
          );
        },
      ),
    );
  }

  List<PopupMenuItem<String>> _buildSortOptions() {
    return [
      PopupMenuItem(
        value: 'date',
        child: ListTile(
          leading: Icon(Icons.arrow_downward),
          title: Text('Date (Newest First)'),
          trailing: _sortBy == 'date' ? Icon(Icons.check) : null,
        ),
      ),
      PopupMenuItem(
        value: 'date_old',
        child: ListTile(
          leading: Icon(Icons.arrow_upward),
          title: Text('Date (Oldest First)'),
          trailing: _sortBy == 'date_old' ? Icon(Icons.check) : null,
        ),
      ),
      PopupMenuItem(
        value: 'amount_high',
        child: ListTile(
          leading: Icon(Icons.arrow_downward),
          title: Text('Amount (High to Low)'),
          trailing: _sortBy == 'amount_high' ? Icon(Icons.check) : null,
        ),
      ),
      PopupMenuItem(
        value: 'amount_low',
        child: ListTile(
          leading: Icon(Icons.arrow_upward),
          title: Text('Amount (Low to High)'),
          trailing: _sortBy == 'amount_low' ? Icon(Icons.check) : null,
        ),
      ),
      PopupMenuItem(
        value: 'category',
        child: ListTile(
          leading: Icon(Icons.sort_by_alpha),
          title: Text('Category (A-Z)'),
          trailing: _sortBy == 'category' ? Icon(Icons.check) : null,
        ),
      ),
    ];
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (range != null) {
      setState(() => _dateRange = range);
    }
  }

  Future<void> _exportToCSV(BuildContext context) async {
    try {
      final exporter = ExportService();
      final expenses =
          Provider.of<ExpenseProvider>(context, listen: false).expenses;
      final csv = exporter.exportToCSV(expenses);
      await exporter.saveCSV(
        csv,
        'expenses_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Expenses exported successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: ${e.toString()}')));
    }
  }

  Widget _buildCategoryFilterDialog(BuildContext context) {
    final categories =
        Provider.of<ExpenseProvider>(
          context,
        ).expenses.map((e) => e.category).toSet().toList();

    categories.insert(0, 'All');

    return AlertDialog(
      title: Text('Filter by Category'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: categories.length,
          itemBuilder:
              (ctx, index) => ListTile(
                title: Text(categories[index]),
                trailing:
                    _filterCategory == categories[index]
                        ? Icon(
                          Icons.check,
                          color: Theme.of(context).primaryColor,
                        )
                        : null,
                onTap: () {
                  setState(() => _filterCategory = categories[index]);
                  Navigator.pop(context);
                },
              ),
        ),
      ),
    );
  }

  List<Expense> _getFilteredExpenses(BuildContext context) {
    List<Expense> expenses = Provider.of<ExpenseProvider>(context).expenses;

    // Apply category filter
    if (_filterCategory != 'All') {
      expenses = expenses.where((e) => e.category == _filterCategory).toList();
    }

    // Apply date range filter
    if (_dateRange != null) {
      expenses =
          expenses
              .where(
                (e) =>
                    e.date.isAfter(_dateRange!.start) &&
                    e.date.isBefore(_dateRange!.end),
              )
              .toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'date':
        expenses.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'date_old':
        expenses.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'amount_high':
        expenses.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'amount_low':
        expenses.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'category':
        expenses.sort((a, b) => a.category.compareTo(b.category));
        break;
    }

    return expenses;
  }
}

class ExpenseTile extends StatelessWidget {
  final Expense expense;

  const ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id), // Unique key for each item
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: Text('Confirm Delete'),
                content: Text('Are you sure you want to delete this expense?'),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(ctx).pop(false),
                  ),
                  TextButton(
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                    onPressed: () => Navigator.of(ctx).pop(true),
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) async {
        try {
          await Provider.of<ExpenseProvider>(
            context,
            listen: false,
          ).deleteExpense(expense.id);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Expense deleted successfully')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete expense: $e')),
          );
          // Optional: Re-insert the item if deletion fails
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                expense.category[0],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          title: Text(expense.title),
          subtitle: Text(DateFormat('MMM d, y').format(expense.date)),
          trailing: Text(
            '\$${expense.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => EditExpenseScreen(expense: expense),
              ),
            );
          },
        ),
      ),
    );
  }
}

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({required this.expense});

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late DateTime _selectedDate;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController = TextEditingController(
      text: widget.expense.amount.toStringAsFixed(2),
    );
    _selectedDate = widget.expense.date;
    _selectedCategory = widget.expense.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _updateExpense() {
    final updatedExpense = Expense(
      id: widget.expense.id,
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      category: _selectedCategory,
    );

    Provider.of<ExpenseProvider>(
      context,
      listen: false,
    ).updateExpense(widget.expense.id, updatedExpense);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Expense'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: Text('Confirm Delete'),
                      content: Text('Delete this expense permanently?'),
                      actions: [
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.of(ctx).pop(false),
                        ),
                        TextButton(
                          child: Text('Delete'),
                          onPressed: () => Navigator.of(ctx).pop(true),
                        ),
                      ],
                    ),
              );

              if (confirmed == true) {
                try {
                  await Provider.of<ExpenseProvider>(
                    context,
                    listen: false,
                  ).deleteExpense(widget.expense.id);

                  Navigator.of(context).pop(); // Close edit screen
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Expense deleted')));
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                }
              }
            },
          ),
          IconButton(icon: Icon(Icons.check), onPressed: _updateExpense),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            ListTile(
              title: Text('Date'),
              subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
              trailing: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
            ),
            DropdownButton<String>(
              value: _selectedCategory,
              items:
                  [
                    'Food',
                    'Transportation',
                    'Entertainment',
                    'Bills',
                    'Shopping',
                    'Healthcare',
                    'Other',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
