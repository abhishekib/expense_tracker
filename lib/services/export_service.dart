import 'package:csv/csv.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:intl/intl.dart';

class ExportService {
  String exportToCSV(List<Expense> expenses) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    final rows = [
      ['Date', 'Category', 'Description', 'Amount'], // Header
      ...expenses.map(
        (e) => [
          dateFormat.format(e.date),
          e.category,
          e.title,
          e.amount.toStringAsFixed(2),
        ],
      ),
    ];

    return const ListToCsvConverter().convert(rows);
  }

  Future<void> saveCSV(String csvData, String fileName) async {
    // Implementation for saving file
    // Requires file_picker and permission_handler packages
  }
}
