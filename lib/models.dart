class Lesson {
  final String level;
  final String title;
  final String simpleText;
  final String formula;
  final String example;
  final String indicator;
  final String risk;

  const Lesson({
    required this.level,
    required this.title,
    required this.simpleText,
    required this.formula,
    required this.example,
    required this.indicator,
    required this.risk,
  });
}

class AssetItem {
  final String id;
  final String ticker;
  final String name;
  final String type;
  final double price;
  final double expectedYieldPct;
  final String formulaExplain;
  final String calcExplain;
  final String indicatorExplain;
  final String riskExplain;

  const AssetItem({
    required this.id,
    required this.ticker,
    required this.name,
    required this.type,
    required this.price,
    required this.expectedYieldPct,
    required this.formulaExplain,
    required this.calcExplain,
    required this.indicatorExplain,
    required this.riskExplain,
  });
}

class NewsOption {
  final String actionText;
  final double balanceBonusPct;
  final String explanation;

  const NewsOption({
    required this.actionText,
    required this.balanceBonusPct,
    required this.explanation,
  });
}

class MarketNews {
  final String title;
  final String category;
  final String description;
  final Map<String, double> typeImpactPct;
  final String portfolioImpactExplain;
  final List<NewsOption> options;

  const MarketNews({
    required this.title,
    required this.category,
    required this.description,
    required this.typeImpactPct,
    required this.portfolioImpactExplain,
    required this.options,
  });
}
