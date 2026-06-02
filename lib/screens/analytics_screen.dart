import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/patient.dart';

class AnalyticsScreen extends StatelessWidget {
  final Patient patient;
  const AnalyticsScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Графіки динаміки пацієнта", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(patient.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("МКХ: ${patient.icdDiagnosis}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem("Сила м'язів (MRC)", Colors.blue),
                const SizedBox(width: 24),
                _buildLegendItem("Мобільність (IMS * 8)", Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < patient.sessionDates.length) {
                              var d = patient.sessionDates[index];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text("${d.day}.${d.month}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: patient.mrcHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 4,
                        dotData: const FlDotData(show: true),
                      ),
                      LineChartBarData(
                        spots: patient.imsHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value * 8.0)).toList(),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 4,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
