import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/patient.dart';

class ScaleMrcPage extends StatefulWidget {
  final Patient? patient;
  const ScaleMrcPage({super.key, this.patient});

  @override
  State<ScaleMrcPage> createState() => _ScaleMrcPageState();
}

class _ScaleMrcPageState extends State<ScaleMrcPage> {
  double _score = 48;

  Future<void> _saveResult() async {
    if (widget.patient == null) return;
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('patients_list');
    if (data != null) {
      List decoded = json.decode(data);
      List<Patient> list = decoded.map((p) => Patient.fromMap(p)).toList();
      int idx = list.indexWhere((p) => p.id == widget.patient!.id);
      if (idx != -1) {
        list[idx].mrcHistory.add(_score);
        widget.patient!.mrcHistory.add(_score);
      }
      await prefs.setString('patients_list', json.encode(list.map((p) => p.toMap()).toList()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Результат MRC-SumScore збережено!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.patient == null ? "Калькулятор MRC" : "Оцінка сили MRC", style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Сумарний бал MRC-SumScore", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Поточна оцінка: ${_score.toInt()} з 60 балів", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 16),
            if (_score < 48)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Text("⚠️ Бал < 48: Ознака синдрому ПІТ-асоційованої м'язової слабкості (ICU-AW).", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            const SizedBox(height: 24),
            const Text("Проведіть мануальне тестування 6 симетричних груп м'язів рук та ніг (від 0 до 5 балів кожна) та вкажіть суму:", style: TextStyle(color: Colors.grey)),
            Slider(
              value: _score,
              min: 0,
              max: 60,
              divisions: 60,
              label: _score.toInt().toString(),
              onChanged: (val) => setState(() => _score = val),
            ),
            const Spacer(),
            if (widget.patient != null)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)),
                  onPressed: _saveResult,
                  child: const Text("Зберегти у звіт пацієнта", style: TextStyle(color: Colors.white)),
                ),
              )
          ],
        ),
      ),
    );
  }
}
