class ClinicalOption {
  final String text;
  final int score;
  const ClinicalOption({required this.text, required this.score});
}

class ClinicalQuestion {
  final String id;
  final String text;
  final List<ClinicalOption> options;
  const ClinicalQuestion({required this.id, required this.text, required this.options});
}

class ClinicalScale {
  final String id;
  final String name;
  final String fullName;
  final String icfCategory;
  final String instruction;
  final String indications;
  final List<ClinicalQuestion> questions;

  const ClinicalScale({
    required this.id,
    required this.name,
    required this.fullName,
    required this.icfCategory,
    required this.instruction,
    required this.indications,
    required this.questions,
  });
}

class ClinicalData {
  // МЕДИЧНИЙ ДОВІДНИК МКХ-10 (Розширений)
  static const List<Map<String, String>> mckh10Catalog = [
    {"code": "I63.0", "name": "Інфаркт мозку внаслідок тромбозу прецеребральних артерій"},
    {"code": "I63.3", "name": "Інфаркт мозку внаслідок тромбозу церебральних артерій (Ішемічний інсульт)"},
    {"code": "I61.9", "name": "Внутрішньомозковий крововилив неуточнений (Геморагічний інсульт)"},
    {"code": "G82.0", "name": "В'яла параплегія (Нижній парапарез)"},
    {"code": "G82.2", "name": "Параплегія неуточнена"},
    {"code": "G82.4", "name": "Спастична тетраплегія"},
    {"code": "M16.0", "name": "Первинний коксартроз двобічний"},
    {"code": "M16.1", "name": "Інший первинний коксартроз (кульшовий суглоб)"},
    {"code": "M17.0", "name": "Первинний гонартроз двобічний (колінний суглоб)"},
    {"code": "T90.5", "name": "Наслідки внутрішньочерепної травми"},
    {"code": "T91.3", "name": "Наслідки травми спинного мозку"},
  ];

  // ДОМЕНИ МКФ
  static const List<Map<String, String>> icfDomains = [
    {"code": "b730", "name": "Функції сили м'язів (Геміпарез, тетрапарез, слабкість ВІТ)"},
    {"code": "b280", "name": "Відчуття болю (Ноцицептивний, нейропатичний біль)"},
    {"code": "b710", "name": "Функції рухливості суглобів (Контрактури, обмеження амплітуди)"},
    {"code": "d450", "name": "Ходьба (Пересування на короткі та довгі відстані)"},
    {"code": "d410", "name": "Зміна положення тіла (З положення лежачи в положення сидячи/стоячи)"},
    {"code": "d415", "name": "Підтримання положення тіла (Утримання рівноваги сидячи або стоячи)"},
    {"code": "d510", "name": "Миття тіла (Самообслуговування та гігієна)"},
  ];

  // ПРОТОКОЛЬНІ ФІЗИЧНІ ВПРАВИ ТА ТЕРАПЕВТИЧНІ ВТРУЧАННЯ
  static const List<Map<String, dynamic>> exercisesCatalog = [
    {
      "category": "Респіраторна фізична терапія",
      "items": [
        {"name": "Діафрагмальне дихання", "desc": "Контроль дихальних рухів животом для зниження задишки, активації нижніх часток легень та покращення оксигенації."},
        {"name": "Постуральний дренаж", "desc": "Надання пацієнту специфічних положень у ліжку для пасивного відтоку бронхіального секрету під дією сили тяжіння."},
        {"name": "Хаффінг-техніка (Huffed coughing)", "desc": "Форсований видих з відкритою голосовою щілиною для евакуації мокротиння без надмірного кашльового зусилля."}
      ]
    },
    {
      "category": "Рання мобілізація та профілактика ускладнень ВІТ",
      "items": [
        {"name": "Пасивна суглобова гімнастика", "desc": "Виконання терапевтом рухів у всіх суглобах кінцівок пацієнта для профілактики ранніх м'язових контрактур."},
        {"name": "Вправи на циклічному велоергометрі в ліжку", "desc": "Застосування ліжкових тренажерів для підтримки трофіки м'язів та стимуляції кровообігу нижніх кінцівок."},
        {"name": "Прогресивне висаджування (Edge of bed)", "desc": "Поступове переведення пацієнта в положення сидячи з опущеними ногами для тренування ортостатичної стійкості."}
      ]
    },
    {
      "category": "Нейром'язова активація та баланс",
      "items": [
        {"name": "PNF-фасилітація (Лопаткові та тазові патерни)", "desc": "Пропріоцептивна нейром'язова фасилітація для відновлення правильних рухових стереотипів у хворих з геміпарезом."},
        {"name": "Міст сідничний (Bridging)", "desc": "Підйом тазу з положення лежачи на спині із зігнутими колінами для активації великого сідничного м'яза та стабілізації кору."},
        {"name": "Тренування балансу на стабілоплатформі / балансувальних подушках", "desc": "Активація глибоких м'язів-стабілізаторів у положенні стоячи для відновлення координації."}
      ]
    },
    {
      "category": "Відновлення ходьби та локомоції",
      "items": [
        {"name": "Імітація крокових рухів без опори", "desc": "Вправи в положенні лежачи або сидячи для відновлення кінематики кроку."},
        {"name": "Ходьба в брусах з дзеркальним контролем", "desc": "Пересування в брусах з візуальним зворотним зв'язком для корекції асиметрії кроку та атаксії."},
        {"name": "Дозована ходьба з асистивними засобами (ходунки/палиці)", "desc": "Тренування стереотипу ходьби з поступовим зменшенням підтримки терапевта."}
      ]
    }
  ];

  // КАТАЛОГ ВСІХ 16 КЛІНІЧНИХ ШКАЛ ОЦІНКИ
  static final List<ClinicalScale> allScales = [
    ClinicalScale(
      id: "ims",
      name: "IMS",
      fullName: "Шкала мобільності відділення інтенсивної терапії (ICU Mobility Scale)",
      icfCategory: "d450 Рухливість / d410 Зміна положення тіла",
      instruction: "Оцініть найвищий рівень мобільності, який пацієнт демонструє самостійно або з допомогою терапевта.",
      indications: "Пацієнти у критичному стані, тривале перебування на ШВЛ, гострий період інсульту.",
      questions: [
        ClinicalQuestion(id: "ims_q1", text: "Оберіть максимальний поточний рівень активності пацієнта:", options: [
          ClinicalOption(text: "Рівень 0: Лише пасивні рухи в ліжку терапевтом", score: 0),
          ClinicalOption(text: "Рівень 1: Пасивне сидіння в ліжку, підйом узголів'я", score: 1),
          ClinicalOption(text: "Рівень 2: Пасивне пересаджування в крісло (без осьового навантаження)", score: 2),
          ClinicalOption(text: "Рівень 3: Активне утримання сидячого положення на краю ліжка", score: 3),
          ClinicalOption(text: "Рівень 4: Активний перехід у положення стоячи (опора на ноги)", score: 4),
          ClinicalOption(text: "Рівень 5: Ходьба на місці біля ліжка з допомогою 1-2 осіб", score: 5),
          ClinicalOption(text: "Рівень 6: Ходьба з допоміжними засобами (ходунки) за підтримки 1 особи", score: 6),
          ClinicalOption(text: "Рівень 7: Самостійна ходьба з ходунками (без фізичної допомоги)", score: 7),
          ClinicalOption(text: "Рівень 8: Ходьба без засобів опори за підтримки 1 особи", score: 8),
          ClinicalOption(text: "Рівень 9: Самостійна ходьба з палицею або ортезом", score: 9),
          ClinicalOption(text: "Рівень 10: Повністю незалежна, безпечна ходьба без обмежень", score: 10),
        ])
      ]
    ),
    ClinicalScale(
      id: "mrc",
      name: "MRC-SumScore",
      fullName: "Шкала оцінки м'язової сили (Medical Research Council SumScore)",
      icfCategory: "b730 Функції сили м'язів",
      instruction: "Протестуйте білатерально 3 групи м'язів на верхніх кінцівках (відведення плеча, згинання передпліччя, розгинання кисті) та 3 групи на нижніх кінцівках (згинання стегна, розгинання гомілки, тильне згинання стопи). Кожна група оцінюється від 0 до 5. Сума варіюється від 0 до 60.",
      indications: "Набута слабкість у відділенні інтенсивної терапії (ICUAW), м'язова дистрофія, полінейропатії.",
      questions: [
        ClinicalQuestion(id: "mrc_q1", text: "Розрахуйте сумарний бал м'язової сили для всіх 12 патернів рухів рух:", options: [
          ClinicalOption(text: "Плігія / Відсутність скорочень (менше 12 балів)", score: 10),
          ClinicalOption(text: "Тяжка загальна слабкість / Виражений тетрапарез (12-36 балів)", score: 25),
          ClinicalOption(text: "Помірна слабкість / Наявність критерію ICUAW (37-48 балів)", score: 42),
          ClinicalOption(text: "Легке зниження сили, функціональні рухи збережені (49-59 балів)", score: 54),
          ClinicalOption(text: "Повна фізіологічна норма м'язової сили (60 балів)", score: 60),
        ])
      ]
    ),
    ClinicalScale(
      id: "vas",
      name: "VAS",
      fullName: "Візуально-аналогова шкала болю (Visual Analog Scale)",
      icfCategory: "b280 Відчуття болю",
      instruction: "Попросіть пацієнта позначити на лінії від 0 до 10 рівень болю, який він відчуває прямо зараз. 0 — біль відсутній, 10 — максимально стерпний біль.",
      indications: "Оцінка больового синдрому при травмах, операціях, хронічних патологіях опорно-рухового апарату.",
      questions: [
        ClinicalQuestion(id: "vas_q1", text: "Суб'єктивний рівень болю пацієнта:", options: [
          ClinicalOption(text: "0 - Біль повністю відсутній", score: 0),
          ClinicalOption(text: "1-3 - Слабкий біль (не заважає щоденній активності)", score: 2),
          ClinicalOption(text: "4-6 - Помірний біль (впливає на сон, обмежує рухи)", score: 5),
          ClinicalOption(text: "7-9 - Сильний/тяжкий біль (виражене страждання)", score: 8),
          ClinicalOption(text: "10 - Надважкий, нестерпний больовий шок", score: 10),
        ])
      ]
    ),
    ClinicalScale(
      id: "bbs",
      name: "Berg Balance Scale",
      fullName: "Шкала рівноваги Берга",
      icfCategory: "d415 Підтримання положення тіла",
      instruction: "Проведіть 14 функціональних тестів (сидіння, стояння, пересаджування, стояння з заплющеними очима тощо). Кожен пункт оцінюється від 0 до 4 балів. Максимум 56 балів.",
      indications: "Оцінка ризику падінь у літніх людей, пацієнтів після інсульту та з хворобою Паркінсона.",
      questions: [
        ClinicalQuestion(id: "bbs_q1", text: "Загальний результат виконання 14 тестів на рівновагу:", options: [
          ClinicalOption(text: "0-20 балів: Високий ризик падінь, пацієнт прикутий до крісла", score: 15),
          ClinicalOption(text: "21-40 балів: Помірний ризик падінь, пересування з допоміжними засобами", score: 32),
          ClinicalOption(text: "41-56 балів: Низький ризик падінь, самостійне утримання балансу", score: 49),
        ])
      ]
    ),
    ClinicalScale(
      id: "rmi",
      name: "Rivermead Mobility Index",
      fullName: "Індекс мобільності Рівермід",
      icfCategory: "d450 Рухливість",
      instruction: "Оцінка складається з 14 запитань до пацієнта та 1 прямого спостереження (стояння 10 секунд). За кожну ствердну відповідь нараховується 1 бал. Максимум 15.",
      indications: "Оцінка функціональних рухових навичок у пацієнтів після неврологічних катастроф.",
      questions: [
        ClinicalQuestion(id: "rmi_q1", text: "Кількість успішно виконаних рухових дій (0-15):", options: [
          ClinicalOption(text: "Тяжкі порушення рухливості (0-4 бали)", score: 2),
          ClinicalOption(text: "Помірні обмеження пересування (5-10 балів)", score: 7),
          ClinicalOption(text: "Мінімальні порушення / Повна автономія (11-15 балів)", score: 13),
        ])
      ]
    ),
    ClinicalScale(
      id: "rass",
      name: "RASS",
      fullName: "Шкала седації-ажитації Річмонда (Richmond Agitation-Sedation Scale)",
      icfCategory: "b110 Функції свідомості",
      instruction: "Оцініть стан пацієнта шляхом візуального спостереження. Якщо пацієнт спить або не реагує, перевірте реакцію на голос та фізичний стимул. Діапазон від -5 до +4.",
      indications: "Моніторинг рівня свідомості пацієнтів у палатах інтенсивної терапії та реанімації.",
      questions: [
        ClinicalQuestion(id: "rass_q1", text: "Поточний психоемоційний стан та рівень свідомості:", options: [
          ClinicalOption(text: "Від -5 до -3: Глибока/помірна седація (немає реакції або реакція лише на фізичний стимул)", score: -4),
          ClinicalOption(text: "Від -2 до -1: Легка седація / Сонливість (пробудження на голос, утримання погляду)", score: -1),
          ClinicalOption(text: "0: Спокійний, уважний стан, адекватний контакт", score: 0),
          ClinicalOption(text: "Від +1 до +4: Ажитація, тривога, агресивна або некерована поведінка", score: 2),
        ])
      ]
    ),
    ClinicalScale(
      id: "fad",
      name: "FIM / Barthel",
      fullName: "Модифікований Індекс Активності Повсякденного Життя Бартел (Barthel Index)",
      icfCategory: "d5 Самообслуговування",
      instruction: "Оцініть 10 пунктів щоденної життєдіяльності (харчування, особиста гігієна, туалет, одягання, контроль сфінктерів, переміщення, ходьба). Максимум 100 балів.",
      indications: "Оцінка ступеня інвалідності, залежності від сторонньої допомоги в побуті.",
      questions: [
        ClinicalQuestion(id: "barthel_q1", text: "Сумарний індекс життєдіяльності за Бартел:", options: [
          ClinicalOption(text: "Повна залежність від стороннього догляду (0-20 балів)", score: 10),
          ClinicalOption(text: "Тяжка залежність (21-60 балів)", score: 45),
          ClinicalOption(text: "Помірна залежність (61-90 балів)", score: 75),
          ClinicalOption(text: "Мінімальна залежність / Повна побутова незалежність (91-100 балів)", score: 95),
        ])
      ]
    ),
    ClinicalScale(
      id: "ashworth",
      name: "Modified Ashworth Scale",
      fullName: "Модифікована шкала спастичності Ешворта",
      icfCategory: "b735 Функції м'язового тонусу",
      instruction: "Оцініть опір, що виникає під час пасивного згинання/розгинання кінцівки у суглобі. Оцінки від 0 (нормальний тонус) до 4 (кінцівка ригідна).",
      indications: "Центральні парези, інсульти, розсіяний склероз, спинальні травми зі спастичним синдромом.",
      questions: [
        ClinicalQuestion(id: "ash_q1", text: "Рівень м'язового тонусу при пасивному русі:", options: [
          ClinicalOption(text: "0: Немає підвищення тонусу", score: 0),
          ClinicalOption(text: "1-1+: Легке підвищення тонусу, мінімальний опір наприкінці руху", score: 1),
          ClinicalOption(text: "2: Помірне підвищення тонусу впродовж більшої частини руху, рух легкий", score: 2),
          ClinicalOption(text: "3: Значне підвищення тонусу, пасивний рух утруднений", score: 3),
          ClinicalOption(text: "4: Уражений сегмент ригідний при згинанні чи розгинанні", score: 4),
        ])
      ]
    ),
    // Додаткові шкали для забезпечення повного списку (16 шкал) у майбутньому розширенні логіки
    ClinicalScale(id: "nihss", name: "NIHSS", fullName: "Шкала інсульту Національного інституту здоров'я", icfCategory: "b1 Системні неврологічні функції", instruction: "Неврологічний огляд.", indications: "Гострий інсульт.", questions: [ClinicalQuestion(id: "n1", text: "Бал за NIHSS", options: [ClinicalOption(text: "Легкий (0-4)", score: 2), ClinicalOption(text: "Тяжкий (більше 15)", score: 18)])]),
    ClinicalScale(id: "tug", name: "TUG", fullName: "Тест 'Встань та йди' (Timed Up and Go Test)", icfCategory: "d450 Ходьба та баланс", instruction: "Встати з крісла, пройти 3 метри, повернутися і сісти на час.", indications: "Оцінка мобільності.", questions: [ClinicalQuestion(id: "t1", text: "Час виконання тесту", options: [ClinicalOption(text: "Норма (< 10 сек)", score: 8), ClinicalOption(text: "Високий ризик падінь (> 14 сек)", score: 15)])]),
    ClinicalScale(id: "fac", name: "FAC", fullName: "Функціональні категорії ходьби (Functional Ambulation Categories)", icfCategory: "d450 Ходьба", instruction: "Визначення рівня незалежності при ходьбі.", indications: "Порушення локомоції.", questions: [ClinicalQuestion(id: "f1", text: "Категорія ходьби", options: [ClinicalOption(text: "Категорія 0-2 (Потребує постійної підтримки)", score: 1), ClinicalOption(text: "Категорія 4-5 (Незалежна ходьба)", score: 5)])]),
    ClinicalScale(id: "mas", name: "MAS (Motor Assessment Scale)", fullName: "Шкала рухової оцінки", icfCategory: "b760 Рухові функції", instruction: "Оцінка виконання повсякденних рухових завдань.", indications: "Інсульт.", questions: [ClinicalQuestion(id: "mas1", text: "Загальний рівень моторних навичок", options: [ClinicalOption(text: "Низький моторний вихід", score: 10), ClinicalOption(text: "Високий функціональний рівень", score: 40)])]),
    ClinicalScale(id: "fugl_meyer", name: "Fugl-Meyer", fullName: "Шкала Фугл-Мейєра для оцінки рухового відновлення", icfCategory: "b760 Рухові функції", instruction: "Детальний тест рефлексів, синергій та координації.", indications: "Геміплегія.", questions: [ClinicalQuestion(id: "fm1", text: "Загальний руховий дефіцит", options: [ClinicalOption(text: "Виражений дефіцит", score: 30), ClinicalOption(text: "Мінімальний дефіцит", score: 90)])]),
    ClinicalScale(id: "tinetti", name: "Tinetti POMA", fullName: "Шкала оцінки ходьби та рівноваги Тінетті", icfCategory: "d415 Баланс та локомоція", instruction: "Оцінка стійкості стоячи та кінематики кроку.", indications: "Геріатрія, атаксії.", questions: [ClinicalQuestion(id: "tin1", text: "Сумарний бал Тінетті", options: [ClinicalOption(text: "Високий ризик падінь (<19 балів)", score: 12), ClinicalOption(text: "Низький ризик падінь (24-28 балів)", score: 26)])]),
    ClinicalScale(id: "6mwt", name: "6MWT", fullName: "Тест 6-хвилинної ходьби (6-Minute Walk Test)", icfCategory: "b455 Толерантність до фізичного навантаження", instruction: "Вимірювання максимальної відстані ходьби за 6 хвилин.", indications: "Кардіореспіраторний дефіцит.", questions: [ClinicalQuestion(id: "6m1", text: "Пройдена дистанція", options: [ClinicalOption(text: "Тяжке зниження толерантності (<200 м)", score: 150), ClinicalOption(text: "Помірна / Нормальна стійкість (>400 м)", score: 420)])]),
    ClinicalScale(id: "cpax", name: "CPAx", fullName: "Chelsea Critical Care Physical Assessment Tool", icfCategory: "b7 Функції опорно-рухового апарату", instruction: "Оцінка 10 функцій дихання та мобільності у ВІТ.", indications: "Реанімаційні пацієнти.", questions: [ClinicalQuestion(id: "cp1", text: "Загальний індекс CPAx", options: [ClinicalOption(text: "Глибока дисфункція (0-15 балів)", score: 8), ClinicalOption(text: "Функціональне відновлення (35-50 балів)", score: 42)])]),
  ];
}
