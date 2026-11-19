import 'sim_models.dart';
import 'scenarios_all.dart';

class SimScenarios {
  static final List<SimScenario> items = [
    const SimScenario(
      id: 'SC-01',
      title: 'Резкое повышение ключевой ставки ЦБ (+2%)',
      category: 'Ставка ЦБ',
      description: 'ЦБ РФ повысил ключевую ставку на 2 п.п. из-за ускорения инфляции и жестко сигнализировал о сохранении высоких ставок.',
      indirectClues: 'Рост ставок по коротким вкладам выше ключевой, падение индекса RGBI за неделю до заседания.',
      whyMarketReacts: 'Старые облигации с фиксированным купоном дешевеют, чтобы их доходность сравнялась с новой ставкой ЦБ. Акции закредитованных компаний падают из-за дорогих кредитов.',
      whatToDo: 'Не продавать длинные ОФЗ в панике на дне, перекладывать свободный кэш во флоатеры и фонды денежного рынка.',
      priceShiftPct: {
        AssetKind.ofz: -4.5,
        AssetKind.bond: -3.2,
        AssetKind.stock: -3.8,
        AssetKind.etf: -1.5,
      },
      keyRateDeltaPct: 2.0,
    ),
    const SimScenario(
      id: 'SC-02',
      title: 'Начало цикла снижения ставки ЦБ (-1.5%)',
      category: 'Ставка ЦБ',
      description: 'Инфляция замедляется 3 месяца подряд, ЦБ снижает ключевую ставку на 1.5 п.п. и смягчает риторику.',
      indirectClues: 'Банки снижают ставки по вкладам на 1–3 года быстрее, чем ЦБ меняет ключевую ставку.',
      whyMarketReacts: 'Длинные ОФЗ резко растут в цене, переоцениваясь под более низкую доходность. Акции начинают ралли за счет перетока денег с вкладов.',
      whatToDo: 'Фиксировать высокую доходность в длинных ОФЗ с постоянным купоном и дивидендных акциях.',
      priceShiftPct: {
        AssetKind.ofz: 6.2,
        AssetKind.bond: 3.8,
        AssetKind.stock: 5.5,
        AssetKind.etf: 2.8,
      },
      keyRateDeltaPct: -1.5,
    ),
    const SimScenario(
      id: 'SC-03',
      title: 'Девальвация рубля на 12% за месяц',
      category: 'Валюта и сырье',
      description: 'Курс доллара и юаня резко вырос на фоне сокращения профицита торгового баланса.',
      indirectClues: 'Снижение объемов продажи валютной выручки экспортерами и рост импорта.',
      whyMarketReacts: 'Выручка нефтяников и металлургов в рублях растет. Внутренний рынок и импортеры сталкиваются с ростом издержек и инфляцией.',
      whatToDo: 'Держать долю в экспортерах и замещающих облигациях; на пике паники фиксировать часть валютной прибыли.',
      priceShiftPct: {
        AssetKind.ofz: -2.0,
        AssetKind.bond: -1.2,
        AssetKind.stock: 4.8,
        AssetKind.etf: 2.1,
      },
      keyRateDeltaPct: 1.0,
    ),
    const SimScenario(
      id: 'SC-04',
      title: 'Неожиданная отмена дивидендов крупным эмитентом',
      category: 'Корпоративные события',
      description: 'Совет директоров рекомендовал не выплачивать дивиденды, направив прибыль на капитальные затраты и погашение долга.',
      indirectClues: 'Рост долговой нагрузки (Чистый долг/EBITDA > 2.5x) и отрицательный свободный денежный поток в последнем отчете.',
      whyMarketReacts: 'Частные инвесторы массово продают бумагу, так как покупали её ради дивидендной доходности.',
      whatToDo: 'Всегда проверять FCF и долговую нагрузку перед покупкой под дивиденды, не ставить весь капитал на одну идею.',
      priceShiftPct: {
        AssetKind.ofz: 0.2,
        AssetKind.bond: -0.5,
        AssetKind.stock: -7.5,
        AssetKind.etf: -2.2,
      },
      keyRateDeltaPct: 0.0,
    ),
    const SimScenario(
      id: 'SC-05',
      title: 'Нефть Brent упала на 15%, рубль стабилен',
      category: 'Сырьевой шок',
      description: 'Мировые цены на нефть снизились на фоне замедления мировой экономики, при этом курс рубля остается крепким.',
      indirectClues: 'Рост запасов нефти в США и снижение прогнозов мирового спроса.',
      whyMarketReacts: 'Рублевая цена бочки нефти падает, снижая будущую прибыль и дивиденды нефтегазового сектора.',
      whatToDo: 'Сократить долю цикличных сырьевых компаний с высокой себестоимостью добычи, переложиться в облигации и внутренний сектор.',
      priceShiftPct: {
        AssetKind.ofz: 0.5,
        AssetKind.bond: 0.3,
        AssetKind.stock: -5.2,
        AssetKind.etf: -1.8,
      },
      keyRateDeltaPct: 0.0,
    ),
    ...kAllScenarios.map((s) {
      final lower = s.assetType.toLowerCase();
      Map<AssetKind, double> shifts = {
        AssetKind.ofz: -0.5,
        AssetKind.bond: -0.5,
        AssetKind.stock: 1.5,
        AssetKind.etf: 0.8,
      };
      double rateDelta = 0.0;

      if (lower.contains('офз') || lower.contains('ставк')) {
        shifts = {
          AssetKind.ofz: -2.5,
          AssetKind.bond: -1.8,
          AssetKind.stock: -1.5,
          AssetKind.etf: -0.5,
        };
        rateDelta = 0.5;
      } else if (lower.contains('облигац')) {
        shifts = {
          AssetKind.ofz: 0.4,
          AssetKind.bond: -2.2,
          AssetKind.stock: -0.4,
          AssetKind.etf: 0.2,
        };
      } else if (lower.contains('бпиф') || lower.contains('фонд')) {
        shifts = {
          AssetKind.ofz: 0.8,
          AssetKind.bond: 0.9,
          AssetKind.stock: 1.2,
          AssetKind.etf: 1.4,
        };
      }

      return SimScenario(
        id: 'CASE-${s.id}',
        title: s.title,
        category: s.assetType,
        description: '${s.newsHeadline}\n\n${s.plainExplanation}',
        indirectClues: s.indirectSigns,
        whyMarketReacts: '${s.entryRule}\n${s.exitRule}',
        whatToDo: s.bestAction,
        priceShiftPct: shifts,
        keyRateDeltaPct: rateDelta,
      );
    }),
  ];
}
