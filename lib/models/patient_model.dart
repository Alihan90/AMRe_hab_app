import 'dart:convert';

class Patient {
  final String id;
  final String fullName;
  final int age;
  final String chamber;      // Палата та ліжко пацієнта
  final String diagnosis;    // Клінічний діагноз за МКХ-10
  
  // Компоненти Індивідуального реабілітаційного плану (ІРП) згідно з вимогами МОЗ:
  String icfCodes;           // Встановлені коди МКФ (ICF)
  String currentSmartGoal;   // Сформована SMART-ціль
  String irpInterventions;   // Реабілітаційні втручання та дозування вправ
  String irpTerm;            // Термін виконання (коротко-/довгостроковий)
  
  // Історія оцінювання за 16 шкалами:
  List<Map<String, dynamic>> testHistory;

  Patient({
    required this.id,
    required this.fullName,
    required this.age,
    required this.chamber,
    required this.diagnosis,
    required this.currentSmartGoal,
    this.icfCodes = "",
    this.irpInterventions = "",
    this.irpTerm = "Короткостроковий (до 14 днів)",
    List<Map<String, dynamic>>? testHistory,
  }) : this.testHistory = testHistory ?? [];

  // Конвертація в Map для локальної бази даних (SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'age': age,
      'chamber': chamber,
      'diagnosis': diagnosis,
      'icfCodes': icfCodes,
      'currentSmartGoal': currentSmartGoal,
      'irpInterventions': irpInterventions,
      'irpTerm': irpTerm,
      'testHistory': testHistory,
    };
  }

  // Відновлення даних з локальної пам'яті телефону
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      age: map['age'] ?? 0,
      chamber: map['chamber'] ?? '',
      diagnosis: map['diagnosis'] ?? '',
      icfCodes: map['icfCodes'] ?? '',
      currentSmartGoal: map['currentSmartGoal'] ?? '',
      irpInterventions: map['irpInterventions'] ?? '',
      irpTerm: map['irpTerm'] ?? 'Короткостроковий (до 14 днів)',
      testHistory: List<Map<String, dynamic>>.from(map['testHistory'] ?? []),
    );
  }

  // Двигун автоматичного проектування ІРП на основі наказів МОЗ України
  static Map<String, String> generateAutoIRP(String mkhDiagnosis) {
    // 1. Протокол для Нейрореабілітації (Інсульти, ЧМТ)
    if (mkhDiagnosis.contains("I63") || mkhDiagnosis.contains("I61") || mkhDiagnosis.contains("Інсульт")) {
      return {
        "icf": "b730.2 (Порушення сили м'язів однієї половини тіла), d410 (Зміна положення тіла), d450 (Ходьба)",
        "goal": "Пацієнт зможе самостійно переміщатися з ліжка на приліжкове крісло за допомогою опорної рами з мінімальною підтримкою протягом 5 хвилин до моменту виписки (14 днів).",
        "interventions": "• Клінічне позиціонування: Протиспастичні укладки кінцівок кожні 2 години.\n• Кінезотерапія: Відновлення контролю тулуба, тренування балансу сидячи на краю ліжка (експозиція від 5 до 15 хв).\n• Пасивно-активні вправи для паретичних кінцівок (3 підходи по 10 повторень, 2 рази на день).\n• Ранній ортостатичний тренінг: Вертикалізація за допомогою активної опори."
      };
    } 
    // 2. Протокол для пацієнтів ВІТ (Реанімація, Полінейропатії, ШВЛ)
    else if (mkhDiagnosis.contains("G62") || mkhDiagnosis.contains("Слабість") || mkhDiagnosis.contains("ВІТ")) {
      return {
        "icf": "b440 (Функції дихання), b730.3 (Генералізована слабкість м'язів), d415 (Утримання положення тіла)",
        "goal": "Збільшити сумарну силу м'язів за шкалою MRC-SumScore з 32 до >= 42 балів та досягти утримання стабільного положення сидячи протягом 10 хвилин за 10 днів.",
        "interventions": "• Дихальна кінезотерапія: Діафрагмальне дихання, стимуляція кашльового поштовху, PEP-саморобні тренажери (5 хвилин кожні 2 години).\n• Пасивна мобілізація: Розробка суглобів для профілактики контрактур (CPM-режим).\n• Ізометричні вправи: Скорочення чотириголового м'яза стегна та сідничних м'язів (утримання тонусу 5 сек, 10 повторень).\n• Поетапна вертикалізація на ліжку-вертикалізаторі (кути 30°-45°-60°) під контролем ЧСС/АТ/SpO2."
      };
    } 
    // 3. Протокол для Травматології/Ортопедії (Ендопротези, остеосинтез)
    else if (mkhDiagnosis.contains("M16") || mkhDiagnosis.contains("Травма") || mkhDiagnosis.contains("Суглоб")) {
      return {
        "icf": "b710 (Функції рухливості суглобів), b780 (Функції пов'язані з відчуттям болю), d450 (Ходьба)",
        "goal": "Відновити кут згинання в оперованому суглобі до 90 градусів, навчити пацієнта безпечного осьового навантаження кінцівки з ходунками на відстань 50 метрів за 7 днів.",
        "interventions": "• Контроль болю (VAS) та набряку: Кріотерапія після навантаження, терапія положенням (дренажне підняття кінцівки).\n• Активно-асистивні вправи для збільшення амплітуди рухів у суглобі.\n• Тренування правильного патерну ходьби з використанням допоміжних засобів (ходунки/милиці).\n• Ізометричне тонізування фіксаторів суглоба."
      };
    } 
    // 4. Базовий реабілітаційний протокол для інших патологій (в т.ч. Кардіо та Онко)
    else {
      return {
        "icf": "b710 (Рухливість суглобів), d410 (Зміна положення тіла)",
        "goal": "Забезпечити безпечне, самостійне та безболісне виконання поворотів у ліжку та припіднімання тазу без сторонньої допомоги протягом 5 днів.",
        "interventions": "• Загальнозміцнююча ліжкова кінезотерапія за індивідуальним дозуванням.\n• Дихальні вправи для профілактики застійних явищ у легенях.\n• Поетапне висаджування та адаптація до ортостатичного навантаження."
      };
    }
  }
}
