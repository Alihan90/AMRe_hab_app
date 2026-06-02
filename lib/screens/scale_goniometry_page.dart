import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/patient.dart';

class ScaleGoniometryPage extends StatefulWidget {
  final Patient? patient;
  const ScaleGoniometryPage({super.key, this.patient});

  @override
  State<ScaleGoniometryPage> createState() => _ScaleGoniometryPageState();
}

class _ScaleGoniometryPageState extends State<ScaleGoniometryPage> {
  // База даних суглобів із анатомічними нормами
  final List<Map<String, dynamic>> _joints = [
    {
      "name": "Плечовий суглоб (Згинання)",
      "norm": "0° – 180°",
      "max": 180,
      "left": 180.0,
      "right": 180.0
    },
    {
      "name": "Плечовий суглоб (Відведення)",
      "norm": "0° – 180°",
      "max": 180,
      "left": 180.0,
      "right": 180.0
    },
    {
      "name": "Ліктьовий суглоб (Згинання)",
      "norm": "0° – 150°",
      "max": 150,
      "left": 150.0,
      "right": 150.0
    },
    {
      "name": "Променево-зап'ястковий (Згинання)",
      "norm": "0° – 80°",
      "max": 80,
      "left": 80.0,
      "right": 80.0
    },
    {
      "name": "Кульшовий суглоб (Згинання)",
      "norm": "0° – 120°",
      "max": 120,
      "left": 120.0,
      "right": 120.0
    },
    {
      "name": "Колінний суглоб (Згинання)",
      "norm": "0° – 135°",
      "max": 135,
      "left": 135.0,
      "right": 135.0
    },
    {
      "name": "Гомілковостопний (Тильне згинання)",
      "norm": "0° – 20°",
      "max": 20,
      "left": 20.0,
      "right": 20.0
    },
    {
      "name": "Гомілковостопний (Підошовне зг.)",
      "norm": "0° – 50°",
      "max": 50,
      "left": 50.0,
      "right": 50.0
    },
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
        // Формуємо красивий протокол гоніометрії для вклеювання в картку
        String report = "📐 Протокол гоніометрії від ${DateTime.now().day}.${DateTime.now().month}:\n";
        for (var joint in _joints) {
          report += "• ${joint['name']} (Норма: ${joint['norm']}): Ліва: ${joint['left'].toInt()}°, Права: ${joint['right'].toInt()}°\n";
        }
        report += "\n";
        
        // Записуємо в історію/цілі пацієнта
        list[idx].currentSmartGoal = report + list[idx].currentSmartGoal;
        widget.patient!.currentSmartGoal = report + widget.patient!.currentSmartGoal;
      }
      await prefs.setString('patients_list', json.encode(list.map((p) => p.toMap()).toList()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Дані гоніометрії збережено в історію хвороби!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.patient == null ? "Інтерактивна Гоніометрія" : "Гоніометрія: ${widget.patient!.fullName}", style: const TextStyle(color: Colors.white, fontSize: 15)),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Вкажіть реальну амплітуду рухів (ROM) за допомогою повзунків для лівої та правої кінцівок.",
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _joints.length,
              itemBuilder: (context, index) {
                final joint = _joints[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(joint["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                              child: Text("Норма: ${joint['norm']}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text("Л", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                            Expanded(
                              child: Slider(
                                value: joint["left"],
                                min: 0,
                                max: joint["max"].toDouble(),
                                divisions: joint["max"],
                                activeColor: Colors.red.shade400,
                                label: "${joint['left'].toInt()}°",
                                onChanged: (v) => setState(() => joint["left"] = v),
                              ),
                            ),
                            Text("${joint['left'].toInt()}°", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            const Text("П", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                            Expanded(
                              child: Slider(
                                value: joint["right"],
                                min: 0,
                                max: joint["max"].toDouble(),
                                divisions: joint["max"],
                                activeColor: Colors.green.shade400,
                                label: "${joint['right'].toInt()}°",
                                onChanged: (v) => setState(() => joint["right"] = v),
                              ),
                            ),
                            Text("${joint['right'].toInt()}°", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
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
                  child: const Text("Зберегти кути в карту пацієнта", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
