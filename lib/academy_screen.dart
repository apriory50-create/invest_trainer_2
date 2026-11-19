import 'package:flutter/material.dart';
import 'models.dart';
import 'lessons_data.dart';

class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key});

  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen> {
  final Set<int> _completedIds = {};
  String _selectedModule = 'Все';
  String _search = '';

  List<Lesson> get _lessons => LessonsData.allLessons;

  List<String> get _modules {
    final set = <String>{'Все'};
    for (final l in _lessons) {
      if (l.moduleTitle.isNotEmpty) set.add(l.moduleTitle);
    }
    return set.toList();
  }

  List<Lesson> get _filtered {
    final q = _search.trim().toLowerCase();
    return _lessons.where((l) {
      final byMod = _selectedModule == 'Все' || l.moduleTitle == _selectedModule;
      final byText = q.isEmpty ||
          l.title.toLowerCase().contains(q) ||
          l.content.toLowerCase().contains(q) ||
          l.category.toLowerCase().contains(q);
      return byMod && byText;
    }).toList();
  }

  void _openLesson(Lesson lesson) {
    int? chosenOption;
    bool answered = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.92,
              maxChildSize: 0.96,
              minChildSize: 0.5,
              builder: (_, scrollCtrl) {
                return ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Chip(label: Text(lesson.category)),
                        const SizedBox(width: 8),
                        Text('~${lesson.readingTimeMinutes} мин'),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lesson.title,
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.moduleTitle,
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                    const Divider(height: 24),
                    Text(
                      lesson.content,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                    if (lesson.keyRules.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withOpacity(0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Главные правила:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            ...lesson.keyRules.map(
                              (r) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text('• $r'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Проверка понимания:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(lesson.question),
                          const SizedBox(height: 12),
                          ...List.generate(lesson.options.length, (i) {
                            final isCorrect = i == lesson.correctOptionIndex;
                            final isSelected = chosenOption == i;
                            Color? tileColor;
                            if (answered) {
                              if (isCorrect) {
                                tileColor = Colors.green.withOpacity(0.25);
                              } else if (isSelected) {
                                tileColor = Colors.red.withOpacity(0.25);
                              }
                            }
                            return Card(
                              color: tileColor,
                              child: ListTile(
                                title: Text(lesson.options[i]),
                                onTap: () {
                                  setModalState(() {
                                    chosenOption = i;
                                    answered = true;
                                  });
                                  if (i == lesson.correctOptionIndex) {
                                    setState(() => _completedIds.add(lesson.id));
                                  }
                                },
                              ),
                            );
                          }),
                          if (answered) ...[
                            const SizedBox(height: 8),
                            Text(
                              lesson.explanation,
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() => _completedIds.add(lesson.id));
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Отметить урок пройденным'),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _lessons.length;
    final done = _completedIds.length;
    final list = _filtered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Прогресс: $done из $total уроков',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(total == 0 ? '0%' : '${((done / total) * 100).round()}%'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: total == 0 ? 0 : done / total,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Поиск по урокам, терминам, темам...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: _modules.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final m = _modules[i];
              return ChoiceChip(
                label: Text(m, overflow: TextOverflow.ellipsis),
                selected: _selectedModule == m,
                onSelected: (_) => setState(() => _selectedModule = m),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final lesson = list[i];
              final isDone = _completedIds.contains(lesson.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isDone ? Colors.green : Colors.teal,
                    child: Icon(
                      isDone ? Icons.check : Icons.menu_book,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    lesson.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${lesson.moduleTitle} • ${lesson.readingTimeMinutes} мин'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openLesson(lesson),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


