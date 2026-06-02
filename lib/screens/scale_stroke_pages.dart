import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/patient.dart';

class NeuroScalePage extends StatefulWidget {
  final String type; // MoCA, Rancho, Rivermead, Berg, Ashworth
  final Patient? patient;
  const NeuroScalePage({super.key, required this.type, this.patient});

  @override
  State<NeuroScalePage> createState() => _NeuroScalePageState();
}

class _NeuroScalePageState extends State<NeuroScalePage> {
  double _score = 0;
  String _selectedRank = "0";

  final List<String> _ranchoLevels = [
    "I рівень - Повна відсутність реакцій (сон, комітозний стан)",
    "II рівень - Генералізована реакція (неспецифічний рух на біль)",
    "III рівень - Локалізована реакція (повертає голову на звук, стискає руку)",
    "IV рівень - Збуджено-агресивний стан (неадекватна поведінка, відсутність кооперації)",
    "V рівень - Неадекватний, незбуджений стан (сплутаний мовний контакт)",
    "VI рівень - Адекватний, сплутаний стан (виконує прості інструкції)",
    "VII рівень - Адекватний, автоматизований стан (побутовий автопілот)",
    "VIII рівень - Адекватний, інтегрований стан (усвідомлена робота з реабілітологом)"
  ];

  final List<String> _ashworthLevels = [
    "0 - Нормальний тонус (немає підвищення опору пасивним рухам)",
    "1 - Незначне підвищення тонусу (ефект клямки наприкінці амплітуди)",
    "1+ - Легке підвищення тонусу (мінімальний опір у меншій половині амплітуди)",
    "2 - Помірне підвищення тонусу (протягом усього руху, але суглоб легко згинається)",
    "3 - Виражене підвищення тонусу (пасивний рух утруднений)",
    "4 - Контрактура (уражена частина зафіксована у згинанні/розгинанні)"
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
        String dataString = widget.type == "Rancho" ? _ranchoLevels[_score.toInt()] : (widget.type == "Ashworth" ? _selectedRank : "${_score.toInt()} балів");
        String finalLog = "⚡ Шкала ${widget.type}: $dataString (${DateTime.now().day}.${DateTime.now().month})\n";
        list[idx].currentSmartGoal = finalLog + list[idx].currentSmartGoal;
        widget.patient!.currentSmartGoal = finalLog + widget.patient!.currentSmartGoal;
      }
      await prefs.setString('patients_list', json.encode(list.map((p) => p.toMap()).toList()));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Результат оцінки ${widget.type} інтегровано в картку!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF1E293B), title: Text("Шкала: ${widget.type}", style: const TextStyle(color: Colors.white, fontSize: 16))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.type == "MoCA") ...[
              const Text("Монреальська шкала когніцій (MoCA)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Text("Сума: ${_score.toInt()} з 30 балів", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
              Slider(value: _score, min: 0, max: 30, divisions: 30, label: _score.toInt().toString(), onChanged: (v) => setState(() => _score = v)),
              Text(_score < 26 ? "⚠️ Наявність когнітивних порушень. Потрібні спрощені команди реабілітолога." : "✅ Когнітивна сфера збережена.", style: const TextStyle(color: Colors.black54))
            ],
            if (widget.type == "Rivermead") ...[
              const Text("Індекс мобільності Рівермід (RMI)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Text("Поточна оцінка: ${_score.toInt()} з 15 балів", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
              Slider(value: _score, min: 0, max: 15, divisions: 15, label: _score.toInt().toString(), onChanged: (v) => setState(() => _score = v)),
              const Text("Відображає здатність пацієнта до базових переміщень у просторі (повороти, вставання, ходьба сходами).", style: TextStyle(color: Colors.black45, fontSize: 12))
            ],
            if (widget.type == "Berg") ...[
              const Text("Шкала балансу Берга (BBS)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              Text("Оцінка рівноваги: ${_score.toInt()} з 56 балів", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
              Slider(value: _score, min: 0, max: 56, divisions: 56, label: _score.toInt().toString(), onChanged: (v) => setState(() => _score = v)),
              Text(_score <= 20 ? "🚨 Високий ризик падіння! Пацієнт потребує тотальної страховки." : (_score <= 40 ? "⚠️ Середній ризик падіння." : "✅ Низький ризик падіння."), style: const TextStyle(fontWeight: FontWeight.bold))
            ],
            if (widget.type == "Rancho") ...[
              const Text("Рівні когнітивного відновлення Rancho Los Amigos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _ranchoLevels.length,
                  itemBuilder: (c, i) => RadioListTile<double>(
                    title: Text(_ranchoLevels[i], style: const TextStyle(fontSize: 13)),
                    value: i.toDouble(), groupValue: _score, onChanged: (v) => setState(() => _score = v!),
                  ),
                ),
              )
            ],
            if (widget.type == "Ashworth") ...[
              const Text("Оцінка спастичності за Ashworth (MAS)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: _ashworthLevels.length,
                  itemBuilder: (c, i) => RadioListTile<String>(
                    title: Text(_ashworthLevels[i], style: const TextStyle(fontSize: 13)),
                    value: _ashworthLevels[i].split(" ")[0], groupValue: _selectedRank, onChanged: (v) => setState(() => _selectedRank = v!),
                  ),
                ),
              )
            ],
            const Spacer(),
            if (widget.patient != null)
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B)), onPressed: _saveResult, child: const Text("Внести оцінку в аналітику пацієнта", style: TextStyle(color: Colors.white)))),
          ],
        ),
      ),
    );
  }
}
