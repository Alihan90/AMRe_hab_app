import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/patient.dart';
import 'dashboard_screen.dart';
import 'scales_screen.dart';

class MainListScreen extends StatefulWidget {
  const MainListScreen({super.key});

  @override
  State<MainListScreen> createState() => _MainListScreenState();
}

class _MainListScreenState extends State<MainListScreen> {
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  final TextEditingController _patientSearchController = TextEditingController();

  final List<Map<String, String>> _mkhDatabase = [
    {"code": "I63.3", "name": "I63.3 Інфаркт головного мозку (Ішемічний інсульт)", "goal": "Стабілізація сидіння на краю ліжка з підтримкою протягом 5-10 хвилин, контроль балансу."},
    {"code": "I61.1", "name": "I61.1 Внутрішньомозковий крововилив у півкулю (Геморагічний інсульт)", "goal": "Контроль протипролежневих укладок, пасивні рухи для запобігання ранніх контрактур."},
    {"code": "S06.2", "name": "S06.2 Дифузне травматичне ушкодження головного мозку (Тяжка ЧМТ)", "goal": "Активація за простими інструкціями, утримання вертикального положення голови до 2 хвилин."},
    {"code": "G62.8", "name": "G62.8 Полінейропатія критичних станів (Слабість набута у ВІТ / ICUAW)", "goal": "Збільшення загальної м'язової сили верхніх та нижніх кінцівок до >= 3 балів за MRC-SumScore."},
    {"code": "G72.8", "name": "G72.8 Інші визначені міопатії (Міопатія критичних станів / іммобілізації)", "goal": "Проведення пасивного ортостатичного тренування на вертикалізаторі під кутом до 60 градусів."},
    {"code": "I69.3", "name": "I69.3 Наслідки інфаркту головного мозку", "goal": "Відновлення опороздатності паретичної нижньої кінцівки, підготовка до вставання."},
    {"code": "S14.1", "name": "S14.1 Ушкодження шийного відділу спинного мозку", "goal": "Дихальна гімнастика з опором, профілактика гіпостатичної пневмонії, пасивна мобілізація."}
  ];

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _patientSearchController.addListener(_filterPatients);
  }

  Future<void> _loadPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('patients_list');
    if (data != null) {
      final List decoded = json.decode(data);
      setState(() {
        _patients = decoded.map((p) => Patient.fromMap(p)).toList();
        _filteredPatients = _patients;
      });
    } else {
      _createMockData();
    }
  }

  void _createMockData() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> mockData = [
      {
        "id": "1", 
        "fullName": "Іванов Петро Сидорович", 
        "age": 54, 
        "chamber": "ВІТ-2, ліжко 3", 
        "diagnosis": "I63.3 Інфаркт головного мозку (Ішемічний інсульт)", 
        "currentSmartGoal": "Стабілізація сидіння на краю ліжка з підтримкою протягом 5-10 хвилин, контроль балансу."
      }
    ];
    setState(() {
      _patients = mockData.map((p) => Patient.fromMap(p)).toList();
      _filteredPatients = _patients;
    });
    await prefs.setString('patients_list', json.encode(mockData));
  }

  void _filterPatients() {
    String query = _patientSearchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _patients.where((p) => p.fullName.toLowerCase().contains(query)).toList();
    });
  }

  void _showAddPatientDialog() {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final chamberCtrl = TextEditingController();
    final goalCtrl = TextEditingController();
    final mkhSearchCtrl = TextEditingController();
    
    String selectedDiagnosis = "I63.3 Інфаркт головного мозку (Ішемічний інсульт)";
    List<Map<String, String>> mkhSuggestions = List.from(_mkhDatabase);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Реєстрація пацієнта ВІТ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl, 
                    keyboardType: TextInputType.text, // Повністю виправлено роботу клавіатури
                    decoration: const InputDecoration(labelText: "ПІБ пацієнта (Текст)")
                  ),
                  TextField(
                    controller: ageCtrl, 
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Вік (років)")
                  ),
                  TextField(
                    controller: chamberCtrl, 
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(labelText: "Палата / Ліжко")
                  ),
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Живий пошук по МКХ-10:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        TextField(
                          controller: mkhSearchCtrl,
                          decoration: const InputDecoration(hintText: "Введіть код чи назву (напр. інсульт, ЧМТ)...", hintStyle: TextStyle(fontSize: 11)),
                          onChanged: (val) {
                            setDialogState(() {
                              mkhSuggestions = _mkhDatabase.where((item) => 
                                item['name']!.toLowerCase().contains(val.toLowerCase()) || 
                                item['code']!.toLowerCase().contains(val.toLowerCase())
                              ).toList();
                            });
                          },
                        ),
                        SizedBox(
                          height: 90,
                          child: mkhSuggestions.isEmpty 
                            ? const Center(child: Text("Нічого не знайдено", style: TextStyle(fontSize: 11)))
                            : ListView.builder(
                                itemCount: mkhSuggestions.length,
                                itemBuilder: (context, idx) {
                                  final sug = mkhSuggestions[idx];
                                  final isSel = selectedDiagnosis == sug['name'];
                                  return ListTile(
                                    dense: true,
                                    title: Text(sug['name']!, style: TextStyle(fontSize: 11, color: isSel ? Colors.blue : Colors.black87)),
                                    onTap: () {
                                      setDialogState(() {
                                        selectedDiagnosis = sug['name']!;
                                        mkhSearchCtrl.text = sug['code']!;
                                        goalCtrl.text = sug['goal']!; // Автоматичний підбір цілі
                                      });
                                    },
                                  );
                                },
                              ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: goalCtrl, 
                    maxLines: 2,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(labelText: "SMART ціль (Автоматична / Ручна)")
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Скасувати")),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty) return;
                  final newPatientMap = {
                    "id": DateTime.now().millisecondsSinceEpoch.toString(),
                    "fullName": nameCtrl.text,
                    "age": int.tryParse(ageCtrl.text) ?? 45,
                    "chamber": chamberCtrl.text.isEmpty ? "ВІТ" : chamberCtrl.text,
                    "diagnosis": selectedDiagnosis,
                    "currentSmartGoal": goalCtrl.text,
                  };
                  _patients.add(Patient.fromMap(newPatientMap));
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('patients_list', json.encode(_patients.map((p) => p.toMap()).toList()));
                  _filterPatients();
                  if (mounted) Navigator.pop(context);
                },
                child: const Text("Зберегти"),
              )
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("ВІТ Реабілітація v1.0", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Глобальний пошук та інструменти (доступні без вибору пацієнта)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Глобальний пошук шкал та вправ", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700, foregroundColor: Colors.white),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScalesScreen(patient: null))),
                        icon: const Icon(Icons.assessment, size: 16),
                        label: const Text("Каталог шкал", style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white),
                        onPressed: () {
                          // Перехід на глобальний екран вправ
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Загальний каталог вправ доступний через карту пацієнта")));
                        },
                        icon: const Icon(Icons.fitness_center, size: 16),
                        label: const Text("База вправ", style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                const Text("📋 СПИСОК ПАЦІЄНТІВ ВІДДІЛЕННЯ", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                IconButton(
                  icon: const Icon(Icons.person_add, color: Colors.blue, size: 26),
                  onPressed: _showAddPatientDialog,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TextField(
              controller: _patientSearchController,
              decoration: InputDecoration(
                hintText: "Пошук пацієнта за ПІБ у базі...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredPatients.isEmpty
                ? const Center(child: Text("Пацієнтів не знайдено"))
                : ListView.builder(
                    itemCount: _filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = _filteredPatients[index];
                      final Map<String, dynamic> pMap = patient.toMap();
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: Color(0xFF334155), child: Icon(Icons.person, color: Colors.white)),
                          title: Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text("${pMap['chamber']} • ${pMap['diagnosis']}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen(patient: patient))).then((_) => _loadPatients()),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
