import 'dart:math';
import 'package:flutter/material.dart';

class CalculatorsScreen extends StatefulWidget {
  const CalculatorsScreen({super.key});

  @override
  State<CalculatorsScreen> createState() => _CalculatorsScreenState();
}

class _CalculatorsScreenState extends State<CalculatorsScreen> {
  int _selectedCalc = 0;

  // 1. Параметры ОФЗ
  double _ofzPricePercent = 54.0;
  double _ofzCouponRub = 71.0;
  double _ofzYears = 12.0;
  double _ofzDuration = 7.2;
  double _cbRateDrop = 4.0;

  // 2. Параметры ИИС-3
  double _iisContribution = 400000.0;
  int _ndflRate = 13;
  double _iisYears = 5.0;
  double _iisYield = 16.0;

  // 3. Параметры Сложного процента
  double _compInitial = 100000.0;
  double _compMonthly = 15000.0;
  double _compRate = 17.0;
  double _compYears = 10.0;

  String _fmt(double val) {
    final int v = val.round();
    final String s = v.toString();
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buf.write(' ');
      }
      buf.write(s[i]);
    }
    return '${buf.toString()} ₽';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        const Text(
          'Инвест-Калькуляторы ПРО',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Двигай ползунки, чтобы мгновенно рассчитать доходность длинных ОФЗ на снижении ставки ЦБ, возврат НДФЛ по ИИС-3 и рост капитала.',
          style: TextStyle(color: Colors.white70, fontSize: 13.5),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('1. Доходность ОФЗ'),
              selected: _selectedCalc == 0,
              onSelected: (_) => setState(() => _selectedCalc = 0),
            ),
            ChoiceChip(
              label: const Text('2. Вычет ИИС-3'),
              selected: _selectedCalc == 1,
              onSelected: (_) => setState(() => _selectedCalc = 1),
            ),
            ChoiceChip(
              label: const Text('3. Сложный процент'),
              selected: _selectedCalc == 2,
              onSelected: (_) => setState(() => _selectedCalc = 2),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_selectedCalc == 0) _buildOfzCalculator(),
        if (_selectedCalc == 1) _buildIisCalculator(),
        if (_selectedCalc == 2) _buildCompoundCalculator(),
      ],
    );
  }

  Widget _buildOfzCalculator() {
    final double buyPriceRub = _ofzPricePercent * 10.0;
    final double currentCouponYield = (_ofzCouponRub / buyPriceRub) * 100.0;
    final double bodyUpsidePercent = _ofzDuration * _cbRateDrop;
    final double bodyProfitRub = buyPriceRub * (bodyUpsidePercent / 100.0);
    final double firstYearTotalRub = _ofzCouponRub + bodyProfitRub;
    final double firstYearTotalPercent = (firstYearTotalRub / buyPriceRub) * 100.0;
    final double totalToMaturityRub = (1000.0 - buyPriceRub) + (_ofzCouponRub * _ofzYears);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: const Color(0xFF00E676).withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF00E676), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Результат по 1 облигации (номинал 1000 ₽):',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E676)),
                ),
                const SizedBox(height: 8),
                Text('• Цена покупки в стакане: ${_fmt(buyPriceRub)} (${_ofzPricePercent.toStringAsFixed(0)}%)'),
                Text('• Текущая купонная доходность: ${currentCouponYield.toStringAsFixed(1)}% годовых'),
                Text(
                  '• Рост тела при снижении ставки на ${_cbRateDrop.toStringAsFixed(1)}%: +${bodyUpsidePercent.toStringAsFixed(1)}% (+${_fmt(bodyProfitRub)})',
                ),
                const Divider(height: 18),
                Text(
                  'Итого за год разворота ставки (купон + рост цены): +${firstYearTotalPercent.toStringAsFixed(1)}% (+${_fmt(firstYearTotalRub)})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: Colors.amberAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Общая прибыль при удержании до погашения (${_ofzYears.toStringAsFixed(0)} лет): +${_fmt(totalToMaturityRub)} на 1 бумагу',
                  style: const TextStyle(fontSize: 12.5, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _sliderCard(
          title: 'Рыночная цена ОФЗ (% от номинала 1000 ₽)',
          valueLabel: '${_ofzPricePercent.toStringAsFixed(0)}% (${_fmt(buyPriceRub)})',
          value: _ofzPricePercent,
          min: 45,
          max: 105,
          onChanged: (v) => setState(() => _ofzPricePercent = v),
        ),
        _sliderCard(
          title: 'Годовой купон в рублях (например, у 26238 — 71 ₽)',
          valueLabel: '${_ofzCouponRub.toStringAsFixed(0)} ₽/год',
          value: _ofzCouponRub,
          min: 50,
          max: 150,
          onChanged: (v) => setState(() => _ofzCouponRub = v),
        ),
        _sliderCard(
          title: 'Дюрация облигации (чувствительность к ставке)',
          valueLabel: '${_ofzDuration.toStringAsFixed(1)} года',
          value: _ofzDuration,
          min: 1.0,
          max: 9.0,
          onChanged: (v) => setState(() => _ofzDuration = v),
        ),
        _sliderCard(
          title: 'Ожидаемое снижение ставки ЦБ / доходности за год',
          valueLabel: '-${_cbRateDrop.toStringAsFixed(1)}%',
          value: _cbRateDrop,
          min: 0.0,
          max: 10.0,
          onChanged: (v) => setState(() => _cbRateDrop = v),
        ),
        _sliderCard(
          title: 'Лет до погашения выпуска',
          valueLabel: '${_ofzYears.toStringAsFixed(0)} лет',
          value: _ofzYears,
          min: 1,
          max: 20,
          onChanged: (v) => setState(() => _ofzYears = v),
        ),
      ],
    );
  }

  Widget _buildIisCalculator() {
    final double deductibleBase = min(_iisContribution, 400000.0);
    final double annualTaxRefund = deductibleBase * (_ndflRate / 100.0);
    final double totalTaxRefunds = annualTaxRefund * _iisYears;

    double portfolioValue = 0;
    for (int y = 0; y < _iisYears.round(); y++) {
      portfolioValue = (portfolioValue + _iisContribution + annualTaxRefund) * (1 + _iisYield / 100.0);
    }
    final double totalOwnMoney = _iisContribution * _iisYears.round();
    final double netProfit = portfolioValue - totalOwnMoney;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.amberAccent.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.amberAccent, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Расчет выгоды ИИС-3 (налоговый вычет + освобождение прибыли):',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amberAccent),
                ),
                const SizedBox(height: 8),
                Text('• Возврат НДФЛ от государства за 1 год: +${_fmt(annualTaxRefund)}'),
                Text('• Всего возвратов НДФЛ за ${_iisYears.toStringAsFixed(0)} лет: +${_fmt(totalTaxRefunds)}'),
                Text('• Вложено своих денег: ${_fmt(totalOwnMoney)}'),
                const Divider(height: 18),
                Text(
                  'Итоговый капитал на ИИС-3 (с реинвестированием вычетов): ${_fmt(portfolioValue)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                    color: Color(0xFF00E676),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Чистая прибыль + вычеты: +${_fmt(netProfit)} (налог на доход при закрытии ИИС-3 до 30 млн ₽ = 0 ₽)',
                  style: const TextStyle(fontSize: 12.5, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Выбери свою ставку НДФЛ (прогрессивная шкала 2025–2026):',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [13, 15, 18, 20, 22].map((rate) {
            return ChoiceChip(
              label: Text('$rate%'),
              selected: _ndflRate == rate,
              onSelected: (_) => setState(() => _ndflRate = rate),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _sliderCard(
          title: 'Ежегодный взнос на ИИС-3 (лимит вычета — с 400 000 ₽)',
          valueLabel: _fmt(_iisContribution),
          value: _iisContribution,
          min: 50000,
          max: 1000000,
          onChanged: (v) => setState(() => _iisContribution = (v / 10000).round() * 10000.0),
        ),
        _sliderCard(
          title: 'Средняя доходность активов на ИИС-3 (% годовых)',
          valueLabel: '${_iisYield.toStringAsFixed(1)}%',
          value: _iisYield,
          min: 8,
          max: 25,
          onChanged: (v) => setState(() => _iisYield = v),
        ),
        _sliderCard(
          title: 'Срок инвестирования на ИИС-3 (лет)',
          valueLabel: '${_iisYears.toStringAsFixed(0)} лет',
          value: _iisYears,
          min: 5,
          max: 20,
          onChanged: (v) => setState(() => _iisYears = v.roundToDouble()),
        ),
      ],
    );
  }

  Widget _buildCompoundCalculator() {
    final int months = (_compYears * 12).round();
    final double monthlyRate = (_compRate / 100.0) / 12.0;

    double total = _compInitial;
    for (int m = 0; m < months; m++) {
      total = total * (1 + monthlyRate) + _compMonthly;
    }

    final double investedOwn = _compInitial + (_compMonthly * months);
    final double compoundProfit = total - investedOwn;
    final double passiveMonthlyIncome = (total * (_compRate / 100.0)) / 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.cyanAccent.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.cyanAccent, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Магия сложного процента:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                ),
                const SizedBox(height: 8),
                Text('• Внесено своих денег: ${_fmt(investedOwn)}'),
                Text('• Начислено сложных процентов: +${_fmt(compoundProfit)}'),
                const Divider(height: 18),
                Text(
                  'Итоговый капитал через ${_compYears.toStringAsFixed(0)} лет: ${_fmt(total)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF00E676),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Пассивная зарплата купонами/дивидендами с этого капитала: ~${_fmt(passiveMonthlyIncome)} в месяц!',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.amberAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _sliderCard(
          title: 'Стартовый капитал',
          valueLabel: _fmt(_compInitial),
          value: _compInitial,
          min: 0,
          max: 2000000,
          onChanged: (v) => setState(() => _compInitial = (v / 10000).round() * 10000.0),
        ),
        _sliderCard(
          title: 'Ежемесячное пополнение портфеля',
          valueLabel: _fmt(_compMonthly),
          value: _compMonthly,
          min: 0,
          max: 150000,
          onChanged: (v) => setState(() => _compMonthly = (v / 1000).round() * 1000.0),
        ),
        _sliderCard(
          title: 'Среднегодовая доходность с реинвестированием',
          valueLabel: '${_compRate.toStringAsFixed(1)}% годовых',
          value: _compRate,
          min: 5,
          max: 30,
          onChanged: (v) => setState(() => _compRate = v),
        ),
        _sliderCard(
          title: 'Горизонт инвестирования (лет)',
          valueLabel: '${_compYears.toStringAsFixed(0)} лет',
          value: _compYears,
          min: 1,
          max: 30,
          onChanged: (v) => setState(() => _compYears = v.roundToDouble()),
        ),
      ],
    );
  }

  Widget _sliderCard({
    required String title,
    required String valueLabel,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  valueLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E676)),
                ),
              ],
            ),
            Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

