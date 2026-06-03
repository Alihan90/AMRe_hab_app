import 'dart:convert';

class Patient {
  final String id;
  final String fullName;
  final int age;
  final String chamber;
  final String diagnosis; // МКХ-10
  String currentSmartGoal;
  String icfCodes; // Коди МКФ (напр. b710, d450)
  String irpTerm; // Терміни виконання ІРП
  String irpInterventions; // Реабілітаційні втручання за Наказом МОЗ
  List<Map<String, dynamic>> testHistory;

  Patient({
    required this.id,
    required this.fullName,
    required this.age,
    required this.chamber,
    required this.diagnosis,
    required this.currentSmartGoal,
    this.icfCodes = "",
    this.irpTerm = "Короткостроковий (до 14 днів)",
    this.irpInterventions = "",
    List<Map<String, dynamic>>? testHistory,
  }) : this.testHistory = testHistory ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'age': age,
      'chamber': chamber,
      'diagnosis': diagnosis,
      'currentSmartGoal': currentSmartGoal,
      'icfCodes': icfCodes,
      'irpTerm': irpTerm,
      'irpInterventions': irpInterventions,
      'testHistory': testHistory,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      age: map['age'] ?? 0,
      chamber: map['chamber'] ?? '',
      diagnosis: map['diagnosis'] ?? '',
      currentSmartGoal: map['currentSmartGoal'] ?? '',
      icfCodes: map['icfCodes'] ?? '',
      irpTerm: map['irpTerm'] ?? 'Короткостроковий (до 14 днів)',
      irpInterventions: map['irpInterventions'] ?? '',
      testHistory: List<Map<String, dynamic>>.from(map['testHistory'] ?? []),
    );
  }

  // Автоматичне формування ІРП відповідно до клінічних протоколів МОЗ України
  static Map<String, String> generateAutoIRP(String diagnosis) {
    if (diagnosis.contains("I63") || diagnosis.contains("I61") || diagnosis.contains("Інсульт")) {
      return {
        "icf": "b730.2 (Порушення сили м'язів однієї половини тіла), d410 (Зміна положення тіла), d450 (Ходьба)",
        "goal": "Пацієнт зможе самостійно переміщатися з ліжка на крісло за допомогою опорної рами з мінімальною підтримкою протягом 5 хвилин до моменту виписки (14 днів).",
        "interventions": "1. Терапія положенням (протиспастичні укладки згідно з протоколом МОЗ).\n2. Кінезотерапія: відновлення контролю тулуба та балансу сидячи.\n3. Вправи на збільшення амплітуди пасивних та активних рухів.\n4. Вертикалізація пацієнта (поетапний ортостатичний тренінг)."
      };
    } else if (diagnosis.contains("S06") || diagnosis.contains("Травма")) {
      return {
        "icf": "b110 (Функції свідомості), b710 (Функції рухливості суглобів), d415 (Утримання положення тіла)",
        "goal": "Досягти стабільного утримання вертикального положення голови та контролю погляду сидячи в ліжку протягом 10 хвилин з контролем АТ.",
        "interventions": "1. Пасивна суглобова гімнастика для запобігання м'язових ретракцій.\n2. Ортостатичні тренування на ліжку-вертикалізаторі (кути 30°-45°-60°).\n3. Дихальна кінезотерапія: стимуляція відкашлювання, дренажні положення.\n4. Когнітивно-рухова активація за командами фізичного терапевта."
      };
    } else if (diagnosis.contains("G62") || diagnosis.contains("Слабість")) {
      return {
        "icf": "b730.3 (Генералізована слабкість м'язів), b440 (Функції дихання), d420 (Переміщення себе)",
        "goal": "Збільшити силу проксимальних груп м'язів до >= 3 балів за MRC-SumScore для можливості активного припіднімання у ліжку за 10 днів.",
        "interventions": "1. Ізометричні вправи для великих м'язових груп в межах ліжка.\n2. Активно-пасивні вправи з прогресуючим опором еластичних стрічок.\n3. Дихальна гімнастика з використанням методів позитивного тиску на видиху.\n4. Електроміостимуляція (ЕМС) чотириголових м'язів стегна."
      };
    } else {
      return {
        "icf": "b710 (Рухливість суглобів), d410 (Зміна положення)",
        "goal": "Забезпечити безпечне та самостійне виконання поворотів у ліжку без допомоги персоналу протягом 7 днів.",
        "interventions": "1. Функціональне тренування рухів у ліжку (повороти, міст).\n2. Дихальні та загальнозміцнюючі вправи згідно з загальним протоколом ранньої мобілізації МОЗ України.\n3. Пасивне розтягування м'язів-згиначів."
      };
    }
  }
}
