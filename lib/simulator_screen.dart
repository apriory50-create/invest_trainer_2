import 'package:flutter/material.dart';
import 'scenarios_all.dart';
import 'scenarios_part1.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  String _selectedFilter = 'Все';
  String _searchQuery = '';
  int _selectedIndex = 0;

  List<String> get _filters {
    final set = <String>{'Все'};
    for (final s in kAllScenarios) {
      final first = s.assetType.split('/').first.trim();
      if (first.isNotEmpty) set.add(first);
    }
    return set.take(8).toList();
  }

  List<MarketScenario> get _filteredScenarios {
    return kAllScenarios.where((s) {
      final matchesFilter = _selectedFilter == 'Все' ||
          s.assetType.toLowerCase().contains(_selectedFilter.toLowerCase());
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          s.title.toLowerCase().contains(q) ||
          s.newsHeadline.toLowerCase().contains(q) ||
          s.assetType.toLowerCase().contains(q);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredScenarios;
    final current = items.isEmpty
        ? null
        : items[_selectedIndex.clamp(0, items.length - 1)];

    return Scaffold(
      appBar: AppBar(
        title: Text('Сценарии (${kAllScenarios.length})'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Поиск по теме, новости или активу...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) => setState(() {
                _searchQuery = val;
                _selectedIndex = 0;
              }),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final active = f == _selectedFilter;
                return ChoiceChip(
                  label: Text(f),
                  selected: active,
                  onSelected: (_) => setState(() {
                    _selectedFilter = f;
                    _selectedIndex = 0;
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 54,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (_, i) {
                final s = items[i];
                final selected = i == _selectedIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text('#${s.id}'),
                    backgroundColor: selected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    onPressed: () => setState(() => _selectedIndex = i),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 8),
          Expanded(
            child: current == null
                ? const Center(child: Text('Ничего не найдено'))
                : _ScenarioCard(scenario: current),
          ),
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final MarketScenario scenario;

  const _ScenarioCard({required this.scenario});

  Widget _block(BuildContext context, String label, String text, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          '#${scenario.id} · ${scenario.assetType}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          scenario.title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('Новость: ${scenario.newsHeadline}'),
        ),
        const SizedBox(height: 12),
        _block(context, 'Суть на пальцах', scenario.plainExplanation, Icons.lightbulb_outline),
        _block(context, 'Косвенные признаки', scenario.indirectSigns, Icons.visibility_outlined),
        _block(context, 'Правило входа', scenario.entryRule, Icons.login),
        _block(context, 'Правило выхода', scenario.exitRule, Icons.logout),
        _block(context, 'Формула и риск', scenario.riskFormula, Icons.calculate_outlined),
        _block(context, 'Лучшее действие', scenario.bestAction, Icons.check_circle_outline),
      ],
    );
  }
}

