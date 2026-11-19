import 'dart:math';
import 'package:flutter/material.dart';

class CalculatorsScreen extends StatefulWidget {
  const CalculatorsScreen({super.key});

  @override
  State<CalculatorsScreen> createState() => _CalculatorsScreenState();
}

class _CalculatorsScreenState extends State<CalculatorsScreen> {
  int _calcIndex = 0;

  double _startCapital = 100000;
  double _monthlyAdd = 15000;
  double _ratePercent = 14;
  int _years = 10;

  double _entryPrice = 1000;
  double _stopPrice = 950;
  double _targetPrice = 1150;
  double _riskRub = 5000;

  double _currentPrice = 1000;
  double _newPrice = 850;
  double _currentShares = 10;
  double _extraBudget = 20000;

  String _fmt(double v) => v.round().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]} ',
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Калькуляторы')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Сложный %')),
              ButtonSegment(value: 1, label: Text('Риск/Прибыль')),
              ButtonSegment(value: 2, label: Text('Усреднение')),
            ],
            selected: {_calcIndex},
            onSelectionChanged: (s) => setState(() => _calcIndex = s.first),
          ),
          const SizedBox(height: 16),
          if (_calcIndex == 0) _buildCompoundCalc(),
          if (_calcIndex == 1) _buildRiskCalc(),
          if (_calcIndex == 2) _buildAverageCalc(),
        ],
      ),
    );
  }

  Widget _sliderRow(
    String label,
    double val,
    double min,
    double max,
    int divs,
    String text,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: val.clamp(min, max),
          min: min,
          max: max,
          divisions: divs,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCompoundCalc() {
    final r = _ratePercent / 100 / 12;
    final months = _years * 12;
    double total = _startCapital;
    for (int i = 0; i < months; i++) {
      total = total * (1 + r) + _monthlyAdd;
    }
    final invested = _startCapital + _monthlyAdd * months;
    final profit = total - invested;

    return Column(
      children: [
        _sliderRow('Стартовый капитал', _startCapital, 0, 2000000, 40,
            '${_fmt(_startCapital)} ₽', (v) => setState(() => _startCapital = v)),
        _sliderRow('Пополнение в месяц', _monthlyAdd, 0, 200000, 40,
            '${_fmt(_monthlyAdd)} ₽', (v) => setState(() => _monthlyAdd = v)),
        _sliderRow('Доходность в год', _ratePercent, 1, 35, 34,
            '${_ratePercent.toStringAsFixed(0)}%',
            (v) => setState(() => _ratePercent = v)),
        _sliderRow('Срок (лет)', _years.toDouble(), 1, 30, 29, '$_years лет',
            (v) => setState(() => _years = v.round())),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161B26),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Итоговый капитал: ${_fmt(total)} ₽',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Вложено своих: ${_fmt(invested)} ₽'),
              Text('Доход от процентов: +${_fmt(profit)} ₽',
                  style: const TextStyle(color: Colors.greenAccent)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF00E676).withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Подсказка: регулярное пополнение и время дают главный эффект сложного процента.',
          ),
        ),
      ],
    );
  }

  Widget _buildRiskCalc() {
    final riskPerShare = max(1.0, (_entryPrice - _stopPrice).abs());
    final shares = max(1, (_riskRub / riskPerShare).floor());
    final rewardPerShare = max(0.0, (_targetPrice - _entryPrice).abs());
    final potentialProfit = shares * rewardPerShare;
    final rr = potentialProfit / max(1.0, shares * riskPerShare);

    return Column(
      children: [
        _sliderRow('Цена входа', _entryPrice, 10, 10000, 99,
            '${_fmt(_entryPrice)} ₽', (v) => setState(() => _entryPrice = v)),
        _sliderRow('Стоп-лосс', _stopPrice, 5, 10000, 99,
            '${_fmt(_stopPrice)} ₽', (v) => setState(() => _stopPrice = v)),
        _sliderRow('Цель (тейк-профит)', _targetPrice, 10, 15000, 149,
            '${_fmt(_targetPrice)} ₽', (v) => setState(() => _targetPrice = v)),
        _sliderRow('Допустимый риск', _riskRub, 500, 100000, 99,
            '${_fmt(_riskRub)} ₽', (v) => setState(() => _riskRub = v)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161B26),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Размер позиции: $shares шт.',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Потенциальная прибыль: +${_fmt(potentialProfit)} ₽',
                  style: const TextStyle(color: Colors.greenAccent)),
              Text('Соотношение риск/доходность: 1 : ${rr.toStringAsFixed(1)}'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amberAccent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Подсказка: цельтесь минимум в соотношение 1:2 или выше, чтобы покрывать убыточные сделки.',
          ),
        ),
      ],
    );
  }

  Widget _buildAverageCalc() {
    final safeNewPrice = max(1.0, _newPrice);
    final addedShares = (_extraBudget / safeNewPrice).floor();
    final totalShares = max(1.0, _currentShares + addedShares);
    final newAvg =
        (_currentShares * _currentPrice + addedShares * safeNewPrice) /
            totalShares;

    return Column(
      children: [
        _sliderRow('Текущая средняя цена', _currentPrice, 10, 10000, 99,
            '${_fmt(_currentPrice)} ₽', (v) => setState(() => _currentPrice = v)),
        _sliderRow('Текущее кол-во бумаг', _currentShares, 1, 500, 99,
            '${_currentShares.round()} шт.',
            (v) => setState(() => _currentShares = v)),
        _sliderRow('Цена докупки', _newPrice, 10, 10000, 99,
            '${_fmt(_newPrice)} ₽', (v) => setState(() => _newPrice = v)),
        _sliderRow('Сумма докупки', _extraBudget, 0, 500000, 100,
            '${_fmt(_extraBudget)} ₽', (v) => setState(() => _extraBudget = v)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161B26),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Новая средняя цена: ${_fmt(newAvg)} ₽',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Будет докуплено: $addedShares шт.'),
              Text('Всего бумаг в позиции: ${totalShares.round()} шт.'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.cyanAccent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Подсказка: усредняйте только качественные активы, у которых не сломался бизнес.',
          ),
        ),
      ],
    );
  }
}
