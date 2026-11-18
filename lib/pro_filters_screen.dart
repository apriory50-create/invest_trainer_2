import 'package:flutter/material.dart';

class _PresetTicker {
  final String ticker;
  final String name;
  final List<bool> states;
  final String comment;
  const _PresetTicker(this.ticker, this.name, this.states, this.comment);
}

const List<_PresetTicker> _presets = [
  _PresetTicker(
    'SBER',
    'Сбербанк',
    [true, true, true, true, true],
    'Эталон: ROE > 22%, достаточность капитала в норме, P/E около 4–4.5x, стабильно платит 50% чистой прибыли дивидендами.',
  ),
  _PresetTicker(
    'LKOH',
    'Лукойл',
    [true, true, true, true, true],
    'Эталон: Отрицательный чистый долг (кубышка кэша), высокий свободный денежный поток (FCF), щедрые дивиденды.',
  ),
  _PresetTicker(
    'SU26238',
    'ОФЗ 26238 (на пике ставки ЦБ)',
    [true, true, true, true, true],
    'Государственная надежность РФ, покупка около 50–55% от номинала фиксирует высокую доходность к погашению и дает потенциал роста тела +30–40% при снижении ставки ЦБ.',
  ),
  _PresetTicker(
    'GAZP',
    'Газпром (в период высокого CAPEX)',
    [false, false, true, false, false],
    'Внимание: Огромные капитальные стройки съедают свободный денежный поток (FCF отрицательный), долг вырос, дивиденды под угрозой.',
  ),
  _PresetTicker(
    'SGZH',
    'Компания с долгом > 4x EBITDA',
    [false, false, false, false, false],
    'СТОП! Критический долг при высокой ставке ЦБ ведет к убыткам, риску дефолта или размывающей допэмиссии акций.',
  ),
];

class ProFiltersScreen extends StatefulWidget {
  const ProFiltersScreen({super.key});

  @override
  State<ProFiltersScreen> createState() => _ProFiltersScreenState();
}

class _ProFiltersScreenState extends State<ProFiltersScreen> {
  final TextEditingController _customTickerCtrl = TextEditingController(text: 'SBER');
  List<bool> _filters = [true, true, true, true, true];
  String _presetNote = _presets[0].comment;

  static const List> _filterDefs = [
    {
      'title': 'Фильтр 1. Безопасный долг (Net Debt / EBITDA < 2.0x)',
      'sub': 'У компании низкий долг или есть кубышка кэша (а для ОФЗ — госгарантия Минфина). Высокая ставка ЦБ не съедает прибыль.',
    },
    {
      'title': 'Фильтр 2. Живые деньги и прибыль (FCF > 0, ROE > 15%)',
      'sub': 'Бизнес генерирует положительный свободный денежный поток (FCF) после всех строек и стабильно наращивает выручку.',
    },
    {
      'title': 'Фильтр 3. Адекватная оценка без переплаты (P/E или YTM)',
      'sub': 'Акция стоит дешевле среднеисторического P/E (обычно < 6–8x) или облигация куплена ниже номинала с высокой YTM.',
    },
    {
      'title': 'Фильтр 4. Честные дивиденды или купоны без оферт-ловушек',
      'sub': 'Дивиденды платятся из реальной прибыли (не в долг!), а в облигации нет скрытой невыгодной оферты через месяц.',
    },
    {
      'title': 'Фильтр 5. Соответствие циклу ставки ЦБ и ликвидность',
      'sub': 'Бумага из 1–2 эшелона с узким спредом в стакане, а момент покупки совпадает с фазой ключевой ставки ЦБ.',
    },
  ];

  void _applyPreset(_PresetTicker p) {
    setState(() {
      _customTickerCtrl.text = '${p.ticker} (${p.name})';
      _filters = List<bool>.from(p.states);
      _presetNote = p.comment;
    });
  }

  @override
  void dispose() {
    _customTickerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int passed = _filters.where((e) => e).length;
    final Color statusColor = passed == 5
        ? Colors.greenAccent
        : passed >= 3
            ? Colors.amberAccent
            : Colors.redAccent;

    final String verdictTitle = passed == 5
        ? '5 из 5: ОДОБРЕНО В ЯДРО ПОРТФЕЛЯ'
        : passed == 4
            ? '4 из 5: ХОРОШИЙ АКТИВ (Соблюдай лимит до 5–10% портфеля)'
            : passed == 3
                ? '3 из 5: ПОВЫШЕННЫЙ РИСК (Только малая доля до 2–3%)'
                : 'МЕНЕЕ 3 из 5: СТОП! ИНВЕСТИЦИОННАЯ ЛОВУШКА';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        const Text(
          'Чек-лист «5 Фильтров Профи»',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Проверяй любую акцию или облигацию по этим 5 фильтрам перед нажатием кнопки «Купить». Выбери готовый пример ниже или переключай галочки вручную для своей бумаги.',
          style: TextStyle(color: Colors.white70, fontSize: 13.5),
        ),
        const SizedBox(height: 14),
        const Text('Быстрый разбор популярных бумаг:', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presets.map((p) {
            return ActionChip(
              label: Text(p.ticker),
              onPressed: () => _applyPreset(p),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _customTickerCtrl,
          decoration: const InputDecoration(
            labelText: 'Проверяемый тикер или бумага',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.verified_user_outlined),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          color: statusColor.withValues(alpha: 0.14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: statusColor, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verdictTitle,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: passed / 5.0,
                  minHeight: 8,
                  color: statusColor,
                  backgroundColor: Colors.white12,
                ),
                const SizedBox(height: 8),
                Text(_presetNote, style: const TextStyle(fontSize: 13, color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < _filterDefs.length; i++)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: SwitchListTile(
              value: _filters[i],
              activeColor: Colors.greenAccent,
              title: Text(
                _filterDefs[i]['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _filterDefs[i]['sub']!,
                  style: const TextStyle(fontSize: 12.5, color: Colors.white70),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _filters[i] = val;
                  _presetNote = 'Ручная проверка тикера «${_customTickerCtrl.text}»: пройдено $passed из 5 фильтров безопасности.';
                });
              },
            ),
          ),
      ],
    );
  }
}
