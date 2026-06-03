import 'package:flutter/material.dart';
import '../models/scale_model.dart';

class TestExecutorScreen extends StatefulWidget {
  final ClinicalScale scale;

  const TestExecutorScreen({Key? key, required this.scale}) : super(key: key);

  @override
  State<TestExecutorScreen> createState() => _TestExecutorScreenState();
}

class _TestExecutorScreenState extends State<TestExecutorScreen> {
  // Зберігає вибрані відповіді: [id_питання: бал] або [id_поля: введене_значення]
  final Map<String, dynamic> _answers = {};

  @override
  void initState() {
    super.initState();
    // Ініціалізуємо дефолтні значення для шкал типу single_choice та multi_questions
    for (var question in widget.scale.questions) {
      if (question.options.isNotEmpty) {
        _answers[question.id] = question.options.first.score;
      }
    }
  }

  // Розрахунок загального результату
  int _calculateTotalScore() {
    int total = 0;
    if (widget.scale.testType == 'inputs') return 0; // Для числових тестів логіка інша
    
    _answers.forEach((key, value) {
      if (value is int) {
        total += value;
      }
    });
    return total;
  }

  // Автоматична клінічна інтерпретація результату згідно з вимогами МОЗ
  String _getInterpretation(int score) {
    switch (widget.scale.id) {
      case 'ims':
        if (score <= 2) return "Критично низька мобільність (ліжковий режим)";
        if (score <= 5) return "Помірна мобільність (межі палати з підтримкою)";
        return "Висока мобільність (активна локомоція)";
      case 'rass':
        if (score == 0) return "Норма (спокійний, уважний)";
        if (score > 0) return "Рівень ажитації/ризик зриву апаратури";
        return "Рівень седації/пригнічення свідомості";
      case 'vas':
        if (score <= 3) return "Слабкий біль (допускаються всі види вправ)";
        if (score <= 6) return "Помірний біль (потрібна обережність, корекція навантаження)";
        return "Інтенсивний біль (кінезотерапія обмежена, потрібна аналгезія)";
      case 'mrc':
        if (score < 48) return "Синдром ICUAW (набута слабкість м'язів у ВІТ)";
        return "Нормальна або мінімально знижена м'язова сила";
      case 'bbs':
        if (score <= 20) return "Високий ризик падіння (переміщення у кріслі колісному)";
        if (score <= 40) return "Помірний ризик падіння (ходьба з асистенцією/ходунками)";
        return "Низький ризик падіння (самостійна ходьба)";
      default:
        return "Тест завершено успішно. Результат внесено до бази даних.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scale.id.toUpperCase()),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Інформаційна плашка про шкалу у топі екрана
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            color: Colors.teal.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.scale.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
                ),
                const SizedBox(height: 4),
                Text("Область МКФ: ${widget.scale.icfCategory}", style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          
          // Тіло тесту з питаннями
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.scale.questions.length,
              itemBuilder: (context, qIndex) {
                final question = widget.scale.questions[qIndex];

                // Варіант 1: Поля введення (наприклад, для Ортостатичного тесту або 6MWT)
                if (widget.scale.testType == 'inputs') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: question.text,
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (val) {
                        _answers[question.id] = val;
                      },
                    ),
                  );
                }

                // Варіант 2: Радіокнопки (опитувальники з балами)
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.scale.testType == 'multi_questions')
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          question.text,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ...question.options.map((option) {
                      return RadioListTile<int>(
                        title: Text(option.text),
                        value: option.score,
                        groupValue: _answers[question.id],
                        activeColor: Colors.teal,
                        onChanged: (value) {
                          setState(() {
                            _answers[question.id] = value;
                          });
                        },
                      );
                    }).toList(),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
          
          // Нижня панель підрахунку результату
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5)],
            ),
            child: Row(
              children: [
                if (widget.scale.testType != 'inputs')
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Всього балів: ${_calculateTotalScore()}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        Text(
                          _getInterpretation(_calculateTotalScore()),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ElevatedButton(
                  onPressed: () {
                    // Формуємо фінальний мап тесту для збереження пацієнту
                    final testResult = {
                      'scaleId': widget.scale.id,
                      'date': DateTime.now().toIso8601String().substring(0, 10),
                      'score': widget.scale.testType != 'inputs' ? _calculateTotalScore() : 0,
                      'interpretation': widget.scale.testType != 'inputs' 
                          ? _getInterpretation(_calculateTotalScore())
                          : "Внесені дані: ${_answers.values.join(', ')}"
                    };
                    
                    // Повертаємо результат на попередній екран
                    Navigator.pop(context, testResult);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text("Зберегти", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
