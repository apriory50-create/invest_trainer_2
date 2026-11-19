enum AssetKind { ofz, bond, stock, etf }

class SimInstrument {
  final String ticker;
  final String name;
  final AssetKind kind;
  final String sector;
  final int lotSize;
  final double nominal;
  final double annualCouponOrDivPct; // Годовая ставка купона или дивиденда %
  final double debtToEbitda; // Долговая нагрузка эмитента
  final int maturityMonthsLeft; // Остаток до погашения для облигаций (мес.)
  final double rateSensitivity; // Чувствительность к ставке ЦБ
  double priceRub;
  double accruedInterestPerUnit; // Текущий НКД на 1 бумагу

  SimInstrument({
    required this.ticker,
    required this.name,
    required this.kind,
    required this.sector,
    required this.lotSize,
    required this.nominal,
    required this.annualCouponOrDivPct,
    required this.debtToEbitda,
    required this.maturityMonthsLeft,
    required this.rateSensitivity,
    required this.priceRub,
    required this.accruedInterestPerUnit,
  });

  String get kindLabel {
    switch (kind) {
      case AssetKind.ofz:
        return 'ОФЗ';
      case AssetKind.bond:
        return 'Корп. облигация';
      case AssetKind.stock:
        return 'Акция';
      case AssetKind.etf:
        return 'БПИФ';
    }
  }
}

class HoldingPosition {
  final SimInstrument instrument;
  int units;
  double avgCleanPriceRub;
  double paidNkdRub;

  HoldingPosition({
    required this.instrument,
    this.units = 0,
    this.avgCleanPriceRub = 0.0,
    this.paidNkdRub = 0.0,
  });

  double get marketValue => units * instrument.priceRub;
  double get costBasis => units * avgCleanPriceRub;
  double get unrealizedPnl => marketValue - costBasis;
  double get unrealizedPnlPct =>
      costBasis > 0 ? ((marketValue - costBasis) / costBasis) * 100 : 0.0;
}

class SimScenario {
  final String id;
  final String title;
  final String category;
  final String description;
  final String indirectClues;
  final String whyMarketReacts;
  final String whatToDo;
  final Map<AssetKind, double> priceShiftPct;
  final double keyRateDeltaPct;

  const SimScenario({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.indirectClues,
    required this.whyMarketReacts,
    required this.whatToDo,
    required this.priceShiftPct,
    required this.keyRateDeltaPct,
  });
}

class CoachComment {
  final String tag; // ПРАВИЛЬНО | ОШИБКА | ВНИМАНИЕ | ВРЕМЯ | СЦЕНАРИЙ
  final String headline;
  final List<String> details;
  final String whySoNotOtherwise;
  final String advice;
  final List<String> watchNext;

  const CoachComment({
    required this.tag,
    required this.headline,
    required this.details,
    required this.whySoNotOtherwise,
    required this.advice,
    required this.watchNext,
  });
}

