import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/patient.dart';

class ScaleCpotPage extends StatefulWidget {
  final Patient? patient;
  const ScaleCpotPage({super.key, this.patient});
  @override
  State<ScaleCpotPage> createState() => _ScaleCpotPageState();
}
class _ScaleCpotPageState extends State<ScaleCpotPage> {
  double _score = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF1E293B), title: const Text("Оцінка болю CPOT")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Показник болю за шкалою CPOT (0-8 балів)", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("${_score.toInt()} балів", style: const TextStyle(fontSize: 32, color: Colors.red, fontWeight: FontWeight.bold)),
            Slider(value: _score, min: 0, max: 8, divisions: 8, label: _score.toInt().toString(), onChanged: (v) => setState(() => _score = v)),
            Text(_score >= 3 ? "🚨 Пацієнт відчуває виражений біль! Потрібна аналгезія перед кінезіотерапією." : "✅ Рівень болю прийнятний для початку терапії."),
            const Spacer(),
            if (widget.patient != null)
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)), onPressed: () => Navigator.pop(context), child: const Text("Зберегти вимір", style: TextStyle(color: Colors.white)))
          ],
        ),
      ),
    );
  }
}
