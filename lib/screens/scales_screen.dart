import 'package:flutter/material.dart';
import '../models/patient.dart';
import 'scale_ims_page.dart';
import 'scale_mrc_page.dart';

class ScalesScreen extends StatelessWidget {
  final Patient? patient;
  const ScalesScreen({super.key, this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(patient == null ? "Інструментальні Шкали" : "Оцінка пацієнта", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (patient != null)
            Padding(
              padding: const EdgeInsets.bottom(16.0),
              child: Text("Тестування для: ${patient!.fullName}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
          
          _buildScaleCard(
            context,
            "Шкала мобільності ВІТ (IMS)",
            "Рівень мобільності пацієнта в умовах реанімації від пасивного стану до ходьби (0-7 балів).",
            Icons.accessible_forward,
            Colors.green,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScaleImsPage(patient: patient))),
          ),
          const SizedBox(height: 12),
          _buildScaleCard(
            context,
            "Сила м'язів MRC-SumScore",
            "Діагностика периферичної слабкості та оцінка сили основних м'язових груп (0-60 балів).",
            Icons.fitness_center,
            Colors.blue,
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScaleMrcPage(patient: patient))),
          ),
        ],
      ),
    );
  }

  Widget _buildScaleCard(BuildContext context, String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(description, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
