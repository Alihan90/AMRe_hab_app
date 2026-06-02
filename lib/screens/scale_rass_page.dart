import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/patient.dart';

class ScaleRassPage extends StatefulWidget {
  final Patient? patient;
  const ScaleRassPage({super.key, this.patient});

  @override
  State<ScaleRassPage> createState() => _ScaleRassPageState();
}

class _ScaleRassPageState extends State<ScaleRassPage> {
  int _score = 0;

  final List<Map<String, dynamic>> _rassItems = [
    {"score": 4, "title": "+4 Агресивний", "desc": "Явна агресія, небезпека для персоналу, пацієнт видаляє катетери/трубки."},
    {"score": 3, "title": "+3 Дуже збуджений", "desc": "Часті хаотичні рухи, агресія на апарат ШВЛ."},
    {"score": 2, "title": "+2 Збуджений", "desc": "Некоординовані рухи, намагається сісти, але підкоряється командам."},
    {"score": 1, "title": "+1 Неспокійний", "desc": "Тривожний, але рухи не агресивні та не хаотичні."},
    {"score": 0, "title": "0 Спокійний, уважний", "desc": "Нормальний стан неспання, адекватно реагує на оточення."},
    {"score": -1, "title": "-1 Сонливий", "desc": "Прокидається від голосу, тримає зоровий контакт більше 10 секунд."},
    {"score": -2, "title": "-2 Легка седація", "desc": "Прокидається від голосу, але зоровий контакт триває менше 10 секунд."},
    {"score": -3, "title": "-3 Помірна седація", "desc": "Реагує рухом або відкриттям очей на голос, але без зорового контакту."},
    {"score": -4, "title": "-4 Глибока седація", "desc": "Не реагує на голос, але відкриває очі/рухається при фізичній стимуляції."},
    {"score": -5, "title": "-5 Без свідомості (Кома)", "desc": "Повна відсутність реакцій на голос та фізичну стимуляцію."},
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
        String levelText = _rassItems.firstWhere((item) => item["score"] == _score)["title"];
        list[idx].currentSmartGoal = "🧠 Шкала RASS: Бал $_score ($levelText) від ${DateTime.now().day}.${DateTime.now().month}\n\n${list[idx].currentSmartGoal}";
        widget.patient!.currentSmartGoal = "🧠 Шкала RASS: Бал $_score ($levelText) від ${DateTime.now().day}.${DateTime.now().month}\n\n${widget.patient!.currentSmartGoal}";
      }
      await prefs.setString('patients_list', json.encode(list.map((p) => p.toMap()).toList()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Результат RASS збережено в аналітику пацієнта!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.patient == null ? "Калькулятор RASS" : "RASS: ${widget.patient!.fullName}", style: const TextStyle(color: Colors.white, fontSize: 15)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.purple.shade50,
            width: double.infinity,
            child: Text(
              "Поточний вибір: Бал $_score",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _rassItems.length,
              itemBuilder: (context, index) {
                final item = _rassItems[index];
                bool isSelected = _score == item["score"];
                return Card(
                  color: isSelected ? Colors.purple.shade100 : Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    title: Text(item["title"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(item["desc"], style: const TextStyle(fontSize: 12)),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.purple) : null,
                    onTap: () => setState(() => _score = item["score"]),
                  ),
                );
              },
            ),
          ),
          if (widget.patient != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                  onPressed: _saveResult,
                  child: const Text("Зберегти показник у картку", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
