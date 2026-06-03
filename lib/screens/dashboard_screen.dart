import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/patient.dart';
import 'scales_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Patient patient;
  const DashboardScreen({super.key, required this.patient});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _scaleLogs = [];

  @override
  void initState() {
    super.initState();
    _loadScaleLogs();
  }

  Future<void> _loadScaleLogs() async {
    final prefs = await SharedPreferences.getInstance();
    String key = "scale_history_${widget.patient.id}";
    String? existingData = prefs.getString(key);
    if (existingData != null) {
      setState(() {
        _scaleLogs = json.decode(existingData);
      });
    } else {
      // Базовий початковий лог, якщо тестів ще не було
      setState(() {
        _scaleLogs = [
          {"date": "01.06", "scale": "MRC-SumScore", "score": 24},
          {"date": "02.06", "scale": "RASS", "score": -3}
        ];
      });
    }
  }

  void _shareFullDischargeSummary() {
    final Map<String, dynamic> pMap = widget.patient.toMap();
    final String chamber = pMap['chamber'] ?? 'ВІТ';
    final String diagnosis = pMap['diagnosis'] ?? 'Не вказано';
    final String goal = widget.patient.currentSmartGoal;

    String exercisePlan = "";
    if (diagnosis.contains("I63") || diagnosis.contains("I61")) {
      exercisePlan = "1. Раннє висаджування з підтримкою.\n2. Антиспастичні укладки.\n3. Сенсорна дзеркальна активація.";
    } else if (diagnosis.contains("S06")) {
      exercisePlan = "1. Ортостатичний тренінг (ліжко-вертикалізатор).\n2. Контроль м'язового тонусу та фіксації погляду.\n3. Вправи для шийного відділу.";
    } else {
      exercisePlan = "1. Активно-пасивна гімнастика в межах ліжка.\n2. Дихальні техніки з опором (PEP-терапія).\n3. Електроміостимуляція.";
    }

    String scaleHistoryText = "";
    for (var log in _scaleLogs) {
      scaleHistoryText += "• [${log['date']}] ${log['scale']}: ${log['score']} балів\n";
    }

    final String document = """
🏥 ВІДДІЛЕННЯ РАННЬОЇ РЕАБІЛІТАЦІЇ ВІТ
=============================================
ВИПИСНА КАРТА ПАЦІЄНТА / РЕАБІЛІТАЦІЙНИЙ ЗВІТ
=============================================
Пацієнт: ${widget.patient.fullName}
Вік: ${widget.patient.age} р.      Локація: $chamber
Діагноз за МКХ-10: $diagnosis

---------------------------------------------
🎯 ЗАТВЕРДЖЕНА КЛІНІЧНА SMART-ЦІЛЬ:
$goal

---------------------------------------------
📈 ДИНАМІКА ОЦІНОК ШКАЛ (ЗБЕРЕЖЕНІ ЛОГИ):
$scaleHistoryText
---------------------------------------------
🏋️‍♂️ АВТОМАТИЧНО ПІДІБРАНИЙ ПЛАН ВПРАВ:
$exercisePlan

=============================================
Висновок сформовано автоматично у додатку.
Дата: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}
Фізичний терапевт: ____________________
""";

    Share.share(document, subject: 'Виписна карта ВІТ - ${widget.patient.fullName}');
  }

  void _showAutoExerciseProtocol(BuildContext context, String diagnosis) {
    String title = "Протокол фізичної реабілітації";
    List<String> steps = [];

    if (diagnosis.contains("I63") || diagnosis.contains("I61")) {
      title = "🧠 Авто-Протокол: Гострий Інсульт";
      steps = [
        "Циклічні пасивні та активні рухи в суглобах уражених кінцівок для профілактики контрактур.",
        "Терапія положенням: укладка паралізованої руки та ноги проти типової спастичної позиції.",
        "Вправи на стабілізацію кору та висаджування на край ліжка з підтримкою терапевта."
      ];
    } else if (diagnosis.contains("S06")) {
      title = "💥 Авто-Протокол: Тяжка ЧМТ / Забій мозку";
      steps = [
        "Моніторинг церебрального перфузійного тиску та уникнення різких нахилів голови вниз.",
        "Пасивна вертикалізація на поворотному столі (кут від 30° до 60°) під контролем АТ.",
        "Стимуляція зорового та слухового провідних шляхів під час виконання рухових вправ."
      ];
    } else {
      title = "🏥 Авто-Протокол: Синдром ICUAW (Слабість ВІТ)";
      steps = [
        "Вправи з прогресуючим опором за допомогою еластичних стрічок для великих м'язових груп.",
        "Тренування дихальної мускулатури (респіраторний тренінг з опором видиху).",
        "Рання циклічна мобілізація: використання приліжкового велоергометра."
      ];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: steps.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text("✔ $s", style: const TextStyle(fontSize: 12, color: Colors.black87)),
          )).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Зрозуміло")),
        ],
      ),
    );
  }

  void _showDynamicsChart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("📈 Хронологічний лог та Динаміка відновлення", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 4),
            const Text("Результати всіх проведених тестів пацієнта:", style: TextStyle(fontSize: 11, color: Colors.black54)),
            const Divider(),
            Expanded(
              child: _scaleLogs.isEmpty 
                ? const Center(child: Text("Історія тестувань порожня"))
                : ListView.builder(
                    itemCount: _scaleLogs.length,
                    itemBuilder: (context, index) {
                      final log = _scaleLogs[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.trending_up, color: Colors.green),
                        title: Text("${log['scale']}: ${log['score']} балів", style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text("Дата: ${log['date']}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                      );
                    },
                  ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> pMap = widget.patient.toMap();
    final String chamber = pMap['chamber'] ?? 'ВІТ';
    final String diagnosis = pMap['diagnosis'] ?? 'Не вказано';
    final String goal = widget.patient.currentSmartGoal;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Карта Пацієнта ВІТ", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareFullDischargeSummary,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.patient.fullName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 6),
                    Text("Вік: ${widget.patient.age} років   |   Локація: $chamber", style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                    const Divider(height: 20),
                    Text("📋 Діагноз (МКХ-10):\n$diagnosis", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    const Divider(height: 20),
                    const Text("🎯 Поточна SMART-ціль пацієнта:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(goal, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.purple)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: _shareFullDischargeSummary,
                icon: const Icon(Icons.description),
                label: const Text("Сформувати виписну карту пацієнта", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Функціональні дії та автоматизація", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 12),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildMenuCard(context, "Провести тест\n(Описи шкал)", Icons.assessment, Colors.green, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ScalesScreen(patient: widget.patient))).then((_) => _loadScaleLogs());
                }),
                _buildMenuCard(context, "Авто-протокол\nвправ", Icons.psychology, Colors.orange, () {
                  _showAutoExerciseProtocol(context, diagnosis);
                }),
                _buildMenuCard(context, "Історія та лог\nбалів шкал", Icons.show_chart, Colors.blue, () {
                  _showDynamicsChart(context);
                }),
                _buildMenuCard(context, "Експорт / Надіслати\nколегам", Icons.share, Colors.purple, () {
                  _shareFullDischargeSummary();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
