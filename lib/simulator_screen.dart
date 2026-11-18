import 'dart:math';
import 'package:flutter/material.dart';
import 'models.dart';
import 'market_data.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  double _initialCapital = 100000.0;
  double _cash = 100000.0;
  final Map<String, int> _holdings = {};
  final Map<String, double> _currentPrices = {
    for (var a in marketAssets) a.id: a.price,
  };

  AssetItem? _selectedAssetForExplain;
  MarketNews? _activeNews;
  NewsOption? _chosenNewsOption;
  double _lastNewsPortfolioDeltaRub = 0.0;
  final List<String> _lastNewsAssetBreakdown = [];

  double get _portfolioAssetsValue {
    double total = 0;
    _holdings.forEach((id, qty) {
      total += (_currentPrices[id] ?? 0) * qty;
    });
    return total;
  }

  double get _expectedAnnualIncomeRub {
    double income = 0;
    for (var asset in marketAssets) {
      final qty = _holdings[asset.id] ?? 0;
      if (qty > 0) {
        final posValue = (_currentPrices[asset.id] ?? asset.price) * qty;
        income += posValue * (asset.expectedYieldPct / 100.0);
      }
    }
    return income;
  }

  void _buyAsset(AssetItem asset) {
    final price = _currentPrices[asset.id] ?? asset.price;
    if (_cash < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Недостаточно свободных денег! Продайте часть активов или пополните счет.')),
      );
      return;
    }
    setState(() {
      _cash -= price;
      _holdings[asset.id] = (_holdings[asset.id] ?? 0) + 1;
      _selectedAssetForExplain = asset;
    });
  }

  void _sellAsset(AssetItem asset) {
    final currentQty = _holdings[asset.id] ?? 0;
    if (currentQty <= 0) return;
    final price = _currentPrices[asset.id] ?? asset.price;
    setState(() {
      _cash += price;
      if (currentQty == 1) {
        _holdings.remove(asset.id);
      } else {
        _holdings[asset.id] = currentQty - 1;
      }
      _selectedAssetForExplain = asset;
    });
  }

  void _triggerRandomNews() {
    if (_holdings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Портфель пуст! Сначала купите хотя бы одну ценную бумагу ниже.')),
      );
      return;
    }
    final rnd = Random();
    final news = marketNewsList[rnd.nextInt(marketNewsList.length)];
    double totalDelta = 0.0;
    final List<String> breakdown = [];

    setState(() {
      for (var asset in marketAssets) {
        final qty = _holdings[asset.id] ?? 0;
        final impactPct = news.typeImpactPct[asset.type] ?? 0.0;
        final oldPrice = _currentPrices[asset.id] ?? asset.price;
        final newPrice = (oldPrice * (1.0 + impactPct / 100.0)).clamp(10.0, 500000.0);
        if (qty > 0) {
          final deltaRub = (newPrice - oldPrice) * qty;
          totalDelta += deltaRub;
          final sign = deltaRub >= 0 ? '+' : '';
          breakdown.add('${asset.ticker} ($qty шт.): $sign${deltaRub.toStringAsFixed(0)} ₽ ($sign$impactPct%)');
        }
        _currentPrices[asset.id] = newPrice;
      }
      _activeNews = news;
      _chosenNewsOption = null;
      _lastNewsPortfolioDeltaRub = totalDelta;
      _lastNewsAssetBreakdown
        ..clear()
        ..addAll(breakdown);
    });
  }

  void _applyNewsAction(NewsOption option) {
    if (_chosenNewsOption != null) return;
    final baseValue = _portfolioAssetsValue + _cash;
    final bonusRub = baseValue * (option.balanceBonusPct / 100.0);
    setState(() {
      _chosenNewsOption = option;
      _cash = (_cash + bonusRub).clamp(0.0, 100000000.0);
    });
  }

  void _resetSimulator(double newCapital) {
    setState(() {
      _initialCapital = newCapital;
      _cash = newCapital;
      _holdings.clear();
      for (var a in marketAssets) {
        _currentPrices[a.id] = a.price;
      }
      _selectedAssetForExplain = null;
      _activeNews = null;
      _chosenNewsOption = null;
      _lastNewsPortfolioDeltaRub = 0.0;
      _lastNewsAssetBreakdown.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalCapital = _cash + _portfolioAssetsValue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Симулятор: Портфель и Новости'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<double>(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: 'Выбрать стартовый капитал (сброс)',
            onSelected: _resetSimulator,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 50000, child: Text('Начать с 50 000 ₽')),
              PopupMenuItem(value: 100000, child: Text('Начать со 100 000 ₽')),
              PopupMenuItem(value: 500000, child: Text('Начать с 500 000 ₽')),
              PopupMenuItem(value: 1000000, child: Text('Начать с 1 000 000 ₽')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _buildPortfolioHeader(totalCapital),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _triggerRandomNews,
              icon: const Icon(Icons.bolt),
              label: const Text(
                'СГЕНЕРИРОВАТЬ СЛУЧАЙНУЮ НОВОСТЬ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (_activeNews != null) ...[
            const SizedBox(height: 14),
            _buildNewsImpactCard(_activeNews!),
          ],
          if (_selectedAssetForExplain != null) ...[
            const SizedBox(height: 14),
            _buildCalculationExplainCard(_selectedAssetForExplain!),
          ],
          const SizedBox(height: 16),
          const Text(
            'Все виды ценных бумаг (нажми + чтобы купить и увидеть формулу расчета дохода):',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...marketAssets.map(_buildAssetRow),
        ],
      ),
    );
  }

  Widget _buildPortfolioHeader(double totalCapital) {
    final profit = totalCapital - _initialCapital;
    final profitPct = _initialCapital > 0 ? (profit / _initialCapital) * 100 : 0.0;
    final monthlyIncome = _expectedAnnualIncomeRub / 12.0;

    return Container(
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
            'Капитал: ${totalCapital.toStringAsFixed(0)} ₽ (${profit >= 0 ? '+' : ''}${profit.toStringAsFixed(0)} ₽ / ${profit >= 0 ? '+' : ''}${profitPct.toStringAsFixed(1)}%)',
            style: TextStyle(
              color: profit >= 0 ? Colors.greenAccent : Colors.redAccent,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Свободные деньги: ${_cash.toStringAsFixed(0)} ₽ | В бумагах: ${_portfolioAssetsValue.toStringAsFixed(0)} ₽',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            'Расчетный пассивный доход: +${_expectedAnnualIncomeRub.toStringAsFixed(0)} ₽/год (~${monthlyIncome.toStringAsFixed(0)} ₽/мес)',
            style: const TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationExplainCard(AssetItem asset) {
    final qty = _holdings[asset.id] ?? 0;
    final price = _currentPrices[asset.id] ?? asset.price;
    final posSum = price * qty;
    final yearlyRub = posSum * (asset.expectedYieldPct / 100.0);
    final monthlyRub = yearlyRub / 12.0;
    final ndfl13 = yearlyRub * 0.13;
    final netYearlyRub = yearlyRub - ndfl13;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amberAccent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'РАСЧЕТ И ФОРМУЛА ПО БУМАГЕ: ${asset.ticker} (${asset.type})',
            style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            'В портфеле: $qty шт. × ${price.toStringAsFixed(0)} ₽ = ${posSum.toStringAsFixed(0)} ₽\n'
            'Доход до налога (${asset.expectedYieldPct}%): +${yearlyRub.toStringAsFixed(0)} ₽/год (+${monthlyRub.toStringAsFixed(0)} ₽/мес)\n'
            'Чистыми после НДФЛ 13%: +${netYearlyRub.toStringAsFixed(0)} ₽/год (налог ${ndfl13.toStringAsFixed(0)} ₽ или 0 ₽ на ИИС-3)',
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
          const Divider(color: Colors.white24, height: 16),
          Text('Формула: ${asset.formulaExplain}', style: const TextStyle(color: Colors.tealAccent, fontSize: 13)),
          const SizedBox(height: 6),
          Text('Пояснение расчета: ${asset.calcExplain}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text('Показатель: ${asset.indicatorExplain}', style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 13)),
          const SizedBox(height: 6),
          Text('Риски: ${asset.riskExplain}', style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildNewsImpactCard(MarketNews news) {
    final isPositive = _lastNewsPortfolioDeltaRub >= 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF271722),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.deepOrangeAccent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'НОВОСТЬ НА РЫНКЕ (${news.category}):',
            style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(news.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(news.description, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            'Итого влияние на ваш портфель: ${isPositive ? '+' : ''}${_lastNewsPortfolioDeltaRub.toStringAsFixed(0)} ₽',
            style: TextStyle(
              color: isPositive ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          if (_lastNewsAssetBreakdown.isNotEmpty) ...[
            const SizedBox(height: 6),
            ..._lastNewsAssetBreakdown.map(
              (line) => Text('• $line', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Почему так произошло: ${news.portfolioImpactExplain}',
            style: const TextStyle(color: Colors.amberAccent, fontSize: 13),
          ),
          const Divider(color: Colors.white24, height: 18),
          const Text(
            'Выберите ваше действие:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...news.options.map((opt) {
            final isSelected = _chosenNewsOption == opt;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isSelected ? Colors.greenAccent : Colors.white38),
                  backgroundColor: isSelected ? Colors.white10 : Colors.transparent,
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: _chosenNewsOption == null ? () => _applyNewsAction(opt) : null,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(opt.actionText, style: const TextStyle(color: Colors.white, fontSize: 13)),
                ),
              ),
            );
          }),
          if (_chosenNewsOption != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _chosenNewsOption!.balanceBonusPct >= 0 ? Colors.greenAccent : Colors.redAccent,
                ),
              ),
              child: Text(
                'Пояснение по вашему действию (эффект ${_chosenNewsOption!.balanceBonusPct >= 0 ? '+' : ''}${_chosenNewsOption!.balanceBonusPct}% к портфелю):\n${_chosenNewsOption!.explanation}',
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssetRow(AssetItem asset) {
    final qty = _holdings[asset.id] ?? 0;
    final price = _currentPrices[asset.id] ?? asset.price;
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedAssetForExplain = asset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${asset.ticker} • ${asset.type}',
                      style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(asset.name, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      'Цена: ${price.toStringAsFixed(0)} ₽ | Ожид. доход: ~${asset.expectedYieldPct}% | В портфеле: $qty шт.',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: qty > 0 ? () => _sellAsset(asset) : null,
              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
            ),
            IconButton(
              onPressed: () => _buyAsset(asset),
              icon: const Icon(Icons.add_circle, color: Colors.greenAccent),
            ),
          ],
        ),
      ),
    );
  }
}
