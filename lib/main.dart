import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lessons_data.dart';
import 'academy_screen.dart';
import 'simulator_screen.dart';
import 'pro_filters_screen.dart';
import 'calculators_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const InvestTrainerApp());
}

class InvestTrainerApp extends StatelessWidget {
  const InvestTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invest Trainer PRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E131F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFFFF5252),
          surface: Color(0xFF171F30),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF171F30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        useMaterial3: true,
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _tabIndex = 0;
  bool _isProMode = false;
  Set<int> _completedLessons = {};
  double _virtualBalance = 1000000.0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList('completed_lessons') ?? [];
    final savedBalance = prefs.getDouble('virtual_balance') ?? 1000000.0;
    final savedPro = prefs.getBool('is_pro_mode') ?? false;
    if (!mounted) return;
    setState(() {
      _completedLessons = savedIds.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();
      _virtualBalance = savedBalance;
      _isProMode = savedPro;
    });
  }

  Future<void> _completeLesson(int id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _completedLessons.add(id);
    });
    await prefs.setStringList(
      'completed_lessons',
      _completedLessons.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _updateBalance(double newBalance) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _virtualBalance = newBalance;
    });
    await prefs.setDouble('virtual_balance', newBalance);
  }

  Future<void> _toggleProMode(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isProMode = val;
    });
    await prefs.setBool('is_pro_mode', val);
  }

  void _showCheckpointDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ЧЕКПОИНТ-32'),
        content: Text(
          'Статус сборки: Активен\n'
          'Пройдено уроков: ${_completedLessons.length} из ${academyLessons.length}\n'
          'Сценариев в тренажере: 100\n'
          'Вкладка «5 Фильтров Профи»: Активна\n'
          'Вкладка «Калькулятор ОФЗ и ИИС-3»: Активна\n'
          'Капитал портфеля: ${_virtualBalance.toStringAsFixed(0)} ₽',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      AcademyScreen(
        isProMode: _isProMode,
        completedLessons: _completedLessons,
        onCompleteLesson: _completeLesson,
      ),
      SimulatorScreen(
        balance: _virtualBalance,
        onBalanceChanged: _updateBalance,
      ),
      const ProFiltersScreen(),
      const CalculatorsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF171F30),
        title: GestureDetector(
          onTap: _showCheckpointDialog,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Invest Trainer • ЧЕКПОИНТ-32',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                'Уроков: ${_completedLessons.length}/${academyLessons.length} • Капитал: ${_virtualBalance.toStringAsFixed(0)} ₽',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF00E676)),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Text(
                _isProMode ? 'ПРОФИ' : 'С НУЛЯ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _isProMode ? Colors.amberAccent : const Color(0xFF00E676),
                ),
              ),
              Switch(
                value: _isProMode,
                activeColor: Colors.amberAccent,
                onChanged: _toggleProMode,
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(child: pages[_tabIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (idx) => setState(() => _tabIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school, color: Color(0xFF00E676)),
            label: 'Академия',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up, color: Color(0xFF00E676)),
            label: 'Симулятор',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check, color: Color(0xFF00E676)),
            label: '5 Фильтров',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate, color: Color(0xFF00E676)),
            label: 'Калькулятор',
          ),
        ],
      ),
    );
  }
}

