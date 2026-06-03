import '../models/scale_model.dart';

class ClinicalData {
  static const List<Map<String, dynamic>> exercisesCatalog = [
    {
      "category": "Респіраторна терапія (МОЗ України)",
      "items": [
        {"name": "Контрольоване дихання", "desc": "Дихання за участю діафрагми для зниження задишки та покращення вентиляції нижніх часток легень."},
        {"name": "Дренажні положення", "desc": "Постуральний дренаж у поєднанні з перкусією для евакуації мокротиння."}
      ]
    },
    {
      "category": "Рання мобілізація та сила",
      "items": [
        {"name": "Пасивні/активні вправи в ліжку", "desc": "Циклічні рухи в суглобах для профілактики контрактур (акцент на великі м'язові групи)."},
        {"name": "Ортостатичне тренування", "desc": "Поступове вертикалізування пацієнта за допомогою ліжка-вертикалізатора або активного висаджування."}
      ]
    }
  ];

  static final List<ClinicalScale> allScales = [
    ClinicalScale(id: "ims", name: "Шкала мобільності ВІТ (IMS)", icfCategory: "d450 Рухливість", instruction: "Оцінка реального рівня мобільності пацієнта від 0 (лежачий) до 10 (самостійна ходьба).", testType: "single_choice", questions: [
      ClinicalQuestion(id: "q1", text: "Оберіть поточний рівень пацієнта:", options: [
        ClinicalOption(text: "Пасивне переміщення в крісло (0-2 бали)", score: 1),
        ClinicalOption(text: "Активне сидіння в ліжку, пересаджування (3-5 балів)", score: 4),
        ClinicalOption(text: "Ходьба з асистенцією або самостійно (6-10 балів)", score: 8),
      ])
    ]),
    ClinicalScale(id: "mrc", name: "Шкала м'язової сили (MRC-SumScore)", icfCategory: "b730 Сила м'язів", instruction: "Тестування 6 м'язових груп з обох сторін. Максимум 60 балів. Менше 48 — синдром ICUAW.", testType: "single_choice", questions: [
      ClinicalQuestion(id: "m1", text: "Сумарна оцінка м'язів верхніх та нижніх кінцівок:", options: [
        ClinicalOption(text: "Тяжка слабкість (менше 30 балів)", score: 20),
        ClinicalOption(text: "Помірна слабкість / Набута слабкість ВІТ (30-48 балів)", score: 40),
        ClinicalOption(text: "Нормальна м'язова сила (48-60 балів)", score: 55),
      ])
    ]),
    ClinicalScale(id: "vas", name: "Візуально-аналогова шкала болю (VAS)", icfCategory: "b280 Відчуття болю", instruction: "Оцінка інтенсивності болю пацієнтом від 0 (немає болю) до 10 (нестерпний біль).", testType: "single_choice", questions: [
      ClinicalQuestion(id: "v1", text: "Рівень болю за оцінкою пацієнта:", options: [
        ClinicalOption(text: "Легкий біль (0-3 бали)", score: 2),
        ClinicalOption(text: "Помірний біль (4-6 балів)", score: 5),
        ClinicalOption(text: "Тяжкий біль (7-10 балів)", score: 9),
      ])
    ]),
  ];
}
