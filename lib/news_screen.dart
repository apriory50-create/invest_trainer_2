import 'package:flutter/material.dart';
import 'news_feed_01.dart';
import 'news_feed_02.dart';
import 'news_feed_03.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _selectedCategory = 'Все';
  String _query = '';

  List<MarketNewsItem> get _allNews => [
        ...newsBatch01,
        ...newsBatch02,
        ...newsBatch03,
      ];

  @override
  Widget build(BuildContext context) {
    final items = _allNews;
    final categories = ['Все', ...items.map((e) => e.category).toSet()];

    final filtered = items.where((n) {
      final catOk = _selectedCategory == 'Все' || n.category == _selectedCategory;
      final q = _query.trim().toLowerCase();
      final textOk = q.isEmpty ||
          n.title.toLowerCase().contains(q) ||
          n.plainMeaning.toLowerCase().contains(q) ||
          n.whatToDo.toLowerCase().contains(q);
      return catOk && textOk;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Поиск новости, темы или действия...',
              prefixIcon: const Icon(Icons.newspaper),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final c = categories[i];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c),
                  selected: _selectedCategory == c,
                  onSelected: (_) => setState(() => _selectedCategory = c),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Новостей с разбором: ${filtered.length} (всего в базе: ${items.length})',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            itemBuilder: (context, idx) {
              final item = filtered[idx];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  title: Text('#${item.id}. ${item.title}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('${item.category} • ${item.plainMeaning}',
                      maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                  childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  children: [
                    _row('На пальцах:', item.plainMeaning),
                    _row('ОФЗ:', item.ofzImpact),
                    _row('Корп. облигации:', item.bondImpact),
                    _row('Акции:', item.stockImpact),
                    _row('БПИФы:', item.etfImpact),
                    _row('Перспектива:', item.outlook),
                    _row('Что делать:', item.whatToDo),
                    _row('На что смотреть:', item.watchFor),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.35),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}
