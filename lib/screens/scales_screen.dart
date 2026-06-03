import 'package:flutter/material.dart';
import '../models/patient.dart';
import 'scale_rass_page.dart';
import 'scale_mrc_page.dart';
import 'scale_cpax_page.dart';
import 'scale_cpot_page.dart';
import 'scale_ims_page.dart';
import 'scale_mwt_page.dart';
import 'scale_goniometry_page.dart';
import 'scale_stroke_pages.dart';

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
      "name": "Індекс мобільності CPAx (Chelsea Critical Care Physical Assessment Tool)",
      "purpose": "Комплексна оцінка фізичної спроможності пацієнтів, які перебувають на ШВЛ та в інтенсивній терапії.",
      "instruction": "Методика: Оцінюється 10 функціональних компонентів (дихальна функція, кашель, рухливість у ліжку, вставання, пересаджування тощо) за шкалою від 0 до 5. Дозволяє чітко відстежувати мікро-прогрес у пацієнтів на етапі реанімації.",
      "type": "cpax"
    },
    {
      "name": "Шкала CPOT (Critical-Care Pain Observation Tool)",
      "purpose": "Об'єктивна оцінка рівня болю у пацієнтів, які не можуть розмовляти або перебувають без свідомості.",
      "instruction": "Методика: Оцініть 4 поведінкові ознаки: вираз обличчя (0-2 бали), рухова активність (0-2 бали), опір апарату ШВЛ або вокалізація (0-2 бали) та м'язовий тонус за пасивного згинання/розгинання рук (0-2 бали). Сума > 2 свідчить про наявність болю.",
      "type": "cpot"
    },
    {
      "name": "Шкала мобільності IMS (Intensive Care Unit Mobility Scale)",
      "purpose": "Швидка фіксація найвищого рівня мобільності пацієнта у відділенні інтенсивної терапії протягом доби.",
      "instruction": "Методика: Оцініть реальну активність пацієнта за день за шкалою від 0 до 10. Бал 0 — пацієнт пасивний у ліжку. Бал 5 — пацієнт активно сидить на краю ліжка. Бал 10 — пацієнт самостійно ходить без допоміжних засобів.",
      "type": "ims"
    },
    {
      "name": "Тест MWT (Minute Walk Test / Хвилинні тести з ходьбою)",
      "purpose": "Оцінка функціональної витривалості, серцево-судинної та дихальної систем до навантажень.",
      "instruction": "Методика: Пацієнту пропонується пройти максимально можливу дистанцію по безпечному коридору за фіксований час (1, 2 або 6 хвилин). Терапевт рахує метраж, фіксує задишку за шкалою Борга та рівень сатурації до і після тесту.",
      "type": "mwt"
    },
    {
      "name": "Клінічна Гоніометрія (Goniometry)",
      "purpose": "Вимірювання точних кутів амплітуди пасивних та активних рухів у суглобах.",
      "instruction": "Методика: Встановіть стаціонарне плече гоніометра паралельно проксимальному сегменту кінцівки, вісь — на анатомічний центр суглоба, рухоме плече — вздовж дистального сегмента. Виконайте рух та зафіксуйте кут в градусах.",
      "type": "goniometry"
    },
    {
      "name": "Неврологічні Шкали Інсульту (Stroke Pages / NIHSS)",
      "purpose": "Експрес-діагностика неврологічного дефіциту та динаміки стану при гострому порушенні мозкового кровообігу.",
      "instruction": "Методика: Покрокове тестування рівня свідомості, рухів очей, полів зору, парезів обличчя, сили рук та ніг, атаксії, чутливості та мови. Оцінюється кожен окремий сегмент для локалізації та контролю динаміки ураження.",
      "type": "stroke"
    }
  ];

  void _navigateToScale(BuildContext context, String type) {
    Widget page;
    switch (type) {
      case 'rass':
        page = ScaleRassPage(patient: patient);
        break;
      case 'mrc':
        page = ScaleMrcPage(patient: patient);
        break;
      case 'cpax':
        page = ScaleCpaxPage(patient: patient);
        break;
      case 'cpot':
        page = ScaleCpotPage(patient: patient);
        break;
      case 'ims':
        page = ScaleImsPage(patient: patient);
        break;
      case 'mwt':
        page = ScaleMwtPage(patient: patient);
        break;
      case 'goniometry':
        page = ScaleGoniometryPage(patient: patient);
        break;
      case 'stroke':
        page = ScaleStrokePages(patient: patient);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Помилка: Модуль не знайдено.")),
        );
        return;
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
          patient == null ? "Каталог клінічних шкал" : "Шкали: ${patient!.fullName}",
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: Colors.bold),
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
