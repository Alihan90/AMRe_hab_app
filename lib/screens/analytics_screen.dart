import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/patient.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Беремо нашого тестового пацієнта з історією хвороби
    final patient = Patient.mockPatient;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Графіки динаміки пацієнта",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patient.fullName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            Text("Діагноз: ${patient.icdDiagnosis}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),
            
            // Легенда графіка
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem("Сила м'язів (MRC)", Colors.blue),
                const SizedBox(width: 24),
                _buildLegendItem("Мобільність (IMS)", Colors.green),
              ],
            ),
            const SizedBox(height: 16),

            // Сама зона графіка fl_chart
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3)),
                  ],
                ),
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
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "${patient.sessionDates[index].day}.${patient.sessionDates[index].month}",
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    // Будуємо лінії на основі масивів історії пацієнта
                    lineBarsData: [
                      // Лінія MRC (Сила м'язів)
                      LineChartBarData(
                        spots: patient.mrcHistory.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value.toDouble());
                        }).toList(),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                      ),
                      // Лінія IMS (Мобільність у ВІТ)
                      LineChartBarData(
                        spots: patient.imsHistory.asMap().entries.map((e) {
                          // Множимо на 8, щоб візуально підняти шкалу 0-7 на рівень шкали MRC (0-60)
                          return FlSpot(e.key.toDouble(), e.value * 8.0);
                        }).toList(),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Короткий аналітичний висновок додатка
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.blue, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Аналітика: Спостерігається позитивна динаміка. Зростання м'язової сили корелює з підвищенням рівня мобільності пацієнта за останні 5 днів.",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}
