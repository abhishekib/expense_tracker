import 'package:expense_tracker/screens/analytics_screen.dart';
import 'package:expense_tracker/screens/budget_screen.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/screens/add_expense_screen.dart';
import 'package:expense_tracker/screens/history_screen.dart';
import 'package:expense_tracker/screens/reports_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HistoryScreen(),
    AddExpenseScreen(),
    ReportsScreen(),
    BudgetScreen(),
    AnalyticsScreen(),
  ];

  DateTime? _lastBackPressTime;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: true,
          selectedLabelStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          showUnselectedLabels: true,
          unselectedLabelStyle: TextStyle(color: Colors.blueGrey),
          selectedItemColor: Colors.black,

          unselectedItemColor: Colors.blueGrey,
          enableFeedback: true,
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Budget',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex == 0) {
      final now = DateTime.now();
      if (_lastBackPressTime == null ||
          now.difference(_lastBackPressTime!) > Duration(seconds: 2)) {
        _lastBackPressTime = now;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Press back again to exit')));
        return false;
      }
      return true;
    } else {
      setState(() => _currentIndex = 0);
      return false;
    }
  }
}
