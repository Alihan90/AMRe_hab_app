import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/patient.dart';

class SmartGoalScreen extends StatefulWidget {
  final Patient patient;
  const SmartGoalScreen({super.key, required this.patient});

  @override
  State<SmartGoalScreen> createState() => _SmartGoalScreenState();
}

class _SmartGoalScreenState extends State<SmartGoalScreen> {
  String _specific = "самостійно переходити в положення сидіння на краю ліжка";
  String _measurable = "з утриманням балансу протягом 5 хвилин";
  String _achievable = "без підтримки рук та допомоги персоналу";
  String _relevant = "для підготовки до подальшого вставання та ходьби";
  String _timeBound = "до кінця поточного тижня (за 5 днів)";

  late TextEditingController _resultController;

  @override
  void initState() {
    super.initState();
    _resultController = TextEditingController(text: _generateGoalText());
  }

  String _generateGoalText() => "Пацієнт зможе $_specific, $_measurable, $_achievable, $_relevant, $_timeBound.";
  void _updateResult() => _resultController.text = _generateGoalText();

  Future<void> _saveGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('patients_list');
    if (data != null) {
      List decoded = json.decode(data);
      List<Patient> list = decoded.map((p) => Patient.fromMap(p)).toList();
      
      int idx = list.indexWhere((p) => p.id == widget.patient.id);
      if (idx != -1) {
        list[idx].currentSmartGoal = _resultController.text;
        widget.patient.currentSmartGoal = _resultController.text;
      }
      
      await prefs.setString('patients_list', json.encode(list.map((p) => p.toMap()).toList()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ціль записана в карту пацієнта!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF1E293B), iconTheme: const IconThemeData(color: Colors.white), title: const Text("SMART Майстер цілей", style: TextStyle(color: Colors.white))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDropdown("Що робити? (Specific)", _specific, ["самостійно переходити в положення сидіння на краю ліжка", "самостійно пересаджуватися з ліжка у крісло-коляску", "зробити 10 кроків по палаті з чотириопорною палицею"], (val) => setState(() { _specific = val!; _updateResult(); })),
            _buildDropdown("Скільки? (Measurable)", _measurable, ["з утриманням балансу протягом 5 хвилин", "протягом 1 хвилини без запаморочення", "на відстань до 5 метрів"], (val) => setState(() { _measurable = val!; _updateResult(); })),
            _buildDropdown("Які умови? (Achievable)", _achievable, ["без підтримки рук та допомоги персоналу", "за допомогою однієї особи (страховка)", "з опорою на високі ходунки"], (val) => setState(() { _achievable = val!; _updateResult(); })),
            _buildDropdown("Навіщо? (Relevant)", _relevant, ["для підготовки до подальшого вставання та ходьби", "для відновлення навичок самообслуговування (прийом їжі)", "для можливості самостійного відвідування туалету"], (val) => setState(() { _relevant = val!; _updateResult(); })),
            _buildDropdown("Коли? (Time-bound)", _timeBound, ["до кінця поточного тижня (за 5 днів)", "через 3 дні регулярних тренувань", "наприкінці сьогоднішнього заняття"], (val) => setState(() { _timeBound = val!; _updateResult(); })),
            const Divider(),
            TextField(controller: _resultController, maxLines: 3, decoration: const InputDecoration(labelText: "Фінальна ціль", border: OutlineInputBorder())),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.purple), onPressed: _saveGoal, child: const Text("Затвердити ціль", style: TextStyle(color: Colors.white))))
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), DropdownButton<String>(value: value, isExpanded: true, items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 13)))).toList(), onChanged: onChanged), const SizedBox(height: 12)]);
  }
}
