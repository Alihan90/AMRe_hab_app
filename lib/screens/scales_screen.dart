import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/patient.dart';

class ScalesScreen extends StatefulWidget {
  final Patient? patient; // Якщо null - відкривається як довідник
  const ScalesScreen({super.key, this.patient});

  @override
  State<ScalesScreen> createState() => _ScalesScreenState();
}

class _ScalesScreenState extends State<ScalesScreen> {
  // База шкал з детальними описами для лікаря (Чому і Як тестувати)
  final List<Map<String, dynamic>> _clinicalScales = [
    {
      "name": "MRC-SumScore",
      "why": "Оцінка загальної сили м'язів для виявлення набутої слабкості у відділенні інтенсивної терапії (ICUAW).",
      "how": "Тестується 6 м'язових груп симетрично з обох сторін (абдукція плеча, згинання передпліччя, розгинання кисті, згинання стегна, розгинання коліна, тильне згинання стопи). Кожна група оцінюється від 0 (немає скорочень) до 5 (нормальна сила). Максимум: 60 балів.",
      "maxScore": 60
    },
    {
      "name": "RASS (Шкала седації-ажитації Ричмонда)",
      "why": "Моніторинг рівня свідомості пацієнта перед початком та під час ранньої мобілізації для безпеки терапії.",
      "how": "Оцінка візуального контакту та реакції на вербальні/фізичні подразники. Оцінки варіюються від +4 (войовничий) через 0 (спокійний, уважний) до -5 (не реагує на жодні подразники).",
      "maxScore": 4
    },
    {
      "name": "Berg Balance Scale (BBS)",
      "why": "Визначення порушень статичного та динамічного балансу пацієнта перед вертикалізацією.",
      "how": "Оцінка виконання 14 функціональних завдань (сидіння без підтримки, пересадка, стояння з заплющеними очима тощо). Кожне завдання від 0 до 4 балів. Максимум: 56 балів.",
      "maxScore": 56
    }
  ];

  void _runScaleTest(Map<String, dynamic> scale) {
    if (widget.patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Цей режим є лише довідником. Оберіть пацієнта для проведення тесту.")));
      return;
    }

    final scoreCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Проведення тесту: ${scale['name']}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Опис тесту:\n${scale['how']}", style: const TextStyle(fontSize: 11, color: Colors.black87)),
            const SizedBox(height: 12),
            TextField(
              controller: scoreCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Введіть отриманий бал (макс: ${scale['maxScore']})"),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Скасувати")),
          ElevatedButton(
            onPressed: () async {
              final int? val = int.tryParse(scoreCtrl.text);
              if (val == null) return;

              final prefs = await SharedPreferences.getInstance();
              String key = "scale_history_${widget.patient!.id}";
              List<dynamic> history = [];
              
              String? existingData = prefs.getString(key);
              if (existingData != null) {
                history = json.decode(existingData);
              }

              history.add({
                "date": "${DateTime.now().day}.${DateTime.now().month}",
                "scale": scale['name'],
                "score": val
              });

              await prefs.setString(key, json.encode(history));
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Результат тесту успішно збережено в лог!")));
              }
            },
            child: const Text("Зберегти результат"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.patient == null ? "Клінічний довідник шкал" : "Тестування: ${widget.patient!.fullName}", style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _clinicalScales.length,
        itemBuilder: (context, index) {
          final scale = _clinicalScales[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.between,
                    children: [
                      Text(scale['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.purple)),
                      Icon(Icons.help_outline, size: 18, color: Colors.grey.shade600),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text("💡 НАВІЩО:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey.shade700)),
                  Text(scale['why'], style: const TextStyle(fontSize: 11, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text("📋 ЯК ПРОВОДИТИ:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blueGrey.shade700)),
                  Text(scale['how'], style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  const Divider(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                      onPressed: () => _runScaleTest(scale),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: Text(widget.patient == null ? "Переглянути структуру тесту" : "Запустити та зберегти тест"),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
