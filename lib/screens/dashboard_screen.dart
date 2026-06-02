import 'package:flutter/material.dart';
import '../models/patient.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? super.key}) : super(key: super);

  @override
  Widget build(BuildContext context) {
    // Беремо нашого тестового пацієнта для демонстрації на екрані
    final patient = Patient.mockPatient;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B), // Глибокий медичний темно-синій
        title: const Text(
          "ВІТ-Реабілітація",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Картка поточного пацієнта
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
                        const Icon(Icons.person, color: Colors.blue, size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            patient.fullName,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Вік: ${patient.birthDate}", style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text("Діагноз: [${patient.icdCode}] ${patient.icdDiagnosis}", 
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Модулі реабілітації",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            // Сітка з кнопками-модулями
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  context, 
                  "Шкали & Безпека", 
                  Icons.analytics_rounded, 
                  Colors.green,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Модуль шкал буде підключено в наступному кроці")),
                    );
                  }
                ),
                _buildMenuCard(
                  context, 
                  "SMART Майстер", 
                  Icons.psychology_rounded, 
                  Colors.purple,
                  () {}
                ),
                _buildMenuCard(
                  context, 
                  "Графіки динаміки", 
                  Icons.show_chart_rounded, 
                  Colors.blue,
                  () {}
                ),
                _buildMenuCard(
                  context, 
                  "База вправ ВІТ", 
                  Icons.directions_run_rounded, 
                  Colors.orange,
                  () {}
                ),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
