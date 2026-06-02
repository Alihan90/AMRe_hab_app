import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/patient.dart';

class ScaleImsPage extends StatefulWidget {
  final Patient? patient;
  const ScaleImsPage({super.key, this.patient});

  @override
  State<ScaleImsPage> createState() => _ScaleImsPageState();
}

class _ScaleImsPageState extends State<ScaleImsPage> {
  double _score = 0;

  final List<String> _labels = [
    "0 - Пасивне ліжіння в ліжку (без активних рухів)",
    "1 - Пасивне сидіння в ліжку / дихальна гімнастика",
    "2 - Активне сидіння в ліжку, рухи ногами в межах ліжка",
    "3 - Сидіння на краю ліжка з утриманням балансу кору",
    "4 - Вставання з ліжка / стояння з підтримкою (мінімум 1 особа)",
    "5 - Пересаджування з ліжка у крісло без опори на ноги",
    "6 - Ходьба на місці біля ліжка зі страховою підтримкою",
    "7 - Самостійна ходьба по палаті (мінімум 5-10 метрів)"
  ];

  Future<void> _saveResult() async {
    if (widget.patient == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('patients_list');
    if (data != null) {
      List decoded = json.decode(data);
      List<Patient> list = decoded.map((p) => Patient.fromMap(p)).toList();
      int idx = list.indexWhere((p) => p.id == widget.patient!.id);
      if (idx != -1) {
        list[idx].imsHistory.add(_score);
        list[idx].sessionDates.add(DateTime.now());
        widget.patient!.imsHistory.add(_score);
        widget.patient!.sessionDates.add(DateTime.now());
      }
      await prefs.setString('patients_list', json.encode(list.map((p) => p.toMap()).toList()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Результат IMS успішно додано до картки пацієнта!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.patient == null ? "Калькулятор IMS" : "Тестування IMS", style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _score <= 1 ? Colors.red.shade50 : Colors.green.shade50,
            child: Text(
              _score <= 1 ? "⚠️ Критичний рівень мобільності. Тільки пасивні протоколи." : "✅ Дозволена активна кінезіотерапія та вертикалізація.",
              style: TextStyle(fontWeight: FontWeight.bold, color: _score <= 1 ? Colors.red.shade900 : Colors.green.shade900),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _labels.length,
              itemBuilder: (context, index) {
                return RadioListTile<double>(
                  title: Text(_labels[index], style: const TextStyle(fontSize: 14)),
                  value: index.toDouble(),
                  groupValue: _score,
                  onChanged: (val) => setState(() => _score = val!),
                );
              },
            ),
          ),
          if (widget.patient != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                  onPressed: _saveResult,
                  child: const Text("Зберегти вимір в аналітику", style: TextStyle(color: Colors.white)),
                ),
              ),
            )
        ],
      ),
    );
  }
}
