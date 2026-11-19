import 'package:flutter/material.dart';
import 'sim_models.dart';

class RealInvestorSimScreen extends StatefulWidget {
  const RealInvestorSimScreen({super.key});

  @override
  State<RealInvestorSimScreen> createState() => _RealInvestorSimScreenState();
}

class _RealInvestorSimScreenState extends State<RealInvestorSimScreen> {
  static const double _commissionRate = 0.0005; // 0.05% комиссия брокера
  static const double _taxRate = 0.13; // 13% НДФЛ с прибыли и купонов

  double _cash = 250000.0;
  double _realizedTaxPaid = 0.0;
  double _couponsReceived = 0.0;
  int _selectedIdx = 0;
  int _lotsToTrade = 1;
  bool _enforceFilters = true;
  final List<bool> _filtersPassed = [true, true, false, true, false];
  final List<TradeRecord> _history = [];

  late final List<SimInstrument> _market = [
    SimInstrument(
      ticker: 'SU26238RMFS4',
      name: 'ОФЗ 26238 (длинный госдолг)',
      kind: AssetKind.ofz,
      sector: 'Госдолг',
      lotSize: 1,
      nominal: 1000,
      accruedInterestPerUnit: 24.50,
      annualYieldPct: 12.8,
      debtToEbitda: 0.0,
      priceRub: 595.0,
    ),
    SimInstrument(
      ticker: 'RU000A1074V6',
      name: 'Борец Капитал 001P-01',
      kind: AssetKind.bond,
      sector: 'Нефтесервис',
      lotSize: 1,
      nominal: 1000,
      accruedInterestPerUnit: 18.20,
      annualYieldPct: 19.5,
      debtToEbitda: 1.4,
      priceRub: 960.0,
    ),
    SimInstrument(
      ticker: 'SBER',
      name: 'Сбербанк (обыкновенные)',
      kind: AssetKind.stock,
      sector: 'Финансы',
      lotSize: 10,
      nominal: 3,
      accruedInterestPerUnit: 0.0,
      annualYieldPct: 11.5,
      debtToEbitda: 0.0,
      priceRub: 285.0,
    ),
    SimInstrument(
      ticker: 'LQDT',
      name: 'ВИМ Ликвидность (денежный рынок)',
      kind: AssetKind.etf,
      sector: 'Ликвидность',
      lotSize: 1,
      nominal: 1.0,
      accruedInterestPerUnit: 0.0,
      annualYieldPct: 17.8,
      debtToEbitda: 0.0,
      priceRub: 1.54,
    ),
  ];

  late final Map<String, HoldingPosition> _portfolio = {
    for (final item in _market) item.ticker: HoldingPosition(instrument: item),
  };

  static const List<String> _filterTexts = [
    '1. Ставка ЦБ и макрофон не бьют по бумаге',
    '2. Долговая нагрузка и отчетность в норме',
    '3. Цена не на пике резкого импульса',
    '4. Размер позиции не перегружает портфель',
    '5. Заранее задан план выхода и стоп-уровень',
  ];

  int get _passedCount => _filtersPassed.where((e) => e).length;

  double get _portfolioMarketTotal =>
      _cash + _portfolio.values.fold(0.0, (s, p) => s + p.marketValue);

  void _showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _buySelected() {
    final inst = _market[_selectedIdx];
    final pos = _portfolio[inst.ticker]!;
    final units = _lotsToTrade * inst.lotSize;

    if (units <= 0) return;

    if (_enforceFilters && _passedCount < 4) {
      _showMsg('Пройдено фильтров: $_passedCount/5. Отметь минимум 4 или сними строгий режим.');
      return;
    }

    final cleanSum = units * inst.priceRub;
    final nkdSum = units * inst.accruedInterestPerUnit;
    final fee = (cleanSum + nkdSum) * _commissionRate;
    final totalCost = cleanSum + nkdSum + fee;

    if (totalCost > _cash) {
      _showMsg('Не хватает кэша: нужно ${totalCost.toStringAsFixed(2)} ₽, доступно ${_cash.toStringAsFixed(2)} ₽.');
      return;
    }

    setState(() {
      final newUnits = pos.units + units;
      final newCleanBasis = pos.costBasis + cleanSum;
      pos.avgCleanPriceRub = newCleanBasis / newUnits;
      pos.paidNkdRub += nkdSum;
      pos.units = newUnits;
      _cash -= totalCost;
      _history.insert(
        0,
        TradeRecord(
          side: 'КУПЛЯ',
          ticker: inst.ticker,
          units: units,
          totalRub: totalCost,
          feeRub: fee,
          nkdRub: nkdSum,
          taxRub: 0.0,
          note: 'Списано с учетом НКД и комиссии 0.05%',
        ),
      );
    });
    _showMsg('Куплено $units шт. ${inst.ticker} за ${totalCost.toStringAsFixed(2)} ₽');
  }

  void _sellSelected() {
    final inst = _market[_selectedIdx];
    final pos = _portfolio[inst.ticker]!;
    final units = _lotsToTrade * inst.lotSize;

    if (units <= 0 || pos.units < units) {
      _showMsg('Недостаточно бумаг для продажи (в портфеле: ${pos.units} шт.).');
      return;
    }

    final grossProceeds = units * inst.priceRub;
    final fee = grossProceeds * _commissionRate;
    final profit = (inst.priceRub - pos.avgCleanPriceRub) * units - fee;
    final tax = profit > 0 ? profit * _taxRate : 0.0;
    final netProceeds = grossProceeds - fee - tax;

    setState(() {
      pos.units -= units;
      if (pos.units == 0) {
        pos.avgCleanPriceRub = 0.0;
        pos.paidNkdRub = 0.0;
      }
      _cash += netProceeds;
      _realizedTaxPaid += tax;
      _history.insert(
        0,
        TradeRecord(
          side: 'ПРОДАЖА',
          ticker: inst.ticker,
          units: units,
          totalRub: netProceeds,
          feeRub: fee,
          nkdRub: 0.0,
          taxRub: tax,
          note: tax > 0 ? 'Удержан НДФЛ 13% с прибыли' : 'Налог не удержан',
        ),
      );
    });
    _showMsg('Продано $units шт. ${inst.ticker}. На счет зачислено ${netProceeds.toStringAsFixed(2)} ₽');
  }

  void _simulateRateShock(bool rateUp) {
    setState(() {
      for (final inst in _market) {
        double pct = 0.0;
        if (inst.kind == AssetKind.ofz) pct = rateUp ? -4.5 : 5.0;
        if (inst.kind == AssetKind.bond) pct = rateUp ? -1.8 : 2.0;
        if (inst.kind == AssetKind.stock) pct = rateUp ? -2.2 : 2.8;
        if (inst.kind == AssetKind.etf) pct = rateUp ? 0.6 : -0.4;
        inst.priceRub = double.parse((inst.priceRub * (1 + pct / 100)).toStringAsFixed(2));
      }
    });
    _showMsg(rateUp
        ? 'Событие: Ставка ЦБ повышена. Длинные ОФЗ просели, фонд ликвидности подрос.'
        : 'Событие: Ставка ЦБ снижена. Длинные ОФЗ и акции получили импульс роста.');
  }

  void _accrueQuarterCoupon() {
    double netCoupons = 0.0;
    setState(() {
      for (final pos in _portfolio.values) {
        if (pos.units > 0 && pos.instrument.annualYieldPct > 0) {
          final gross = pos.marketValue * (pos.instrument.annualYieldPct / 100) / 4;
          final tax = pos.instrument.kind == AssetKind.ofz ? 0.0 : gross * _taxRate;
          final net = gross - tax;
          _cash += net;
          _couponsReceived += net;
          _realizedTaxPaid += tax;
          netCoupons += net;
        }
      }
    });
    _showMsg('Начислено выплат за квартал (после налогов): +${netCoupons.toStringAsFixed(2)} ₽');
  }

  @override
  Widget build(BuildContext context) {
    final inst = _market[_selectedIdx];
    final pos = _portfolio[inst.ticker]!;
    final units = _lotsToTrade * inst.lotSize;
    final estClean = units * inst.priceRub;
    final estNkd = units * inst.accruedInterestPerUnit;
    final estFee = (estClean + estNkd) * _commissionRate;
    final estTotal = estClean + estNkd + estFee;

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
                const Text('Счет инвестора', style: TextStyle(fontSize: 13)),
                Text('${_portfolioMarketTotal.toStringAsFixed(2)} ₽',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  'Кэш: ${_cash.toStringAsFixed(2)} ₽ • Выплаты: +${_couponsReceived.toStringAsFixed(2)} ₽ • Налоги: ${_realizedTaxPaid.toStringAsFixed(2)} ₽',
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
                const Text('1. Выберите ценную бумагу и объем',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedIdx,
                  isExpanded: true,
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  items: List.generate(_market.length, (i) {
                    final m = _market[i];
                    return DropdownMenuItem(
                      value: i,
                      child: Text('${m.ticker} (${m.kindLabel}) — ${m.priceRub} ₽'),
                    );
                  }),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedIdx = v);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Тип: ${inst.kindLabel} | Лот: ${inst.lotSize} шт. | Доходность: ~${inst.annualYieldPct}% | Долг/EBITDA: ${inst.debtToEbitda}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Лотов: '),
                    IconButton(
                      onPressed: () => setState(() => _lotsToTrade = (_lotsToTrade - 1).clamp(1, 500)),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$_lotsToTrade ($units шт.)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => setState(() => _lotsToTrade = (_lotsToTrade + 1).clamp(1, 500)),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                Text(
                  'К списанию при покупке: ${estTotal.toStringAsFixed(2)} ₽ (бумаги ${estClean.toStringAsFixed(2)} ₽ + НКД ${estNkd.toStringAsFixed(2)} ₽ + ком. ${estFee.toStringAsFixed(2)} ₽)',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _buySelected,
                        child: const Text('Купить'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _sellSelected,
                        child: const Text('Продать'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          child: ExpansionTile(
            title: Text('2. Чек-лист «5 Фильтров Профи» ($_passedCount/5)'),
            subtitle: Text(_enforceFilters ? 'Строгий режим: нужно минимум 4 фильтра' : 'Свободный режим'),
            children: [
              SwitchListTile(
                title: const Text('Блокировать покупку без 4 фильтров'),
                value: _enforceFilters,
                onChanged: (v) => setState(() => _enforceFilters = v),
              ),
              ...List.generate(5, (i) {
                return CheckboxListTile(
                  value: _filtersPassed[i],
                  title: Text(_filterTexts[i], style: const TextStyle(fontSize: 13)),
                  onChanged: (v) => setState(() => _filtersPassed[i] = v ?? false),
                );
              }),
            ],
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('3. Рыночные события и выплаты',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => _simulateRateShock(true),
                      child: const Text('Ставка ЦБ ↑'),
                    ),
                    OutlinedButton(
                      onPressed: () => _simulateRateShock(false),
                      child: const Text('Ставка ЦБ ↓'),
                    ),
                    FilledButton.tonal(
                      onPressed: _accrueQuarterCoupon,
                      child: const Text('Начислить купоны/див.'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('4. Состав портфеля', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                ..._portfolio.values.where((p) => p.units > 0).map((p) {
                  final pnl = p.unrealizedPnl;
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('${p.instrument.ticker} — ${p.units} шт. (${p.marketValue.toStringAsFixed(0)} ₽)'),
                    subtitle: Text(
                      'Ср. цена: ${p.avgCleanPriceRub.toStringAsFixed(2)} ₽ • НКД уплачено: ${p.paidNkdRub.toStringAsFixed(2)} ₽',
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
                if (_portfolio.values.every((p) => p.units == 0))
                  const Text('Портфель пока пуст — выбери бумагу выше и нажми «Купить».'),
              ],
            ),
          ),
        ),
        if (_history.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('5. Журнал сделок', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 6),
                  ..._history.take(8).map((t) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text('${t.side} ${t.ticker} (${t.units} шт.) — ${t.totalRub.toStringAsFixed(2)} ₽'),
                        subtitle: Text(
                          '${t.note} | Ком: ${t.feeRub.toStringAsFixed(2)} ₽${t.taxRub > 0 ? ' | Налог: ${t.taxRub.toStringAsFixed(2)} ₽' : ''}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      )),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
