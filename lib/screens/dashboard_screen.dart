import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/patient.dart';
import 'scales_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Patient patient;
  const DashboardScreen({super.key, required this.patient});

  void _sharePatientReport() {
    final Map<String, dynamic> pMap = patient.toMap();
    final String chamber = pMap['chamber'] ?? 'ВІТ';
    final String diagnosis = pMap['diagnosis'] ?? 'Не вказано';
    final String goal = patient.currentSmartGoal.isEmpty ? "Мобілізація за протоколом" : patient.currentSmartGoal;

    final String report = """
📋 ЗВІТ РАННЬОЇ РЕАБІЛІТАЦІЇ ВІТ
Пацієнт: ${patient.fullName}
Вік: ${patient.age} р.  Палата: $chamber
Діагноз МКХ-10: $diagnosis
----------------------------------
🎯 Поточна SMART-ціль: $goal
----------------------------------
Згенеровано в додатку ВІТ-Реабілітація.
""";
    Share.share(report, subject: 'Реабілітаційний звіт - ${patient.fullName}');
  }

  void _showExercisesDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            const Text("📋 Протоколи вправ та Ранньої Мобілізації ВІТ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const Divider(),
            _buildExerciseSection("Рівень 1: Пасивна мобілізація (Рівень свідомості низький / RASS -4...-3)", [
              "Циклічне пасивне розроблення суглобів кінцівок (кінезотерапія) — по 10-15 хв на кінцівку.",
              "Профілактичне лікування положенням (антиспастичні та протипролежневі укладки) — зміна кожні 2 години.",
              "Дихальна кінезотерапія, перкусійний масаж для покращення дренажу легень."
            ]),
            _buildExerciseSection("Рівень 2: Активно-пасивна мобілізація (RASS -2...+1, пацієнт виконує прості команди)", [
              "Вправи на ліжку з підвісними системами чи еластичними стрічками.",
              "Активне припіднімання тазу в ліжку (місток) для підготовки до пересаджування.",
              "Ортостатичне тренування — поступове піднімання головного кінця ліжка до 45-60°."
            ]),
            _buildExerciseSection("Рівень 3: Активна мобілізація та вертикалізація (Пацієнт стабільний, MRC > 3)", [
              "Переведення в положення сидячи на краю ліжка з опущеними ногами (тренування балансу по 10-15 хв).",
              "Ініціація вертикалізації за допомогою поворотного столу-вертикалізатора або активного підйому з підтримкою.",
              "Вправи на пересаджування у приліжкове крісло."
            ]),
          ],
        ),
      ),
    );
  }

  void _showMkhDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("📚 Класифікатор МКХ-10 (Неврологія та Реабілітація)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(title: Text("I63 — Інфаркт головного мозку"), subtitle: Text("Включає тромбоз, емболію, оклюзію церебральних артерій.")),
                  ListTile(title: Text("I61 — Внутрішньомозковий крововилив"), subtitle: Text("Геморагічний інсульт субарахноїдальний чи паренхіматозний.")),
                  ListTile(title: Text("S06 — Внутрішньочерепна травма (ЧМТ)"), subtitle: Text("Струс, забій, дифузне ушкодження, епі- та субдуральні гематоми.")),
                  ListTile(title: Text("G62.8 — Слабість, набута у відділенні інтенсивної терапії (ICUAW)"), subtitle: Text("Полінейропатії та міопатії критичних станів.")),
                  ListTile(title: Text("G72.8 — Інші визначені міопатії"), subtitle: Text("Первинні розлади м'язів внаслідок тривалої іммобілізації.")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseSection(String title, List<String> exercises) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.indigo)),
          const SizedBox(height: 4),
          ...exercises.map((e) => Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            child: Text("• $e", style: const TextStyle(fontSize: 12, color: Colors.black87)),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> pMap = patient.toMap();
    final String chamber = pMap['chamber'] ?? 'ВІТ';
    final String diagnosis = pMap['diagnosis'] ?? 'Не вказано';
    final String goal = patient.currentSmartGoal.isEmpty ? "Мобілізація за протоколом" : patient.currentSmartGoal;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Карта Пацієнта", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _sharePatientReport,
            tooltip: "Поділитися звітом",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.badge, color: Colors.blue, size: 28),
                        const SizedBox(width: 8),
                        Expanded(child: Text(patient.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const Divider(height: 24),
                    Text("Вік: ${patient.age} р.  |  Локація: $chamber", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    Text("Діагноз МКХ-10: $diagnosis", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    const Divider(height: 20),
                    const Text("Поточна SMART-ціль:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(goal, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text("Модулі та Інструменти", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(context, "Провести тест (Шкали)", Icons.assessment, Colors.green, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ScalesScreen(patient: patient)));
                }),
                _buildMenuCard(context, "Довідник МКХ-10", Icons.library_books_rounded, Colors.purple, () {
                  _showMkhDialog(context);
                }),
                _buildMenuCard(context, "База вправ ВІТ", Icons.directions_run_rounded, Colors.orange, () {
                  _showExercisesDialog(context);
                }),
                _buildMenuCard(context, "Звіт та Динаміка", Icons.show_chart_rounded, Colors.blue, () {
                  _sharePatientReport();
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
