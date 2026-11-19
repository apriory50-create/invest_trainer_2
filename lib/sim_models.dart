enum AssetKind { ofz, bond, stock, etf }

class SimInstrument {
  final String ticker;
  final String name;
  final AssetKind kind;
  final String sector;
  final int lotSize;
  final double nominal;
  final double accruedInterestPerUnit; // НКД на 1 облигацию
  final double annualYieldPct; // Годовой купон или дивдоходность в %
  final double debtToEbitda; // Долговая нагрузка
  double priceRub; // Текущая рыночная цена за 1 шт в рублях

  SimInstrument({
    required this.ticker,
    required this.name,
    required this.kind,
    required this.sector,
    required this.lotSize,
    required this.nominal,
    required this.accruedInterestPerUnit,
    required this.annualYieldPct,
    required this.debtToEbitda,
    required this.priceRub,
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
  double avgCleanPriceRub; // Средняя цена покупки без НКД
  double paidNkdRub; // Суммарно уплаченный НКД

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

class TradeRecord {
  final String side; // КУПЛЯ / ПРОДАЖА
  final String ticker;
  final int units;
  final double totalRub;
  final double feeRub;
  final double nkdRub;
  final double taxRub;
  final String note;

  const TradeRecord({
    required this.side,
    required this.ticker,
    required this.units,
    required this.totalRub,
    required this.feeRub,
    required this.nkdRub,
    required this.taxRub,
    required this.note,
  });
}
