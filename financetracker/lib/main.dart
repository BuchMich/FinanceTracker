import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/dashboard_page.dart';
import 'pages/add_transaction_page.dart';
import 'pages/statistics_page.dart';
import 'pages/goals_page.dart';
import 'pages/settings_page.dart';
import 'services/theme_service.dart';

final themeService = ThemeService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('de_DE');
  runApp(const FinanceFlowApp());
}

class FinanceFlowApp extends StatefulWidget {
  const FinanceFlowApp({super.key});

  @override
  State<FinanceFlowApp> createState() => _FinanceFlowAppState();
}

class _FinanceFlowAppState extends State<FinanceFlowApp> {
  @override
  void initState() {
    super.initState();
    themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinanceFlow',
      debugShowCheckedModeBanner: false,
      themeMode: themeService.flutterThemeMode,
      theme: themeService.lightTheme,
      darkTheme: themeService.darkTheme,
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

  final _pages = <Widget>[
    const DashboardPage(),
    const AddTransactionPage(),
    const StatisticsPage(),
    const GoalsPage(),
    const SettingsPage(),
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
