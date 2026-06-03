import 'package:flutter/material.dart';
import '../models/patient.dart';
import 'scale_rass_page.dart';
import 'scale_mrc_page.dart';
import 'scale_cpax_page.dart';
import 'scale_cpot_page.dart';
import 'scale_ims_page.dart';
import 'scale_mwt_page.dart';
import 'scale_goniometry_page.dart';
import 'scale_stroke_page.dart';

class ScalesScreen extends StatelessWidget {
  final Patient? patient;
  const ScalesScreen({super.key, this.patient});

  final List<Map<String, dynamic>> _scalesData = const [
    {
      "name": "Шкала RASS (Richmond Agitation-Sedation Scale)",
      "purpose": "Оцінка рівня седації та збудження пацієнта в умовах інтенсивної терапії.",
      "instruction": "Методика: Спостерігайте за пацієнтом. Спокійний — 0. Агресивний/збуджений — від +1 до +4. Сонливий (реагує на голос) — від -1 до -3. Реагує лише на фізичний подразник — -4 та -5.",
      "type": "rass"
    },
    {
      "name": "Тест MRC-SumScore (Medical Research Council)",
      "purpose": "Оцінка загальної м'язової сили для діагностики слабкості, набутої у ВІТ.",
      "instruction": "Методика: Тестуються 6 м'язових груп симетрично з обох боків. Оцінка від 0 до 5 балів. Максимум — 60 балів.",
      "type": "mrc"
    },
    {
      "name": "Шкала рівноваги Берга (Berg Balance Scale)",
      "purpose": "Контроль статичного та динамічного балансу, оцінка ризику падіння.",
      "instruction": "Методика: Виконання 14 функціональних завдань (вставання, стояння без підтримки, пересаджування тощо). Кожне завдання оцінюється від 0 до 4 балів.",
      "type": "berg"
    },
    {
      "name": "Індекс мобільності Рівермід (Rivermead Mobility Index)",
      "purpose": "Оцінка базової рухової активності та рівня самостійності переміщення.",
      "instruction": "Методика: Оцінка 14 усних питань/тверджень та 1 практичного тесту. За кожне позитивне твердження — 1 бал.",
      "type": "rivermead"
    },
    {
      "name": "Шкала модифікована Борга (Borg CR10 Scale)",
      "purpose": "Суб'єктивна оцінка пацієнтом рівня задишки та фізичного навантаження.",
      "instruction": "Методика: Пацієнт оцінює своє відчуття нестачі повітря або втоми від 0 (взагалі нічого) до 10 (максимально важке навантаження).",
      "type": "borg"
    },
    {
      "name": "Індекс мобільності CPAx (Chelsea Critical Care Physical Assessment)",
      "purpose": "Комплексна оцінка фізичної спроможності пацієнтів на ШВЛ.",
      "instruction": "Методика: Оцінка 10 компонентів (дихання, кашель, рухливість у ліжку тощо) від 0 до 5 балів.",
      "type": "cpax"
    },
    {
      "name": "Шкала CPOT (Critical-Care Pain Observation Tool)",
      "purpose": "Об'єктивна оцінка болю у пацієнтів без свідомості або на ШВЛ.",
      "instruction": "Методика: Оцінка 4 ознак: вираз обличчя, рухова активність, опір ШВЛ та тонус м'язів (0-2 бали на кожну).",
      "type": "cpot"
    },
    {
      "name": "Шкала мобільності IMS (Intensive Care Unit Mobility Scale)",
      "purpose": "Фіксація найвищого рівня мобільності пацієнта у ВІТ за добу.",
      "instruction": "Методика: Градація від 0 (пасивний у ліжку) до 10 (самостійна ходьба без допоміжних засобів).",
      "type": "ims"
    },
    {
      "name": "Тест MWT (Minute Walk Test / Тести з ходьбою)",
      "purpose": "Оцінка функціональної толерантності до фізичного навантаження.",
      "instruction": "Методика: Фіксація відстані за 1, 2 або 6 хвилин. Обов'язково вимірюється сатурація (SpO2), пульс та задишка до і після тесту.",
      "type": "mwt"
    },
    {
      "name": "Клінічна Гоніометрія (Goniometry)",
      "purpose": "Вимірювання точних кутів амплітуди рухів у суглобах кінцівок.",
      "instruction": "Методика: Вісь гоніометра — на центр суглоба, фіксація зміни кутів руху в градусах.",
      "type": "goniometry"
    },
    {
      "name": "Неврологічні Шкали Інсульту (Stroke Pages / NIHSS)",
      "purpose": "Оцінка неврологічного дефіциту в гострому періоді інсульту.",
      "instruction": "Методика: Покрокове тестування свідомості, поглядів, міміки, сили рук та ніг.",
      "type": "stroke"
    }
  ];

  void _navigateToScale(BuildContext context, String type) {
    Widget page;
    switch (type) {
      case 'rass': page = ScaleRassPage(patient: patient); break;
      case 'mrc': page = ScaleMrcPage(patient: patient); break;
      case 'cpax': page = ScaleCpaxPage(patient: patient); break;
      case 'cpot': page = ScaleCpotPage(patient: patient); break;
      case 'ims': page = ScaleImsPage(patient: patient); break;
      case 'mwt': case 'borg': page = ScaleMwtPage(patient: patient); break;
      case 'goniometry': page = ScaleGoniometryPage(patient: patient); break;
      case 'stroke': page = ScaleStrokePage(patient: patient); break;
      case 'berg': case 'rivermead': page = ScaleMwtPage(patient: patient); break;
      default: return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          patient == null ? "Каталог клінічних шкал" : "Шкали пацієнта",
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
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
