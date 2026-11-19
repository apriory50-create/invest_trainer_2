import 'package:flutter/material.dart';
import 'sim_models.dart';
import 'sim_scenarios.dart';
import 'trade_coach.dart';

class RealInvestorSimScreen extends StatefulWidget {
  const RealInvestorSimScreen({super.key});

  @override
  State<RealInvestorSimScreen> createState() => _RealInvestorSimScreenState();
}

class _RealInvestorSimScreenState extends State<RealInvestorSimScreen> {
  static const double _feeRate = 0.0005; // 0.05% комиссия
  static const double _taxRate = 0.13; // 13% налог

  DateTime _simDate = DateTime(2026, 11, 19);
  double _keyRatePct = 18.0;
  double _cash = 300000.0;
  double _totalIncomeReceived = 0.0;
  double _totalTaxPaid = 0.0;

  int _selectedInstrumentIdx = 0;
  int _lots = 1;
  int _selectedScenarioIdx = 0;
  CoachComment? _comment;

  late final List<SimInstrument> _instruments = [
    SimInstrument(
      ticker: 'SU26238RMFS4',
      name: 'ОФЗ 26238 (длинный госдолг)',
      kind: AssetKind.ofz,
      sector: 'Госдолг',
      lotSize: 1,
      nominal: 1000,
      annualCouponOrDivPct: 12.25,
      debtToEbitda: 0.0,
      maturityMonthsLeft: 168,
      rateSensitivity: 1.8,
      priceRub: 590.0,
      accruedInterestPerUnit: 22.40,
    ),
    SimInstrument(
      ticker: 'SU29014RMFS6',
      name: 'ОФЗ 29014 (флоатер / переменный купон)',
      kind: AssetKind.ofz,
      sector: 'Госдолг',
      lotSize: 1,
      nominal: 1000,
      annualCouponOrDivPct: 17.5,
      debtToEbitda: 0.0,
      maturityMonthsLeft: 48,
      rateSensitivity: 0.2,
      priceRub: 995.0,
      accruedInterestPerUnit: 14.10,
    ),
    SimInstrument(
      ticker: 'RU000A1074V6',
      name: 'Корп. облигация Промышленность-01',
      kind: AssetKind.bond,
      sector: 'Корп. долг',
      lotSize: 1,
      nominal: 1000,
      annualCouponOrDivPct: 19.0,
      debtToEbitda: 1.5,
      maturityMonthsLeft: 24,
      rateSensitivity: 0.9,
      priceRub: 965.0,
      accruedInterestPerUnit: 16.80,
    ),
    SimInstrument(
      ticker: 'SBER',
      name: 'Акция Сбербанк (финансы)',
      kind: AssetKind.stock,
      sector: 'Финансы',
      lotSize: 10,
      nominal: 3.0,
      annualCouponOrDivPct: 11.5,
      debtToEbitda: 0.0,
      maturityMonthsLeft: 0,
      rateSensitivity: 1.0,
      priceRub: 285.0,
      accruedInterestPerUnit: 0.0,
    ),
    SimInstrument(
      ticker: 'LKOH',
      name: 'Акция ЛУКОЙЛ (нефть и газ)',
      kind: AssetKind.stock,
      sector: 'Нефть и газ',
      lotSize: 1,
      nominal: 0.025,
      annualCouponOrDivPct: 12.0,
      debtToEbitda: 0.2,
      maturityMonthsLeft: 0,
      rateSensitivity: 0.7,
      priceRub: 7150.0,
      accruedInterestPerUnit: 0.0,
    ),
    SimInstrument(
      ticker: 'LQDT',
      name: 'БПИФ Денежный рынок (ликвидность)',
      kind: AssetKind.etf,
      sector: 'Ликвидность',
      lotSize: 1,
      nominal: 1.0,
      annualCouponOrDivPct: 17.8,
      debtToEbitda: 0.0,
      maturityMonthsLeft: 0,
      rateSensitivity: -0.4,
      priceRub: 1.54,
      accruedInterestPerUnit: 0.0,
    ),
    SimInstrument(
      ticker: 'GLDRUB_TOM',
      name: 'БПИФ / инструмент на Золото',
      kind: AssetKind.etf,
      sector: 'Золото',
      lotSize: 1,
      nominal: 1.0,
      annualCouponOrDivPct: 0.0,
      debtToEbitda: 0.0,
      maturityMonthsLeft: 0,
      rateSensitivity: -0.3,
      priceRub: 86.0,
      accruedInterestPerUnit: 0.0,
    ),
  ];

  late final Map<String, HoldingPosition> _holdings = {
    for (final i in _instruments) i.ticker: HoldingPosition(instrument: i),
  };

  double get _portfolioTotal =>
      _cash + _holdings.values.fold(0.0, (sum, p) => sum + p.marketValue);

  String get _formattedDate {
    final d = _simDate.day.toString().padLeft(2, '0');
    final m = _simDate.month.toString().padLeft(2, '0');
    return '$d.$m.${_simDate.year}';
  }

  void _notify(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _buy() {
    final inst = _instruments[_selectedInstrumentIdx];
    final pos = _holdings[inst.ticker]!;
    final units = _lots * inst.lotSize;
    if (units <= 0) return;

    final cleanSum = units * inst.priceRub;
    final nkdSum = units * inst.accruedInterestPerUnit;
    final fee = (cleanSum + nkdSum) * _feeRate;
    final totalCost = cleanSum + nkdSum + fee;

    if (totalCost > _cash) {
      _notify('Не хватает средств: нужно ${totalCost.toStringAsFixed(2)} ₽, доступно ${_cash.toStringAsFixed(2)} ₽.');
      return;
    }

    final beforeTotal = _portfolioTotal;
    final afterCash = _cash - totalCost;

    setState(() {
      final nextUnits = pos.units + units;
      pos.avgCleanPriceRub = (pos.costBasis + cleanSum) / nextUnits;
      pos.paidNkdRub += nkdSum;
      pos.units = nextUnits;
      _cash = afterCash;

      _comment = TradeCoach.reviewBuy(
        instrument: inst,
        position: pos,
        units: units,
        totalCost: totalCost,
        nkdSum: nkdSum,
        feeRub: fee,
        cashAfter: afterCash,
        portfolioBefore: beforeTotal,
        currentKeyRatePct: _keyRatePct,
      );
    });
  }

  void _sell() {
    final inst = _instruments[_selectedInstrumentIdx];
    final pos = _holdings[inst.ticker]!;
    final units = _lots * inst.lotSize;

    if (units <= 0 || pos.units < units) {
      _notify('Недостаточно бумаг для продажи (есть ${pos.units} шт.).');
      return;
    }

    final gross = units * inst.priceRub;
    final fee = gross * _feeRate;
    final pnl = (inst.priceRub - pos.avgCleanPriceRub) * units - fee;
    final tax = pnl > 0 ? pnl * _taxRate : 0.0;
    final net = gross - fee - tax;

    setState(() {
      pos.units -= units;
      if (pos.units == 0) {
        pos.avgCleanPriceRub = 0.0;
        pos.paidNkdRub = 0.0;
      }
      _cash += net;
      _totalTaxPaid += tax;

      _comment = TradeCoach.reviewSell(
        instrument: inst,
        position: pos,
        units: units,
        netProceeds: net,
        feeRub: fee,
        taxRub: tax,
        realizedPnl: pnl,
      );
    });
  }

  void _applyScenario() {
    final sc = SimScenarios.items[_selectedScenarioIdx];
    final beforeTotal = _portfolioTotal;

    setState(() {
      _keyRatePct = (_keyRatePct + sc.keyRateDeltaPct).clamp(2.0, 35.0);
      for (final inst in _instruments) {
        final shift = sc.priceShiftPct[inst.kind] ?? 0.0;
        inst.priceRub = double.parse((inst.priceRub * (1 + shift / 100)).toStringAsFixed(2));
      }
      _comment = TradeCoach.reviewScenario(
        scenario: sc,
        newKeyRatePct: _keyRatePct,
        portfolioBefore: beforeTotal,
        portfolioAfter: _portfolioTotal,
      );
    });
  }

  void _advanceTime(int days) {
    double netAdded = 0.0;
    double taxTaken = 0.0;

    setState(() {
      _simDate = _simDate.add(Duration(days: days));

      for (final inst in _instruments) {
        if (inst.kind == AssetKind.ofz || inst.kind == AssetKind.bond) {
          final dailyNkd = (inst.nominal * (inst.annualCouponOrDivPct / 100)) / 365.0;
          inst.accruedInterestPerUnit = double.parse(
            ((inst.accruedInterestPerUnit + dailyNkd * days) % (inst.nominal * 0.12)).toStringAsFixed(2),
          );
        } else if (inst.ticker == 'LQDT') {
          final dailyGrowth = (_keyRatePct / 100) / 365.0;
          inst.priceRub = double.parse(
            (inst.priceRub * (1 + dailyGrowth * days)).toStringAsFixed(4),
          );
        }
      }

      for (final pos in _holdings.values) {
        if (pos.units > 0 && pos.instrument.ticker != 'LQDT' && pos.instrument.annualCouponOrDivPct > 0) {
          final gross = pos.marketValue * (pos.instrument.annualCouponOrDivPct / 100) * (days / 365.0);
          final tax = pos.instrument.kind == AssetKind.ofz ? 0.0 : gross * _taxRate;
          final net = gross - tax;
          _cash += net;
          _totalIncomeReceived += net;
          _totalTaxPaid += tax;
          netAdded += net;
          taxTaken += tax;
        }
      }

      _comment = CoachComment(
        tag: 'ВРЕМЯ',
        headline: 'Продвижение вперед на $days дн. → $_formattedDate',
        details: [
          'Начислено купонов/дивидендов (после налогов): +${netAdded.toStringAsFixed(2)} ₽.',
          'Удержано налога с выплат: ${taxTaken.toStringAsFixed(2)} ₽.',
          'Текущий капитал портфеля: ${_portfolioTotal.toStringAsFixed(2)} ₽.',
        ],
        whySoNotOtherwise: 'Со временем у облигаций копится НКД и приходят выплаты, у акций бывают дивиденды, а у фонда ликвидности растет цена пая.',
        advice: 'Оценивай результат на дистанции и проверяй, не пора ли скорректировать доли бумаг в портфеле.',
        watchNext: [
          'Новый остаток кэша (${_cash.toStringAsFixed(2)} ₽) и выплаченный доход.',
          'Изменения цен бумаг и накопленный НКД.',
        ],
      );
    });
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case 'ПРАВИЛЬНО':
        return Colors.green;
      case 'ОШИБКА':
        return Colors.red;
      case 'ВНИМАНИЕ':
        return Colors.orange;
      case 'СЦЕНАРИЙ':
        return Colors.indigo;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inst = _instruments[_selectedInstrumentIdx];
    final units = _lots * inst.lotSize;
    final estClean = units * inst.priceRub;
    final estNkd = units * inst.accruedInterestPerUnit;
    final estFee = (estClean + estNkd) * _feeRate;
    final estTotal = estClean + estNkd + estFee;
    final scenario = SimScenarios.items[_selectedScenarioIdx];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Дата: $_formattedDate • Ключевая ставка: ${_keyRatePct.toStringAsFixed(1)}%',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text('Капитал: ${_portfolioTotal.toStringAsFixed(2)} ₽',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  'Кэш: ${_cash.toStringAsFixed(2)} ₽ • Выплаты: +${_totalIncomeReceived.toStringAsFixed(2)} ₽ • Налоги: ${_totalTaxPaid.toStringAsFixed(2)} ₽',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('1. Продвижение по времени', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(onPressed: () => _advanceTime(7), child: const Text('+7 дней')),
                    OutlinedButton(onPressed: () => _advanceTime(30), child: const Text('+1 мес.')),
                    OutlinedButton(onPressed: () => _advanceTime(90), child: const Text('+1 квартал')),
                    OutlinedButton(onPressed: () => _advanceTime(365), child: const Text('+1 год')),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('2. Сценарии рынка', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedScenarioIdx,
                  isExpanded: true,
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  items: List.generate(
                    SimScenarios.items.length,
                    (i) => DropdownMenuItem(value: i, child: Text('${SimScenarios.items[i].id}: ${SimScenarios.items[i].title}')),
                  ),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedScenarioIdx = v);
                  },
                ),
                const SizedBox(height: 8),
                Text(scenario.description, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 4),
                Text('Косвенные признаки: ${scenario.indirectClues}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _applyScenario,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Применить сценарий к рынку'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('3. Покупка и продажа всех видов бумаг',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedInstrumentIdx,
                  isExpanded: true,
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  items: List.generate(
                    _instruments.length,
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text('${_instruments[i].ticker} [${_instruments[i].kindLabel}] — ${_instruments[i].priceRub} ₽'),
                    ),
                  ),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedInstrumentIdx = v);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  '${inst.name} • Лот: ${inst.lotSize} шт. • Ставка/див: ~${inst.annualCouponOrDivPct}% • Долг/EBITDA: ${inst.debtToEbitda}',
                  style: const TextStyle(fontSize: 12),
                ),
                Row(
                  children: [
                    const Text('Лотов: '),
                    IconButton(
                      onPressed: () => setState(() => _lots = (_lots - 1).clamp(1, 1000)),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$_lots ($units шт.)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => setState(() => _lots = (_lots + 1).clamp(1, 1000)),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                Text(
                  'Итого при покупке: ${estTotal.toStringAsFixed(2)} ₽ (бумаги ${estClean.toStringAsFixed(2)} ₽ + НКД ${estNkd.toStringAsFixed(2)} ₽ + ком. ${estFee.toStringAsFixed(2)} ₽)',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: FilledButton(onPressed: _buy, child: const Text('Купить'))),
                    const SizedBox(width: 10),
                    Expanded(child: OutlinedButton(onPressed: _sell, child: const Text('Продать'))),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_comment != null) ...[
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: _tagColor(_comment!.tag), width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(_comment!.tag, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        backgroundColor: _tagColor(_comment!.tag),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_comment!.headline, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._comment!.details.map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $d', style: const TextStyle(fontSize: 13)),
                      )),
                  const Divider(),
                  Text('Почему так, а не иначе: ${_comment!.whySoNotOtherwise}', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('Рекомендация: ${_comment!.advice}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text('На что обратить внимание дальше:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ..._comment!.watchNext.map((w) => Text('— $w', style: const TextStyle(fontSize: 12))),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('4. Состав портфеля', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                ..._holdings.values.where((p) => p.units > 0).map((p) {
                  final pnl = p.unrealizedPnl;
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('${p.instrument.ticker} — ${p.units} шт. (${p.marketValue.toStringAsFixed(0)} ₽)'),
                    subtitle: Text(
                      'Ср. цена: ${p.avgCleanPriceRub.toStringAsFixed(2)} ₽ • НКД: ${p.paidNkdRub.toStringAsFixed(2)} ₽',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Text(
                      '${pnl >= 0 ? '+' : ''}${pnl.toStringAsFixed(1)} ₽',
                      style: TextStyle(
                        color: pnl >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
                if (_holdings.values.every((p) => p.units == 0))
                  const Text('Портфель пока пуст — выбери бумагу в блоке 3 и нажми «Купить».'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


