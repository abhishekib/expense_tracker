import 'package:csv/csv.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ExportService {
  static final dateFormat = DateFormat('yyyy-MM-dd');

  String exportToCSV(List<Expense> expenses) {
    try {
      final rows = [
        ['Date', 'Category', 'Description', 'Amount'],
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
    } catch (e) {
      throw Exception('CSV generation failed: $e');
    }
  }

  Future<File> saveCSV(String csvData, String fileName) async {
    try {
      final directory =
          await getDownloadsDirectory() ?? await getTemporaryDirectory();
      final path = '${directory.path}/$fileName';
      final file = File(path);

      await file.writeAsString(csvData);
      return file;
    } catch (e) {
      throw Exception('File save failed: $e');
    }
  }
}
