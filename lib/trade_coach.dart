import 'sim_models.dart';

class TradeAudit {
  final String verdict; // ПРАВИЛЬНО | ОШИБКА | ВНИМАНИЕ
  final String title;
  final List<String> steps; // Пошаговый разбор: что произошло и почему так
  final String whyNotElse; // Почему не так / в чем подвох альтернативы
  final String recommendation; // Конкретная рекомендация что делать дальше
  final List<String> watchList; // На что обратить внимание

  const TradeAudit({
    required this.verdict,
    required this.title,
    required this.steps,
    required this.whyNotElse,
    required this.recommendation,
    required this.watchList,
  });
}

class MistakeCatalogItem {
  final String code;
  final String category;
  final String mistakeName;
  final String whyWrong;
  final String howToFix;
  final String watchSignal;

  const MistakeCatalogItem({
    required this.code,
    required this.category,
    required this.mistakeName,
    required this.whyWrong,
    required this.howToFix,
    required this.watchSignal,
  });
}

class TradeCoach {
  static const List<MistakeCatalogItem> commonMistakes = [
    MistakeCatalogItem(
      code: 'ERR-01',
      category: 'Облигации и ставка',
      mistakeName: 'Покупка длинных ОФЗ на пике ставки или перед ее повышением',
      whyWrong: 'Длинные ОФЗ имеют большую дюрацию: при росте ставки ЦБ их рыночная цена заметно падает, давая бумажный минус по телу.',
      howToFix: 'На фазе ужесточения ставки держи короткие облигации, флоатеры или фонды ликвидности; длинные ОФЗ набирай частями ближе к развороту цикла.',
      watchSignal: 'Смотри на кривую доходности ОФЗ, инфляцию и риторику ЦБ на заседаниях.',
    ),
    MistakeCatalogItem(
      code: 'ERR-02',
      category: 'Облигации и НКД',
      mistakeName: 'Путаница между ценой в % от номинала и реальной суммой списания с учетом НКД',
      whyWrong: 'При покупке облигации сверх цены бумаги списывается накопленный купонный доход (НКД) и комиссия — новичку кажется, что денег списали больше ожидаемого.',
      howToFix: 'Всегда считай полную сумму сделки: (Цена + НКД) * кол-во + комиссия, и сверяй с остатком свободного кэша.',
      watchSignal: 'Следи за датой ближайшего купона и размером НКД в карточке бумаги.',
    ),
    MistakeCatalogItem(
      code: 'ERR-03',
      category: 'Риск-менеджмент',
      mistakeName: 'Вход в одну бумагу на 40–70% всего капитала («всё на одну карту»)',
      whyWrong: 'При плохой новости или просадке сектора весь портфель начинает лихорадить, а эмоции толкают на панические решения.',
      howToFix: 'Ограничивай долю одного эмитента (обычно до 15–20% портфеля) и оставляй подушку ликвидности.',
      watchSignal: 'Проверяй долю позиции в процентах от общего капитала до нажатия «Купить».',
    ),
    MistakeCatalogItem(
      code: 'ERR-04',
      category: 'Фундаментал и долг',
      mistakeName: 'Погоня за высоким купоном/дивидендом у компании с тяжелым долгом',
      whyWrong: 'Высокая доходность часто платит за риск: при дорогом кредитовании компания тратит прибыль на проценты по долгам.',
      howToFix: 'Оценивай долговую нагрузку и способность бизнеса обслуживать долг, а не смотри только на красивую цифру доходности.',
      watchSignal: 'Обращай внимание на рост процентных расходов и рефинансирование долгов.',
    ),
    MistakeCatalogItem(
      code: 'ERR-05',
      category: 'Психология и вход',
      mistakeName: 'Покупка после резкого зеленого импульса («FOMO — страх упустить»)',
      whyWrong: 'Вход на всплеске эмоций часто означает покупку у тех, кто фиксирует прибыль, с высоким риском откатиться назад.',
      howToFix: 'Дождись отката, проверки уровня или срабатывания плана по «5 Фильтрам Профи».',
      watchSignal: 'Сравни текущую цену со средней и задай себе вопрос: зачем я покупаю именно сейчас?',
    ),
    MistakeCatalogItem(
      code: 'ERR-06',
      category: 'Продажа и налоги',
      mistakeName: 'Частая продажа прибыльных активов без учета налога (13%) и комиссии',
      whyWrong: 'При фиксации прибыли удерживается налог и комиссия, а перекладка в другой актив без причины снижает сложный процент.',
      howToFix: 'Продавай по плану: цель достигнута, изменился фундамент, нужен ребаланс или сработал защитный выход.',
      watchSignal: 'Считай чистый результат после комиссии и НДФЛ, а не грязную разницу цен.',
    ),
    MistakeCatalogItem(
      code: 'ERR-07',
      category: 'Убытки и стопы',
      mistakeName: 'Усреднение падающего актива без понимания причины падения',
      whyWrong: 'Если бизнес или сектор ухудшился структурно, доливка на падении лишь увеличивает убыточную позицию.',
      howToFix: 'Сначала ответь: это временный шум рынка или поломка идеи? Без плана выхода не усредняй.',
      watchSignal: 'Сверяйся с новостным фоном и правилом ограничения убытка.',
    ),
    MistakeCatalogItem(
      code: 'ERR-08',
      category: 'Ликвидность',
      mistakeName: 'Остаться без свободного кэша в момент рыночной просадки',
      whyWrong: 'Когда появляются выгодные цены или нужно закрыть кассовый разрыв, свободных денег на счете нет.',
      howToFix: 'Держи резерв в кэше или фонде ликвидности (например, LQDT), чтобы не продавать активы в спешке.',
      watchSignal: 'Следи за долей свободного кэша и ликвидных инструментов в портфеле.',
    ),
  ];

  static TradeAudit auditBuy({
    required SimInstrument instrument,
    required HoldingPosition position,
    required int units,
    required double totalCost,
    required double nkdSum,
    required double feeRub,
    required double cashAfter,
    required double portfolioTotalBefore,
    required int passedFilters,
    required bool lastRateWentUp,
  }) {
    final steps = <String>[];
    final watchList = <String>[];
    String verdict = 'ПРАВИЛЬНО';
    String title = 'Взвешенная покупка ${instrument.ticker} ($units шт.)';
    String whyNotElse = 'Покупка выполнена по расчету с учетом реальных издержек, а не «на глаз».';
    String recommendation = 'Зафиксируй причину входа и заранее определи уровень/условие выхода из позиции.';

    steps.add(
      'Шаг 1. Списание средств: бумаги ${(units * instrument.priceRub).toStringAsFixed(2)} ₽, '
      'НКД ${nkdSum.toStringAsFixed(2)} ₽, комиссия ${feeRub.toStringAsFixed(2)} ₽. Итого: ${totalCost.toStringAsFixed(2)} ₽.',
    );

    final shareAfter = portfolioTotalBefore > 0 ? (totalCost / portfolioTotalBefore) * 100 : 0.0;
    steps.add(
      'Шаг 2. Доля сделки в капитале: ~${shareAfter.toStringAsFixed(1)}% от портфеля. '
      'Остаток свободного кэша после покупки: ${cashAfter.toStringAsFixed(2)} ₽.',
    );

    if (passedFilters < 4) {
      verdict = 'ОШИБКА';
      title = 'Покупка ${instrument.ticker} с нарушением фильтров ($passedFilters/5)';
      steps.add(
        'Шаг 3. Дисциплина: пройдено только $passedFilters из 5 фильтров. Вход без проверки правил повышает шанс случайной сделки.',
      );
      whyNotElse = 'Вместо быстрой покупки в азарте лучше дождаться выполнения хотя бы 4 фильтров и проверить цель.';
      recommendation = 'Не торопись с новыми входами: проверь каждый из 5 фильтров перед следующей сделкой.';
      watchList.add('Проверяй ставку/макрофон, долг/отчет, цену входа, долю в портфеле и план выхода.');
    }

    if (instrument.kind == AssetKind.ofz && lastRateWentUp && verdict != 'ОШИБКА') {
      verdict = 'ВНИМАНИЕ';
      title = 'Покупка длинной ОФЗ после роста ставки ЦБ';
      steps.add(
        'Шаг 3. Специфика облигаций: при росте ставок длинные ОФЗ чувствительны к изменению доходностей и могут колебаться по цене.',
      );
      whyNotElse = 'Фонд ликвидности или короткий долг меньше колеблются по цене при росте ставок, но дают меньше потенциала роста цены при снижении ставки.';
      recommendation = 'Если цель — долгий горизонт и фиксация доходности на годы, держи дисциплину и не пугайся колебаний тела.';
      watchList.add('Следи за заседаниями ЦБ, инфляцией и величиной НКД.');
    }

    if (shareAfter > 25.0) {
      verdict = 'ОШИБКА';
      title = 'Слишком крупная доля одной сделки (${shareAfter.toStringAsFixed(1)}%)';
      steps.add(
        'Шаг 3. Концентрация риска: одна покупка занимает больше четверти портфеля.',
      );
      whyNotElse = 'Дробление входа на части снижает риск зайти всей суммой в неудачный момент.';
      recommendation = 'Уменьшай размер лота и следи, чтобы ни один актив не перетягивал на себя весь риск.';
      watchList.add('Контролируй долю каждого актива в процентах от капитала.');
    } else if (cashAfter < portfolioTotalBefore * 0.10 && verdict == 'ПРАВИЛЬНО') {
      verdict = 'ВНИМАНИЕ';
      title = 'Покупка почти на весь кэш (резерв меньше 10%)';
      steps.add(
        'Шаг 3. Ликвидность: свободных денег осталось мало (${cashAfter.toStringAsFixed(0)} ₽).',
      );
      whyNotElse = 'Полный выход в бумаги лишает маневра при просадках или новых идеях.';
      recommendation = 'Пополняй кэш-резерв или держи часть средств в ликвидном инструменте.';
      watchList.add('Следи за остатком кэша и ликвидности перед следующими покупками.');
    }

    if (instrument.debtToEbitda >= 2.0 && verdict == 'ПРАВИЛЬНО') {
      verdict = 'ВНИМАНИЕ';
      title = 'Покупка бумаги с заметной долговой нагрузкой (${instrument.ticker})';
      steps.add(
        'Шаг 3. Фундаментал: у эмитента повышенный долговой коэффициент (${instrument.debtToEbitda.toStringAsFixed(1)}).',
      );
      whyNotElse = 'Компании с низким долгом легче переносят дорогие кредиты и рыночные штормы.';
      recommendation = 'Не завышай долю такого эмитента в портфеле и следи за процентными расходами.';
      watchList.add('Смотри на отчетность, долговую нагрузку и процентные ставки.');
    }

    if (watchList.isEmpty) {
      watchList.addAll([
        'Следи за средней ценой покупки (${position.avgCleanPriceRub.toStringAsFixed(2)} ₽) и текущим ПнЛ.',
        'Не принимай решений на эмоциях при красных или зеленых свечах.',
      ]);
    }

    return TradeAudit(
      verdict: verdict,
      title: title,
      steps: steps,
      whyNotElse: whyNotElse,
      recommendation: recommendation,
      watchList: watchList,
    );
  }

  static TradeAudit auditSell({
    required SimInstrument instrument,
    required HoldingPosition position,
    required int units,
    required double netProceeds,
    required double feeRub,
    required double taxRub,
    required double realizedProfit,
  }) {
    final steps = <String>[
      'Шаг 1. Расчет продажи: выручка за вычетом комиссии (${feeRub.toStringAsFixed(2)} ₽) и налога (${taxRub.toStringAsFixed(2)} ₽) составила ${netProceeds.toStringAsFixed(2)} ₽.',
      'Шаг 2. Финансовый результат по проданным бумагам: ${realizedProfit >= 0 ? '+' : ''}${realizedProfit.toStringAsFixed(2)} ₽ (средняя покупка была ${position.avgCleanPriceRub.toStringAsFixed(2)} ₽).',
    ];

    String verdict = 'ПРАВИЛЬНО';
    String title = 'Осознанная продажа ${instrument.ticker} ($units шт.)';
    String whyNotElse = 'Выход выполнен с учетом комиссии и налогового эффекта.';
    String recommendation = 'Оцени, куда направить освободившийся кэш: в резерв, более надежный актив или новую идею по плану.';
    final watchList = <String>[
      'Учитывай, что при продаже в плюс удерживается налог (13%), который уменьшает чистую доходность.',
      'Проверяй, не продаешь ли ты актив в спешке из-за краткосрочного шума.',
    ];

    if (realizedProfit < 0) {
      verdict = 'ВНИМАНИЕ';
      title = 'Фиксация убытка по ${instrument.ticker} (${realizedProfit.toStringAsFixed(2)} ₽)';
      steps.add(
        'Шаг 3. Работа с убытком: ты закрыла позицию ниже средней цены покупки. Налог с прибыли в этой сделке не удерживается.',
      );
      whyNotElse = 'Держать заведомо сломанную идею ради «пересидеть» бывает дороже, но закрывать позицию без плана тоже опасно.';
      recommendation = 'Запиши причину убытка в дневник: ошибка входа, смена ставки или неверный размер позиции.';
    } else if (taxRub > 0 && realizedProfit < 150) {
      verdict = 'ВНИМАНИЕ';
      title = 'Небольшая прибыль с удержанием налога (${taxRub.toStringAsFixed(2)} ₽)';
      steps.add(
        'Шаг 3. Издержки: часть небольшой прибыли ушла на комиссию и налог.',
      );
      whyNotElse = 'Частые мелкие сделки «туда-сюда» съедают доходность издержками.';
      recommendation = 'Держи позиции дольше при наличии инвестиционной идеи, чтобы не терять на обороте.';
    }

    return TradeAudit(
      verdict: verdict,
      title: title,
      steps: steps,
      whyNotElse: whyNotElse,
      recommendation: recommendation,
      watchList: watchList,
    );
  }
}
