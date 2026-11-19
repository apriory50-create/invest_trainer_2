class Lesson {
  final int id;
  final String module;
  final String title;
  final String theory;
  final String terms;
  final String entrySignals;
  final String exitSignals;
  final String strategy;
  final String indirectSigns;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const Lesson({
    required this.id,
    required this.module,
    required this.title,
    required this.theory,
    required this.terms,
    required this.entrySignals,
    required this.exitSignals,
    required this.strategy,
    required this.indirectSigns,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  String get fullContent =>
      '📘 ПОДРОБНЫЙ РАЗБОР:\n$theory\n\n'
      '📖 СЛОВАРЬ ТЕРМИНОВ (ПРОСТЫМ ЯЗЫКОМ):\n$terms\n\n'
      '🟢 КОГДА ВХОДИТЬ (ПОКУПАТЬ):\n$entrySignals\n\n'
      '🔴 КОГДА ВЫХОДИТЬ (ПРОДАВАТЬ):\n$exitSignals\n\n'
      '♟ КАКУЮ СТРАТЕГИЮ ПРИМЕНЯТЬ:\n$strategy\n\n'
      '🕵️ КОСВЕННЫЕ ПРИЗНАКИ И СКРЫТЫЕ СИГНАЛЫ:\n$indirectSigns';
}

class MarketScenario {
  final int id;
  final String title;
  final String ticker;
  final String description;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final double priceChangePercent;

  const MarketScenario({
    required this.id,
    required this.title,
    required this.ticker,
    required this.description,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.priceChangePercent,
  });
}

class StockAsset {
  final String ticker;
  final String name;
  final String type;
  final double price;
  final double dividendYield;

  const StockAsset({
    required this.ticker,
    required this.name,
    required this.type,
    required this.price,
    required this.dividendYield,
  });
}

class AssetPosition {
  final String ticker;
  final String name;
  final String type;
  int lots;
  double averagePrice;
  double currentPrice;

  AssetPosition({
    required this.ticker,
    required this.name,
    required this.type,
    required this.lots,
    required this.averagePrice,
    required this.currentPrice,
  });

  double get totalValue => lots * currentPrice;
  double get profit => lots * (currentPrice - averagePrice);
  double get profitPercent =>
      averagePrice > 0 ? ((currentPrice - averagePrice) / averagePrice) * 100 : 0;
}


