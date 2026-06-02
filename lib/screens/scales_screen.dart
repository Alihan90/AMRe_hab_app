import 'package:flutter/material.dart';

class ScalesScreen extends StatefulWidget {
  const ScalesScreen({super.key});

  @override
  State<ScalesScreen> createState() => _ScalesScreenState();
}

class _ScalesScreenState extends State<ScalesScreen> {
  // Змінні для збереження вибору лікаря
  double _imsScore = 0.0;
  int _mrcScore = 24; // Стартовий бал для прикладу

  // Список рівнів шкали IMS (Інтенсивна мобільність)
  final List<Map<String, dynamic>> _imsLevels = [
    {'level': 0.0, 'desc': 'Пасивне лежіння в ліжку (мобільність відсутня)'},
    {'level': 1.0, 'desc': 'Сидіння в ліжку, пасивні вправи'},
    {'level': 2.0, 'desc': 'Пересаджування в крісло за допомогою (2 особи)'},
    {'level': 3.0, 'desc': 'Сидіння на краю ліжка з підтримкою балансу'},
    {'level': 4.0, 'desc': 'Стояння біля ліжка з допомогою (1 особа)'},
    {'level': 5.0, 'desc': 'Ходьба на місці біля ліжка'},
    {'level': 7.0, 'desc': 'Самостійна ходьба по палаті (більше 5 метрів)'},
  ];

  @override
  Widget build(BuildContext context) {
    // Логіка червоного прапорця: якщо IMS дуже низький, виводимо попередження безпеки
    bool isAlertActive = _imsScore <= 1.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Оцінка Шкал & Безпека",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // БЛОК БЕЗПЕКИ (Червоний / Зелений прапорець)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAlertActive ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isAlertActive ? Colors.red : Colors.green,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isAlertActive ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    color: isAlertActive ? Colors.red : Colors.green,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAlertActive ? "КРИТИЧНИЙ РІВЕНЬ" : "БЕЗПЕЧНО ДЛЯ НАВАНТАЖЕНЬ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isAlertActive ? Colors.red.shade900 : Colors.green.shade900,
                          ),
                        ),
                        Text(
                          isAlertActive 
                            ? "Рівень мобільності 0-1. Дозволені тільки пасивні вправи, вертикалізація обмежена ліжком."
                            : "Пацієнт стабільний. Дозволена розширена активна кінезіотерапія та тренування балансу.",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ШКАЛА IMS
            const Text(
              "Шкала мобільності ВІТ (IMS)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: _imsLevels.map((item) {
                    return RadioListTile<double>(
                      title: Text("Поточний рівень: ${item['level']}"),
                      subtitle: Text(item['desc']),
                      value: item['level'],
                      groupValue: _imsScore,
                      onChanged: (value) {
                        setState(() {
                          _imsScore = value!;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ШКАЛА MRC
            const Text(
              "Сила м'язів (MRC-SumScore)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Загальний бал (0-60):", style: TextStyle(fontSize: 16)),
                        Text(
                          "$_mrcScore / 60", 
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    ),
                    Slider(
                      value: _mrcScore.toDouble(),
                      min: 0,
                      max: 60,
                      divisions: 60,
                      label: _mrcScore.toString(),
                      onChanged: (double value) {
                        setState(() {
                          _mrcScore = value.toInt();
                        });
                      },
                    ),
                    Text(
                      _mrcScore < 48 ? "🚨 Підозра на ПІТ-асоційовану м'язову слабкість" : "✅ Сила м'язів у межах норми",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _mrcScore < 48 ? Colors.orange.shade800 : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Кнопка збереження результатів
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Дані збережено! IMS: $_imsScore, MRC: $_mrcScore")),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Зберегти в історію пацієнта", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
