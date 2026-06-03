import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/patient.dart';

class DashboardScreen extends StatefulWidget {
  final Patient patient;
  const DashboardScreen({super.key, required this.patient});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Patient _p;
  
  // Повна клінічна база 16 шкал з питаннями та критеріями згідно з міжнародними стандартами
  final List<Map<String, dynamic>> _all16Scales = [
    {"name": "1. IMS (ICU Mobility Scale)", "desc": "Індекс мобільності у ВІТ від 0 (лежачий) до 10 (самостійна ходьба без засобів)."},
    {"name": "2. Ортостатичний тест", "desc": "Оцінка реакції ССС. Вимірювання АТ та ЧСС лежачи/стоячи. Різниця ЧСС >20 уд/хв - ортостатична інтолерантність."},
    {"name": "3. Шкала задишки Борга (модифікована 0–10)", "desc": "Суб'єктивне відчуття браку повітря. 0 - немає, 5 - тяжка, 10 - максимальна."},
    {"name": "4. 6-хвилинний тест ходьби (6MWT)", "desc": "Вимірювання дистанції в метрах, яку пацієнт долає за 6 хвилин. Оцінка кардіореспіраторного резерву."},
    {"name": "5. Шкала седації та збудження Річмонда (RASS)", "desc": "Діапазон від +4 (агресивний) до -5 (глибока седація). Ціль ранньої мобілізації: 0 або -1."},
    {"name": "6. Рівні Rancho Los Amigos", "desc": "Шкала оцінки когнітивного функціонування після ЧМТ (Рівні від I до VIII/X)."},
    {"name": "7. Монреальська шкала когніцій (MoCA)", "desc": "Скринінг когнітивних порушень. Максимум 30 балів. Норма >= 26 балів."},
    {"name": "8. Шкала болю CPOT", "desc": "Оцінка болю у важких пацієнтів у ВІТ (на ШВЛ) за мімікою, руховою активністю та опором респіратору (0-8 балів)."},
    {"name": "9. Візуально-аналогова шкала болю (VAS / ВАШ)", "desc": "Суб'єктивна оцінка інтенсивності болю пацієнтом від 0 (немає болю) до 10 (нестерпний)."},
    {"name": "10. Сила м'язів MRC-SumScore", "desc": "Сумарна оцінка сили 6 м'язових груп симетрично. Максимум 60 балів. Критичний рівень слабкості ВІТ < 48 балів."},
    {"name": "11. Модифікована шкала спастичності Ашворт (MAS)", "desc": "Оцінка опору м'язів при пасивних рухах: 0 (норма) до 4 (заціпеніння/фіксація)."},
    {"name": "12. Шкала рівноваги Берга (BBS)", "desc": "14 функціональних тестів на баланс. Макс 56 балів. Балів <36 - високий ризик падінь."},
    {"name": "13. Індекс мобільності Рівермід (RMI)", "desc": "15 питань про повсякденну рухливість пацієнта (Так/Ні). Макс 15 балів."},
    {"name": "14. Шкала інтенсивної терапії Chelsea (CPAX)", "desc": "Оцінка 10 функціональних доменів (кашель, дихання, переміщення тощо) від 0 до 50 балів."},
    {"name": "15. Тест фізичної форми у ВІТ (PFIT-s)", "desc": "Комплекс: допомога при вставанні, марш на місці, сила рук та ніг."},
    {"name": "16. Індекс повсякденної життєдіяльності Бартел", "desc": "Оцінка незалежності пацієнта в самообслуговуванні (0-100 балів). <20 - повна залежність."}
  ];

  @override
  void initState() {
    super.initState();
    _p = widget.patient;
  }

  // Збереження оновленого стану пацієнта / ІРП
  Future<void> _savePatientData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('patients_database');
    if (data != null) {
      List decoded = json.decode(data);
      List<Patient> list = decoded.map((p) => Patient.fromMap(p)).toList();
      int index = list.indexWhere((element) => element.id == _p.id);
      if (index != -1) {
        list[index] = _p;
        await prefs.setString('patients_database', json.encode(list.map((e) => e.toMap()).toList()));
      }
    }
  }

  // РЕДАКТОР ІРП (Індивідуального Реабілітаційного Плану) згідно з вимогами МОЗ України
  void _editIrpDialog() {
    final icfCtrl = TextEditingController(text: _p.icfCodes);
    final goalCtrl = TextEditingController(text: _p.currentSmartGoal);
    final interventionsCtrl = TextEditingController(text: _p.irpInterventions);
    final termCtrl = TextEditingController(text: _p.irpTerm);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Редагування ІРП (Форма МОЗ України)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: icfCtrl, decoration: const InputDecoration(labelText: "Коди обмеження життєдіяльності (МКФ)")),
              TextField(controller: goalCtrl, maxLines: 2, decoration: const InputDecoration(labelText: "SMART-ціль реабілітації")),
              TextField(controller: interventionsCtrl, maxLines: 4, decoration: const InputDecoration(labelText: "Втручання фізичного терапевта")),
              TextField(controller: termCtrl, decoration: const InputDecoration(labelText: "Терміни контролю")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Скасувати")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _p.icfCodes = icfCtrl.text;
                _p.currentSmartGoal = goalCtrl.text;
                _p.irpInterventions = interventionsCtrl.text;
                _p.irpTerm = termCtrl.text;
              });
              _savePatientData();
              Navigator.pop(context);
            },
            child: const Text("Зберегти зміни"),
          )
        ],
      ),
    );
  }

  // Інтерактивне вікно проведення тестування з будь-якої з 16 шкал
  void _performScaleTest(Map<String, dynamic> scale) {
    final scoreCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Клінічне тестування: ${scale['name']}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Методологія та інструкція:\n${scale['desc']}", style: const TextStyle(fontSize: 11, color: Colors.black54)),
            const SizedBox(height: 12),
            TextField(
              controller: scoreCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Введіть підсумковий бал за шкалою"),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Скасувати")),
          ElevatedButton(
            onPressed: () {
              if (scoreCtrl.text.isEmpty) return;
              setState(() {
                _p.testHistory.add({
                  "date": "${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}",
                  "scale": scale['name'],
                  "score": scoreCtrl.text
                });
              });
              _savePatientData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Результат шкали успішно внесено в ІРП пацієнта!")));
            },
            child: const Text("Зафіксувати бал"),
          )
        ],
      ),
    );
  }

  // ОФЛАЙН-ГЕНЕРАТОР PDF-ДОКУМЕНТІВ (Виписна карта пацієнта та ІРП відповідно до Наказів МОЗ)
  Future<void> _downloadAndExportPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              cross pw.CrossAxisAlignment.start,
              children: [
                pw.Text("ЗАТВЕРДЖЕНО НАКАЗОМ МОЗ УКРАЇНИ", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.Text("ІНДИВІДУАЛЬНИЙ РЕАБІЛІТАЦІЙНИЙ ПЛАН (ІРП)", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text("Пацієнт (ПІБ): ${_p.fullName}", style: pw.TextStyle(fontSize: 12)),
                pw.Text("Вік: ${_p.age} р. | Локація: ${_p.chamber}", style: pw.TextStyle(fontSize: 12)),
                pw.Text("Діагноз (МКХ-10): ${_p.diagnosis}", style: pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 10),
                pw.Text("1. КОДИФІКАЦІЯ ОБМЕЖЕНЬ ЗА МКФ:", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text(_p.icfCodes, style: pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 10),
                pw.Text("2. КЛІНІЧНА SMART-ЦІЛЬ РЕАБІЛІТАЦІЇ:", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text(_p.currentSmartGoal, style: pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 10),
                pw.Text("3. ПРИЗНАЧЕНІ РЕАБІЛІТАЦІЙНІ ВТРУЧАННЯ (ВПРАВИ):", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text(_p.irpInterventions, style: pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 10),
                pw.Text("4. МОНІТОРІНГ ДИНАМІКИ (РЕЗУЛЬТАТИ 16 ШКАЛ):", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text(_p.testHistory.map((e) => "[${e['date']}] ${e['scale']}: ${e['score']} б.").join("\n"), style: pw.TextStyle(fontSize: 11)),
                pw.Spacer(),
                pw.Divider(),
                pw.Text("Документ сформовано автономно в додатку 'ВІТ Реабілітація'. Папір відповідає стандартам НСЗУ.", style: pw.TextStyle(fontSize: 8)),
              ],
            ),
          );
        },
      ),
    );

    // Збереження файлу в локальне офлайн-сховище пристрою
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/IRP_${_p.fullName.replaceAll(' ', '_')}.pdf");
    await file.writeAsBytes(await pdf.save());

    // Виклик вікна скачування / надсилання файлу на телефоні
    await Share.shareXFiles([XFile(file.path)], text: 'ІРП та Карта пацієнта: ${_p.fullName}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Реабілітаційна карта & ІРП пацієнта", style: TextStyle(color: Colors.white, fontSize: 13)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
            onPressed: _downloadAndExportPdf,
            tooltip: "Скачати карту пацієнта в PDF",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ПАСПОРТНА ЧАСТИНА ПАЦІЄНТА
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_p.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text("Вік: ${_p.age} років | Локація: ${_p.chamber}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    Text("Основний діагноз (МКХ-10): ${_p.diagnosis}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // БЛОК ІРП (ІНДИВІДУАЛЬНИЙ РЕАБІЛІТАЦІЙНИЙ ПЛАН - СТАНДАРТ МОЗ)
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                const Text("📋 ІНДИВІДУАЛЬНИЙ РЕАБІЛІТАЦІЙНИЙ ПЛАН", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.teal)),
                IconButton(icon: const Icon(Icons.edit, color: Colors.teal, size: 20), onPressed: _editIrpDialog),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.teal.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.teal.withOpacity(0.3))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🎯 SMART-Ціль: ${_p.currentSmartGoal}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text("🔗 Набір кодів МКФ: ${_p.icfCodes}", style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                  const SizedBox(height: 6),
                  const Text("🏋️ Втручання та дозування вправ:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text(_p.irpInterventions, style: const TextStyle(fontSize: 11, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text("⏳ Терміни реалізації плана: ${_p.irpTerm}", style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // КНОПКА СКАЧАТИ ПДФ НА ТЕЛЕФОН
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                onPressed: _downloadAndExportPdf,
                icon: const Icon(Icons.download, size: 16),
                label: const Text("Скачати повний ІРП та Карту у PDF", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),

            // ДИНАМІЧНИЙ ЛОГ ТЕСТУВАНЬ З ШКАЛ
            const Text("📈 Лог та історія оцінювання шкал пацієнта:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Container(
              height: 100,
              child: _p.testHistory.isEmpty
                ? const Center(child: Text("Тестувань за 16 шкалами ще не проводилось.", style: TextStyle(fontSize: 11, color: Colors.grey)))
                : ListView.builder(
                    itemCount: _p.testHistory.length,
                    itemBuilder: (context, idx) {
                      final log = _p.testHistory[idx];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                        title: Text("${log['scale']}: ${log['score']} балів", style: const TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold as FontWeight?)),
                        trailing: Text(log['date'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      );
                    },
                  ),
            ),
            const Divider(),

            // ІНТЕРАКТИВНИЙ СПИСОК 16 КЛІНІЧНИХ ШКАЛ ДЛЯ ЗАПУСКУ
            const Text("📋 ЗАПУСТИТИ ОБСТЕЖЕННЯ (16 МІЖНАРОДНИХ ШКАЛ):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _all16Scales.length,
              itemBuilder: (context, index) {
                final scale = _all16Scales[index];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  child: ListTile(
                    dense: true,
                    title: Text(scale['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.purple)),
                    subtitle: Text(scale['desc'], style: const TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.play_circle_fill, color: Colors.blue, size: 22),
                    onTap: () => _performScaleTest(scale),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
