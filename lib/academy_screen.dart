import 'package:flutter/material.dart';
import 'models_data.dart';

class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key});

  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen> {
  final Set<int> _completedLessons = {};

  @override
  Widget build(BuildContext context) {
    final progress = appLessons.isEmpty ? 0.0 : _completedLessons.length / appLessons.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Академия: с 0 до Профи'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Прогресс обучения: ${_completedLessons.length} из ${appLessons.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  color: Colors.tealAccent,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Изучи теорию простым языком, разбери формулы и переходи во вкладку «Симулятор», чтобы проверить всё на практике.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(appLessons.length, (index) {
            final lesson = appLessons[index];
            final isDone = _completedLessons.contains(index);

            return Card(
              color: const Color(0xFF1E293B),
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isDone ? Colors.greenAccent : Colors.white12,
                  width: isDone ? 1.5 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            lesson.level,
                            style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (isDone)
                          const Icon(Icons.check_circle, color: Colors.greenAccent),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lesson.simpleText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _infoBox(
                      icon: Icons.functions,
                      title: 'Формула простыми словами:',
                      text: lesson.formula,
                      color: Colors.amberAccent,
                    ),
                    const SizedBox(height: 8),
                    _infoBox(
                      icon: Icons.calculate_outlined,
                      title: 'Пример расчета в рублях:',
                      text: lesson.example,
                      color: Colors.tealAccent,
                    ),
                    const SizedBox(height: 8),
                    _infoBox(
                      icon: Icons.warning_amber_rounded,
                      title: 'Главный риск:',
                      text: lesson.risk,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDone ? Colors.green.shade800 : Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          setState(() {
                            if (isDone) {
                              _completedLessons.remove(index);
                            } else {
                              _completedLessons.add(index);
                            }
                          });
                        },
                        icon: Icon(isDone ? Icons.done_all : Icons.check),
                        label: Text(
                          isDone
                              ? 'Урок пройден (нажми, чтобы повторить)'
                              : 'Понятно! Отметить изученным',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _infoBox({
    required IconData icon,
    required String title,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.35),
          ),
        ],
      ),
    );
  }
}

