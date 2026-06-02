class Patient {
  String id;
  String fullName;
  String birthDate;
  String icdCode;
  String icdDiagnosis;
  
  // Історія тестувань для побудови графіків динаміки у ВІТ
  List<double> imsHistory; // Рівні мобільності, наприклад: [0.0, 1.0, 2.0, 3.0]
  List<int> mrcHistory;    // Бали сили м'язів, наприклад: [24, 36, 48, 52]
  List<DateTime> sessionDates; // Дати оглядів

  String smartGoal;

  Patient({
    required this.id,
    required this.fullName,
    required this.birthDate,
    required this.icdCode,
    required this.icdDiagnosis,
    required this.imsHistory,
    required this.mrcHistory,
    required this.sessionDates,
    this.smartGoal = "",
  });

  // Шаблон пацієнта для демонстрації інтерфейсу та тестів
  static Patient get mockPatient => Patient(
    id: "1",
    fullName: "Коваленко Олександр Петрович",
    birthDate: "14.05.1972",
    icdCode: "I63.3",
    icdDiagnosis: "Ішемічний інсульт з лівобічним геміпарезом",
    imsHistory: [0.0, 1.0, 2.0, 2.0, 3.0],
    mrcHistory: [24, 30, 42, 44, 50],
    sessionDates: [
      DateTime.now().subtract(const Duration(days: 4)),
      DateTime.now().subtract(const Duration(days: 3)),
      DateTime.now().subtract(const Duration(days: 2)),
      DateTime.now().subtract(const Duration(days: 1)),
      DateTime.now(),
    ],
    smartGoal: "Пацієнт зможе самостійно переходити в положення сидіння на краю ліжка з утриманням балансу протягом 5 хвилин без підтримки до кінця тижня.",
  );
}
