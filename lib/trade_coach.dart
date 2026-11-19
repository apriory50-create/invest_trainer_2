import 'sim_models.dart';

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
      whyWrong:
          'Длинные ОФЗ имеют большую дюрацию: при росте ставки ЦБ их рыночная цена заметно падает, давая бумажный минус по телу.',
      howToFix:
          'На фазе ужесточения ставки держи короткие облигации, флоатеры или фонды ликвидности; длинные ОФЗ набирай частями ближе к развороту цикла.',
      watchSignal:
          'Смотри на кривую доходности ОФЗ, инфляцию и риторику ЦБ на заседаниях.',
    ),
    MistakeCatalogItem(
      code: 'ERR-02',
      category: 'Облигации и НКД',
      mistakeName:
          'Путаница между ценой в % от номинала и реальной суммой списания с учетом НКД',
      whyWrong:
          'При покупке облигации сверх цены бумаги списывается накопленный купонный доход (НКД) и комиссия — новичку кажется, что денег списали больше ожидаемого.',
      howToFix:
          'Всегда считай полную сумму сделки: (Цена + НКД) * кол-во + комиссия, и сверяй с остатком свободного кэша.',
      watchSignal:
          'Следи за датой ближайшего купона и размером НКД в карточке бумаги.',
    ),
    MistakeCatalogItem(
      code: 'ERR-03',
      category: 'Риск-менеджмент',
      mistakeName:
          'Вход в одну бумагу на 40–70% всего капитала («всё на одну карту»)',
      whyWrong:
          'При плохой новости или просадке сектора весь портфель начинает лихорадить, а эмоции толкают на панические решения.',
      howToFix:
          'Ограничивай долю одного эмитента (обычно до 15–20% портфеля) и оставляй подушку ликвидности.',
      watchSignal:
          'Проверяй долю позиции в процентах от общего капитала до нажатия «Купить».',
    ),
    MistakeCatalogItem(
      code: 'ERR-04',
      category: 'Фундаментал и долг',
      mistakeName:
          'Погоня за высоким купоном/дивидендом у компании с тяжелым долгом',
      whyWrong:
          'Высокая доходность часто платит за риск: при дорогом кредитовании компания тратит прибыль на проценты по долгам.',
      howToFix:
          'Оценивай долговую нагрузку и способность бизнеса обслуживать долг, а не смотри только на красивую цифру доходности.',
      watchSignal:
          'Обращай внимание на рост процентных расходов и рефинансирование долгов.',
    ),
    MistakeCatalogItem(
      code: 'ERR-05',
      category: 'Психология и вход',
      mistakeName:
          'Покупка после резкого зеленого импульса («FOMO — страх упустить»)',
      whyWrong:
          'Вход на всплеске эмоций часто означает покупку у тех, кто фиксирует прибыль, с высоким риском откатиться назад.',
      howToFix:
          'Дождись отката, проверки уровня или срабатывания плана по «5 Фильтрам Профи».',
      watchSignal:
          'Сравни текущую цену со средней и задай себе вопрос: зачем я покупаю именно сейчас?',
    ),
    MistakeCatalogItem(
      code: 'ERR-06',
      category: 'Продажа и налоги',
      mistakeName:
          'Частая продажа прибыльных активов без учета налога (13%) и комиссии',
      whyWrong:
          'При фиксации прибыли удерживается налог и комиссия, а перекладка в другой актив без причины снижает сложный процент.',
      howToFix:
          'Продавай по плану: цель достигнута, изменился фундамент, нужен ребаланс или сработал защитный выход.',
      watchSignal:
          'Считай чистый результат после комиссии и НДФЛ, а не грязную разницу цен.',
    ),
    MistakeCatalogItem(
      code: 'ERR-07',
      category: 'Убытки и стопы',
      mistakeName:
          'Усреднение падающего актива без понимания причины падения',
      whyWrong:
          'Если бизнес или сектор ухудшился структурно, доливка на падении лишь увеличивает убыточную позицию.',
      howToFix:
          'Сначала ответь: это временный шум рынка или поломка идеи? Без плана выхода не усредняй.',
      watchSignal:
          'Сверяйся с новостным фоном и правилом ограничения убытка.',
    ),
    MistakeCatalogItem(
      code: 'ERR-08',
      category: 'Ликвидность',
      mistakeName: 'Остаться без свободного кэша в момент рыночной просадки',
      whyWrong:
          'Когда появляются выгодные цены или нужно закрыть кассовый разрыв, свободных денег на счете нет.',
      howToFix:
          'Держи резерв в кэше или фонде ликвидности (например, LQDT), чтобы не продавать активы в спешке.',
      watchSignal:
          'Следи за долей свободного кэша и ликвидных инструментов в портфеле.',
    ),
  ];

  static CoachComment reviewBuy({
    required SimInstrument instrument,
    required HoldingPosition position,
    required int units,
    required double totalCost,
    required double nkdSum,
    required double feeRub,
    required double cashAfter,
    required double portfolioBefore,
    required double currentKeyRatePct,
  }) {
    final details = <String>[
      'Списано всего: ${totalCost.toStringAsFixed(2)} ₽ (бумаги ${(units * instrument.priceRub).toStringAsFixed(2)} ₽, НКД ${nkdSum.toStringAsFixed(2)} ₽, комиссия ${feeRub.toStringAsFixed(2)} ₽).',
      'Остаток кэша после покупки: ${cashAfter.toStringAsFixed(2)} ₽ (ключевая ставка: ${currentKeyRatePct.toStringAsFixed(1)}%).',
    ];

    final sharePct =
        portfolioBefore > 0 ? (totalCost / portfolioBefore) * 100 : 0.0;
    String tag = 'ПРАВИЛЬНО';
    String headline = 'Покупка ${instrument.ticker} ($units шт.) оформлена по плану';
    String whySoNotOtherwise =
        'Сразу учтены полная стоимость, НКД и комиссия, а не только котировка.';
    String advice =
        'Заранее определи условие выхода или добора и не меняй решение из-за шума.';
    final watchNext = <String>[
      'Средняя цена входа: ${position.avgCleanPriceRub.toStringAsFixed(2)} ₽.',
      'Доля этой покупки в капитале: ~${sharePct.toStringAsFixed(1)}%.',
    ];

    if (sharePct > 25.0) {
      tag = 'ОШИБКА';
      headline =
          'Крупная доля в одной сделке (~${sharePct.toStringAsFixed(1)}% капитала)';
      whySoNotOtherwise =
          'Слишком крупная доля в одном активе повышает просадку портфеля при неблагоприятном движении.';
      advice =
          'Разбивай вход на части и соблюдай лимиты доли на одну бумагу.';
    } else if (instrument.kind == AssetKind.ofz &&
        instrument.maturityMonthsLeft > 60 &&
        currentKeyRatePct >= 15.0) {
      tag = 'ВНИМАНИЕ';
      headline = 'Длинная ОФЗ при высокой ключевой ставке (${currentKeyRatePct.toStringAsFixed(1)}%)';
      whySoNotOtherwise =
          'Длинные бумаги сильнее реагируют на изменение ставок, чем короткий долг или денежный рынок.';
      advice =
          'Оценивай горизонт владения и не пугайся колебаний тела до снижения ставок.';
    } else if (instrument.debtToEbitda >= 2.0) {
      tag = 'ВНИМАНИЕ';
      headline = 'Эмитент с заметной долговой нагрузкой (${instrument.debtToEbitda.toStringAsFixed(1)}x)';
      whySoNotOtherwise =
          'Высокие ставки дольше всего давят на заемщиков с большим долгом.';
      advice =
          'Держи умеренную долю и следи за денежным потоком и процентными расходами.';
    } else if (cashAfter < portfolioBefore * 0.10) {
      tag = 'ВНИМАНИЕ';
      headline = 'Почти весь кэш задействован (резерв ниже 10%)';
      whySoNotOtherwise =
          'Малый остаток кэша сужает маневр при новых идеях или просадках.';
      advice =
          'Следи за ликвидным резервом перед следующими покупками.';
    }

    return CoachComment(
      tag: tag,
      headline: headline,
      details: details,
      whySoNotOtherwise: whySoNotOtherwise,
      advice: advice,
      watchNext: watchNext,
    );
  }

  static CoachComment reviewSell({
    required SimInstrument instrument,
    required HoldingPosition position,
    required int units,
    required double netProceeds,
    required double feeRub,
    required double taxRub,
    required double realizedPnl,
  }) {
    final details = <String>[
      'Чистое поступление в кэш: ${netProceeds.toStringAsFixed(2)} ₽ (комиссия ${feeRub.toStringAsFixed(2)} ₽, налог ${taxRub.toStringAsFixed(2)} ₽).',
      'Результат по проданным бумагам: ${realizedPnl >= 0 ? '+' : ''}${realizedPnl.toStringAsFixed(2)} ₽.',
    ];

    String tag = 'ПРАВИЛЬНО';
    String headline = 'Продажа ${instrument.ticker} ($units шт.) зафиксирована';
    String whySoNotOtherwise =
        'Итоговый результат посчитан после комиссии и налога на прибыль.';
    String advice =
        'Определи, куда пойдет освободившийся кэш по твоему плану.';

    if (realizedPnl < 0) {
      tag = 'ВНИМАНИЕ';
      headline = 'Фиксация убытка по ${instrument.ticker} (${realizedPnl.toStringAsFixed(2)} ₽)';
      whySoNotOtherwise =
          'Закрытие в минус помогает остановить рост убытка, если идея перестала работать.';
      advice =
          'Зафиксируй вывод по сделке и не пытайся «отыграться» на эмоциях.';
    }

    return CoachComment(
      tag: tag,
      headline: headline,
      details: details,
      whySoNotOtherwise: whySoNotOtherwise,
      advice: advice,
      watchNext: [
        'Остаток позиции ${instrument.ticker}: ${position.units} шт.',
        'Чистый остаток кэша и налоговые удержания за период.',
      ],
    );
  }

  static CoachComment reviewScenario({
    required SimScenario scenario,
    required double newKeyRatePct,
    required double portfolioBefore,
    required double portfolioAfter,
  }) {
    final diff = portfolioAfter - portfolioBefore;
    final pct = portfolioBefore > 0 ? (diff / portfolioBefore) * 100 : 0.0;

    return CoachComment(
      tag: 'СЦЕНАРИЙ',
      headline: '${scenario.title} (ставка: ${newKeyRatePct.toStringAsFixed(1)}%)',
      details: [
        scenario.description,
        'Изменение стоимости портфеля: ${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(2)} ₽ (${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%).',
      ],
      whySoNotOtherwise: scenario.whyMarketReacts,
      advice: scenario.whatToDo,
      watchNext: [
        'Косвенные признаки: ${scenario.indirectClues}',
        'Капитал портфеля сейчас: ${portfolioAfter.toStringAsFixed(2)} ₽.',
      ],
    );
  }
}

