import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';
import 'pages/add_transaction_page.dart';
import 'pages/statistics_page.dart';
import 'pages/goals_page.dart';
import 'pages/settings_page.dart';

void main() => runApp(const FinanceFlowApp());

class FinanceFlowApp extends StatelessWidget {
  const FinanceFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinanceFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _pages = const <Widget>[
    DashboardPage(),
    AddTransactionPage(),
    StatisticsPage(),
    GoalsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dash'),
          NavigationDestination(icon: Icon(Icons.add_circle), label: 'Neu'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stat'),
          NavigationDestination(icon: Icon(Icons.savings), label: 'Ziele'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Einst'),
        ],
      ),
    );
  }
}
