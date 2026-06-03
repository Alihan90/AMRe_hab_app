import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/patient.dart';
import 'scales_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Patient patient;
  const DashboardScreen({super.key, required this.patient});

  void _sharePatientReport() {
    final String report = """
📋 ЗВІТ РАННЬОЇ РЕАБІЛІТАЦІЇ ВІТ
Пацієнт: ${patient.fullName}
Вік: ${patient.age} р.
----------------------------------
Згенеровано в додатку ВІТ-Реабілітація.
""";
    Share.share(report, subject: 'Реабілітаційний звіт - ${patient.fullName}');
  }

  @override
  Widget build(BuildContext context) {
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
                        Expanded(
                          child: Text(patient.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text("Вік: ${patient.age} р.", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    const Text("Статус пацієнта активний у відділенні ранньої реабілітації.", style: const TextStyle(fontSize: 13, color: Colors.black87)),
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
                _buildMenuCard(context, "SMART Майстер", Icons.psychology_rounded, Colors.purple, () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Модуль SMART цілей активний")));
                }),
                _buildMenuCard(context, "Графіки динаміки", Icons.show_chart_rounded, Colors.blue, () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Графіки будуються автоматично з логів")));
                }),
                _buildMenuCard(context, "База вправ ВІТ", Icons.directions_run_rounded, Colors.orange, () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Протоколи ранньої мобілізації активні")));
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
