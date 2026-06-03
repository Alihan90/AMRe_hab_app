class ScaleQuestion {
  final String id;
  final String text; // Текст конкретного питання (напр. "Повороти в ліжку")
  final List<ScaleOption> options; // Варіанти відповідей з балами

  ScaleQuestion({
    required this.id,
    required this.text,
    required this.options,
  });
}

class ScaleOption {
  final int score;
  final String text; // Напр. "0 - Потребує повної допомоги"

  ScaleOption({required this.score, required this.text});
}

class ClinicalScale {
  final String id;
  final String name;
  final String instruction; // Навіщо і як проводити за протоколом МОЗ
  final String icfCategory; // Зв'язок з кодом МКФ (напр. b730, d450)
  final String testType; // 'single_choice' (радіо), 'multi_questions' (опитувальник), 'inputs' (введення цифр)
  final List<ScaleQuestion> questions;

  ClinicalScale({
    required this.id,
    required this.name,
    required this.instruction,
    required this.icfCategory,
    required this.testType,
    required this.questions,
  });
}
