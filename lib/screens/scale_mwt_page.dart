import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/patient.dart';

class ScaleMwtPage extends StatefulWidget {
  final Patient? patient;
  const ScaleMwtPage({super.key, this.patient});

  @override
  State<ScaleMwtPage> createState() => _ScaleMwtPageState();
}

class _ScaleMwtPageState extends State<ScaleMwtPage> {
  final _distanceCtrl = TextEditingController(text: "250");
  final _weightCtrl = TextEditingController(text: "75");
  final _heightCtrl = TextEditingController(text: "172");
  final _ageCtrl = TextEditingController(text: "60");
  
  String _gender = "Чоловік";
  double _borgBefore = 0;
  double _borgAfter = 0;
  String _calculationResult = "";

  final List<Map<String, dynamic>> _borgScale = [
    {"val": 0.0, "txt": "0 - Взагалі не відчується (Спокій)"},
    {"val": 0.5, "txt": "0.5 - Дуже-дуже легка (Ледве помітна)"},
    {"val": 1.0, "txt": "1 - Дуже легка задишка"},
    {"val": 2.0, "txt": "2 - Легка задишка"},
    {"val": 3.0, "txt": "3 - Помірна (Дихання прискорене)"},
    {"val": 4.0, "txt": "4 - Досить важка задишка"},
    {"val": 5.0, "txt": "5 - Важка задишка"},
    {"val": 7.0, "txt": "7 - Дуже важка задишка"},
    {"val": 10.0, "txt": "10 - Максимальна, гранична задишка"}
  ];

  void _calculateEnright() {
    double distance = double.tryParse(_distanceCtrl.text) ?? 0;
    double weight = double.tryParse(_weightCtrl.text) ?? 0;
    double height = double.tryParse(_heightCtrl.text) ?? 0;
    double age = double.tryParse(_ageCtrl.text) ?? 0;

    if (weight == 0 || height == 0 || age == 0) return;

    double predicted = 0;
    if (_gender == "Чоловік") {
      predicted = (7.57 * height) - (5.02 * age) - (1.76 * weight) - 309;
    } else {
      predicted = (2.11 * height) - (2.29 * age) - (0.78 * weight) + 667;
    }

    double percent = (distance / predicted) * 100;

    setState(() {
      _calculationResult = "Належна відстань (Enright): ${predicted.toStringAsFixed(1)} м.\n"
          "Виконано: ${percent.toStringAsFixed(1)}% від норми.\n"
          "Динаміка задишки (Борг): ${_borgBefore.toString()} -> ${_borgAfter.toString()}";
    });
  }

  Future<void> _saveResult() async {
    if (widget.patient == null || _calculationResult.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('patients_list');
    if (data != null) {
      List decoded = json.decode(data);
      List<Patient> list = decoded.map((p) => Patient.fromMap(p)).toList();
      int idx = list.indexWhere((p) => p.id == widget.patient!.id);
      if (idx != -1) {
        list[idx].currentSmartGoal = "📋 Тест 6MWT:\n$_calculationResult\n\n${list[idx].currentSmartGoal}";
        widget.patient!.currentSmartGoal = "📋 Тест 6MWT:\n$_calculationResult\n\n${widget.patient!.currentSmartGoal}";
      }
      await prefs.setString('patients_list', json.encode(list.map((p) => p.toMap()).toList()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Результати 6MWT+Борг внесено в історію!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF1E293B), title: const Text("Тест 6MWT та шкала Борга", style: TextStyle(color: Colors.white, fontSize: 16))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _gender,
              items: ["Чоловік", "Жінка"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _gender = v!),
              decoration: const InputDecoration(labelText: "Стать пацієнта"),
            ),
            Row(
              children: [
                Expanded(child: TextField(controller: _ageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Вік (років)"))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _heightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Зріст (см)"))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Вага (кг)"))),
              ],
            ),
            TextField(controller: _distanceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Пройдена дистанція за 6 хв (метрів)", labelStyle: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 16),
            const Text("Модифікована шкала Борга (Задишка ДО тесту):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            DropdownButton<double>(
              value: _borgBefore,
              isExpanded: true,
              items: _borgScale.map((b) => DropdownMenuItem<double>(value: b["val"], child: Text(b["txt"]))).toList(),
              onChanged: (v) => setState(() => _borgBefore = v!),
            ),
            const SizedBox(height: 10),
            const Text("Модифікована шкала Борга (Задишка ПІСЛЯ тесту):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            DropdownButton<double>(
              value: _borgAfter,
              isExpanded: true,
              items: _borgScale.map((b) => DropdownMenuItem<double>(value: b["val"], child: Text(b["txt"]))).toList(),
              onChanged: (v) => setState(() => _borgAfter = v!),
            ),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey), onPressed: _calculateEnright, child: const Text("Розрахувати показники за Enright", style: TextStyle(color: Colors.white)))),
            if (_calculationResult.isNotEmpty) ...[
              const SizedBox(height: 15),
              Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: Text(_calculationResult, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue))),
            ],
            const SizedBox(height: 20),
            if (widget.patient != null)
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)), onPressed: _saveResult, child: const Text("Зберегти вимір в картку пацієнта", style: TextStyle(color: Colors.white)))),
          ],
        ),
      ),
    );
  }
}
