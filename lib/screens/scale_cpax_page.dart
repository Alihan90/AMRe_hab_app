import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/patient.dart';

class ScaleCpaxPage extends StatefulWidget {
  final Patient? patient;
  const ScaleCpaxPage({super.key, this.patient});
  @override
  State<ScaleCpaxPage> createState() => _ScaleCpaxPageState();
}
class _ScaleCpaxPageState extends State<ScaleCpaxPage> {
  double _score = 25;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF1E293B), title: const Text("Профіль мобільності CPAX")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Сумарний бал індексу CPAX (0-50 балів)", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("${_score.toInt()} балів", style: const TextStyle(fontSize: 32, color: Colors.green, fontWeight: FontWeight.bold)),
            Slider(value: _score, min: 0, max: 50, divisions: 50, label: _score.toInt().toString(), onChanged: (v) => setState(() => _score = v)),
            const Text("Оцінює 10 параметрів (дихальна функція, тонус, баланс на ліжку, переміщення, сила хвату)."),
            const Spacer(),
            if (widget.patient != null)
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)), onPressed: () => Navigator.pop(context), child: const Text("Зберегти вимір", style: TextStyle(color: Colors.white)))
          ],
        ),
      ),
    );
  }
}
