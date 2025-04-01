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
      appBar: AppBar(
        title: Text('Transaction History'),
        actions: [_buildFilterButton(), _buildSortButton()],
      ),
      body: Column(
        children: [
          if (_dateRange != null) _buildDateRangeChip(),
          Expanded(
            child:
                expenses.isEmpty
                    ? Center(child: Text('No expenses found'))
                    : ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder:
                          (ctx, index) => ExpenseTile(expense: expenses[index]),
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
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Dismissible(
      key: ValueKey(expense.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
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
                    child: Text('Delete'),
                    onPressed: () => Navigator.of(ctx).pop(true),
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) {
        expenseProvider.deleteExpense(expense.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Expense deleted')));
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(child: Text(expense.category[0])),
          title: Text(expense.title),
          subtitle: Text(dateFormat.format(expense.date)),
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
