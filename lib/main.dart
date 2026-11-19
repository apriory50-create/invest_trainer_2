import 'package:flutter/material.dart';
import 'real_investor_sim.dart';
import 'news_screen.dart';
import 'academy_screen.dart';
import 'scenarios_screen.dart';
import 'calculators_screen.dart';

void main() {
  runApp(const InvestTrainerApp());
}

class InvestTrainerApp extends StatefulWidget {
  const InvestTrainerApp({super.key});

  @override
  State<InvestTrainerApp> createState() => _InvestTrainerAppState();
}

class _InvestTrainerAppState extends State<InvestTrainerApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  int _tabIndex = 0;

  final List<String> _titles = const [
    'Академия: с 0 до Профи',
    'Симулятор Инвестора',
    'Рыночные Сценарии',
    'Разбор Новостей',
    'Калькуляторы',
  ];

  final List<Widget> _screens = const [
    AcademyScreen(),
    RealInvestorSimScreen(),
    ScenariosScreen(),
    NewsScreen(),
    CalculatorsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Инвест-Тренер Профи',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(_titles[_tabIndex]),
          actions: [
            IconButton(
              tooltip: 'Сменить тему',
              icon: Icon(
                _themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: () {
                setState(() {
                  _themeMode =
                      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                });
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: _tabIndex,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tabIndex,
          onDestinationSelected: (i) => setState(() => _tabIndex = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.school), label: 'Академия'),
            NavigationDestination(icon: Icon(Icons.candlestick_chart), label: 'Симулятор'),
            NavigationDestination(icon: Icon(Icons.psychology), label: 'Сценарии'),
            NavigationDestination(icon: Icon(Icons.newspaper), label: 'Новости'),
            NavigationDestination(icon: Icon(Icons.calculate), label: 'Расчеты'),
          ],
        ),
      ),
    );
  }
}



