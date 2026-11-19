import 'package:flutter/material.dart';
import 'real_investor_sim.dart';
import 'news_screen.dart';

void main() {
  runApp(const InvestTrainerApp());
}

class InvestTrainerApp extends StatefulWidget {
  const InvestTrainerApp({super.key});

  @override
  State<InvestTrainerApp> createState() => _InvestTrainerAppState();
}

class _InvestTrainerAppState extends State<InvestTrainerApp> {
  ThemeMode _themeMode = ThemeMode.system;
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Симулятор и Новости Инвестора',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(_tabIndex == 0 ? 'Симулятор Инвестора' : 'Разбор Новостей (80+)'),
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
        body: _tabIndex == 0 ? const RealInvestorSimScreen() : const NewsScreen(),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tabIndex,
          onDestinationSelected: (i) => setState(() => _tabIndex = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.candlestick_chart), label: 'Симулятор'),
            NavigationDestination(icon: Icon(Icons.newspaper), label: 'Новости'),
          ],
        ),
      ),
    );
  }
}



