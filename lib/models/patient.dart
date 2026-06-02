import 'dart:convert';

class Patient {
  String id;
  String fullName;
  String age;
  String roomNumber;
  String icdDiagnosis;
  
  // Історія оцінок для графіків
  List<double> mrcHistory;
  List<double> imsHistory;
  List<DateTime> sessionDates;
  
  // Актуальні цілі та нотатки
  String currentSmartGoal;

  Patient({
    required this.id,
    required this.fullName,
    required this.age,
    required this.roomNumber,
    required this.icdDiagnosis,
    required this.mrcHistory,
    required this.imsHistory,
    required this.sessionDates,
    this.currentSmartGoal = "",
  });

  // Конвертуємо в JSON для збереження в пам'ять телефона
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'age': age,
      'roomNumber': roomNumber,
      'icdDiagnosis': icdDiagnosis,
      'mrcHistory': mrcHistory,
      'imsHistory': imsHistory,
      'sessionDates': sessionDates.map((d) => d.toIso8601String()).toList(),
      'currentSmartGoal': currentSmartGoal,
    };
  }

  // Відновлюємо пацієнта з пам'яті телефона
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] ?? '',
      fullName: map['fullName'] ?? '',
      age: map['age'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      icdDiagnosis: map['icdDiagnosis'] ?? '',
      mrcHistory: List<double>.from(map['mrcHistory'] ?? []),
      imsHistory: List<double>.from(map['imsHistory'] ?? []),
      sessionDates: (map['sessionDates'] as List? ?? [])
          .map((d) => DateTime.parse(d))
          .toList(),
      currentSmartGoal: map['currentSmartGoal'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());
  factory Patient.fromJson(String source) => Patient.fromMap(json.decode(source));
}
