import 'package:flutter/material.dart';

class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key});

  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen> {
  int _selectedIdx = 0;

  final List> _lessons = [
    {
      'title': '1. Что такое инвестиции и сложный процент',
      'level': 'Новичок',
      'time': '5 мин',
      'summary':
          'Деньги должны работать и приносить доход. Сложный процент — это когда проценты начисляются на уже накопленные проценты.',
      'rule': 'Начинайте с малого, но регулярно — время важнее суммы.',
    },
    {
      'title': '2. Акции, облигации и ETF',
      'level': 'Новичок',
      'time': '7 мин',
      'summary':
          'Акция — доля в бизнесе с потенциалом роста. Облигация — долг с предсказуемым купоном. ETF — готовый набор активов.',
      'rule': 'Не кладите все яйца в одну корзину: диверсификация снижает риск.',
    },
    {
      'title': '3. Риск, волатильность и горизонт',
      'level': 'Базовый',
      'time': '6 мин',
      'summary':
          'Высокая доходность всегда связана с колебаниями цены. Чем длиннее срок вложений, тем легче пережить просадки.',
      'rule': 'Вкладывайте в рисковые активы только деньги на горизонте от 3–5 лет.',
    },
    {
      'title': '4. Фундаментальный и новостной анализ',
      'level': 'Продвинутый',
      'time': '8 мин',
      'summary':
          'Смотрим на долги компании, прибыль, ставки ЦБ и новости отрасли, чтобы отличать шум от реальных изменений.',
      'rule': 'Реагируйте на факты и отчёты, а не на панику в заголовках.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final lesson = _lessons[_selectedIdx];
    return Scaffold(
      appBar: AppBar(title: const Text('Академия инвестора')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF161B26),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.tealAccent.withOpacity(0.4)),
            ),
            child: const Text(
              'Путь от нуля до уверенного инвестора: выберите урок ниже.',
              style: TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_lessons.length, (i) {
            final item = _lessons[i];
            final active = i == _selectedIdx;
            return Card(
              color: active ? const Color(0xFF1D2738) : const Color(0xFF141923),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () => setState(() => _selectedIdx = i),
                leading: CircleAvatar(
                  backgroundColor: active
                      ? Colors.tealAccent
                      : Colors.blueAccent.withOpacity(0.2),
                  foregroundColor: active ? Colors.black : Colors.white,
                  child: Text('${i + 1}'),
                ),
                title: Text(
                  item['title']!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('${item['level']} • ${item['time']}'),
                trailing: Icon(
                  active ? Icons.check_circle : Icons.chevron_right,
                  color: active ? Colors.tealAccent : Colors.white54,
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          _LessonCard(lesson: lesson),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Map<String, String> lesson;

  const _LessonCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson['title']!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            lesson['summary']!,
            style: const TextStyle(fontSize: 15, height: 1.45),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.4)),
            ),
            child: Text(
              'Главное правило: ${lesson['rule']!}',
              style: const TextStyle(
                color: Colors.amberAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


