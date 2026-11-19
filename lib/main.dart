import 'package:flutter/material.dart';
import 'academy_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Тренажер Инвестора',
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
        body: _tabIndex == 0 ? const AcademyScreen() : const CalculatorsScreen(),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tabIndex,
          onDestinationSelected: (i) => setState(() => _tabIndex = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.school), label: 'Академия'),
            NavigationDestination(icon: Icon(Icons.calculate), label: 'Калькуляторы'),
          ],
        ),
        floatingActionButton: FloatingActionButton.small(
          tooltip: 'Сменить тему',
          onPressed: () {
            setState(() {
              _themeMode =
                  _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            });
          },
          child: Icon(
            _themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
          ),
        ),
      ),
    );
  }
}



