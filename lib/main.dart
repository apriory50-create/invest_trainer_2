import 'package:flutter/material.dart';
import 'real_investor_sim.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Симулятор Инвестора',
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
          title: const Text('Симулятор Инвестора'),
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
        body: const RealInvestorSimScreen(),
      ),
    );
  }
}


