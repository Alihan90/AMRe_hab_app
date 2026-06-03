import 'package:flutter/material.dart';
import '../models/patient.dart';
import 'scale_rass_page.dart';

class ScalesScreen extends StatelessWidget {
  final Patient? patient;
  const ScalesScreen({super.key, this.patient});

  final List<Map<String, dynamic>> _scalesData = const [
    {
      "name": "Шкала RASS (Richmond Agitation-Sedation Scale)",
      "purpose": "Оцінка рівня седації та збудження пацієнта в умовах інтенсивної терапії.",
      "instruction": "Методика: Спостерігайте за пацієнтом. Якщо він спокійний — бал 0. Якщо агресивний чи збуджений — бали від +1 до +4. Якщо сонливий, зверніться до нього голосом та оцініть тривалість зорового контакту (бали від -1 до -3). Якщо реакція лише на фізичний подразник — бали -4 та -5.",
      "type": "rass"
    },
    {
      "name": "Тест MRC-SumScore (Medical Research Council)",
      "purpose": "Оцінка загальної м'язової сили у пацієнтів критичних станів (діагностика слабкості, набутої у ВІТ).",
      "instruction": "Методика: Тестуються 6 м'язових груп симетрично з обох боків (відведення плеча, згинання передпліччя, розгинання кисті, згинання стегна, розгинання коліна, тильне згинання стопи). Кожен рух оцінюється від 0 (немає скорочень) до 5 (нормальна сила). Максимум — 60 балів.",
      "type": "mrc"
    },
    {
      "name": "Шкала рівноваги Берга (Berg Balance Scale)",
      "purpose": "Контроль статичного та динамічного балансу, оцінка ризику падіння пацієнта.",
      "instruction": "Методика: Пацієнту пропонується виконати 14 функціональних завдань (вставання зі стільця, стояння без підтримки, пересаджування, стояння із заплющеними очима тощо). Кожне завдання оцінюється від 0 до 4 балів залежно від якості та швидкості виконання.",
      "type": "berg"
    },
    {
      "name": "Індекс мобільності Рівермід (Rivermead Mobility Index)",
      "purpose": "Оцінка базової рухової активності та рівня самостійності переміщення.",
      "instruction": "Методика: Складається з 14 питань до пацієнта (або спостережень) та 1 практичного тесту (стояння без підтримки 10 сек). Питання покривають градієнт від поворотів у ліжку до підйому по сходах. За кожне 'Так' нараховується 1 бал.",
      "type": "rivermead"
    }
  ];

  void _navigateToScale(BuildContext context, String type) {
    if (type == 'rass') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ScaleRassPage(patient: patient)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Модуль для $type зараз інтегрується автоматично...")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(patient == null ? "Каталог клінічних шкал" : "Шкали: ${patient!.fullName}", style: const TextStyle(color: Colors.white, fontSize: 15)),
      ),
      body: ListView.builder(
        itemCount: _scalesData.length,
        itemBuilder: (context, index) {
          final scale = _scalesData[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scale["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                  const SizedBox(height: 6),
                  Text("🎯 Мета: ${scale["purpose"]}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blueGrey)),
                  const SizedBox(height: 4),
                  Text("📋 Інструкція: ${scale["instruction"]}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                      onPressed: () => _navigateToScale(context, scale["type"]),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text("Перейти до тестування", style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
