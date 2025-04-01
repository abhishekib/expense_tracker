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

  // Add this method to _HistoryScreenState
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

  @override
  Widget build(BuildContext context) {
    final expenses = _getFilteredExpenses(context);

    return Scaffold(
      // Update the appBar in HistoryScreen
      appBar: AppBar(
        title: Text('Transaction History'),
        actions: [
          IconButton(
            icon: Icon(Icons.category),
            onPressed:
                () => showDialog(
                  context: context,
                  builder: _buildCategoryFilterDialog,
                ),
          ),
          _buildFilterButton(),
          _buildSortButton(),
        ],
      ),
      body: Column(
        children: [
          if (_dateRange != null) _buildDateRangeChip(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                try {
                  await Provider.of<ExpenseProvider>(
                    context,
                    listen: false,
                  ).refreshExpenses();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Refresh failed: ${e.toString()}')),
                  );
                }
              },
              child:
                  expenses.isEmpty
                      ? Center(child: Text('No expenses found'))
                      : ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder:
                            (ctx, index) =>
                                ExpenseTile(expense: expenses[index]),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return PopupMenuButton(
      icon: Icon(Icons.filter_alt),
      itemBuilder:
          (context) => [
            PopupMenuItem(
              child: Text('Select Date Range'),
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (range != null) {
                  setState(() => _dateRange = range);
                }
              },
            ),
            PopupMenuItem(
              child: Text('Reset Filters'),
              onTap:
                  () => setState(() {
                    _filterCategory = 'All';
                    _dateRange = null;
                  }),
            ),
          ],
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton(
      icon: Icon(Icons.sort),
      itemBuilder:
          (context) => [
            PopupMenuItem(value: 'date', child: Text('Sort by Date (Newest)')),
            PopupMenuItem(
              value: 'date_old',
              child: Text('Sort by Date (Oldest)'),
            ),
            PopupMenuItem(
              value: 'amount_high',
              child: Text('Sort by Amount (High-Low)'),
            ),
            PopupMenuItem(
              value: 'amount_low',
              child: Text('Sort by Amount (Low-High)'),
            ),
            PopupMenuItem(value: 'category', child: Text('Sort by Category')),
          ],
      onSelected: (value) => setState(() => _sortBy = value),
    );
  }

  Widget _buildDateRangeChip() {
    return Chip(
      label: Text(
        '${DateFormat('MMM d').format(_dateRange!.start)} - '
        '${DateFormat('MMM d').format(_dateRange!.end)}',
      ),
      onDeleted: () => setState(() => _dateRange = null),
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
