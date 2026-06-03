import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/patient.dart';
import 'dashboard_screen.dart';

class MainListScreen extends StatefulWidget {
  const MainListScreen({super.key});

  @override
  State<MainListScreen> createState() => _MainListScreenState();
}

class _MainListScreenState extends State<MainListScreen> {
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _mkhDatabase = [
    {"code": "I63.3", "name": "I63.3 Інфаркт головного мозку (Ішемічний інсульт)"},
    {"code": "I61.1", "name": "I61.1 Внутрішньомозковий крововилив (Геморагічний інсульт)"},
    {"code": "S06.2", "name": "S06.2 Дифузне травматичне ушкодження головного мозку (Тяжка ЧМТ)"},
    {"code": "G62.8", "name": "G62.8 Полінейропатія критичних станів (Слабість ВІТ / ICUAW)"},
    {"code": "G72.8", "name": "G72.8 Міопатія іммобілізації (критичних станів)"},
    {"code": "M16.0", "name": "M16.0 Первинний коксартроз двосторонній (Ортопедія)"},
    {"code": "C34", "name": "C34 Злоякісне новоутворення бронхів або легені (Онкореабілітація)"},
    {"code": "I21", "name": "I21 Гострий інфаркт міокарда (Кардіореабілітація)"}
  ];

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_filterPatients);
  }

  Future<void> _loadPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('patients_database');
    if (data != null) {
      final List decoded = json.decode(data);
      setState(() {
        _patients = decoded.map((p) => Patient.fromMap(p)).toList();
        _filteredPatients = _patients;
      });
    }
  }

  void _filterPatients() {
    String q = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _patients.where((p) => p.fullName.toLowerCase().contains(q)).toList();
    });
  }

  void _showAddPatientDialog() {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final chamberCtrl = TextEditingController();
    String selectedMkh = "I63.3 Інфаркт головного мозку (Ішемічний інсульт)";
    List<Map<String, String>> suggestions = List.from(_mkhDatabase);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Text("Реєстрація пацієнта та авто-формування ІРП за МКФ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl, 
                  keyboardType: TextInputType.text, // Виправлено: Тільки повноцінний текст українською/англійською
                  decoration: const InputDecoration(labelText: "ПІБ Пацієнта")
                ),
                TextField(
                  controller: ageCtrl, 
                  keyboardType: TextInputType.number, 
                  decoration: const InputDecoration(labelText: "Вік (повних років)")
                ),
                TextField(
                  controller: chamberCtrl, 
                  keyboardType: TextInputType.text, 
                  decoration: const InputDecoration(labelText: "Палата / Ліжко")
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Живий пошук МКХ-10 (МОЗ):", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      TextField(
                        decoration: const InputDecoration(hintText: "Введіть код або назву хвороби...", hintStyle: TextStyle(fontSize: 11)),
                        onChanged: (val) {
                          setDlgState(() {
                            suggestions = _mkhDatabase.where((element) => 
                              element['name']!.toLowerCase().contains(val.toLowerCase()) ||
                              element['code']!.toLowerCase().contains(val.toLowerCase())
                            ).toList();
                          });
                        },
                      ),
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          itemCount: suggestions.length,
                          itemBuilder: (context, i) {
                            final item = suggestions[i];
                            return ListTile(
                              dense: true,
                              title: Text(item['name']!, style: const TextStyle(fontSize: 11)),
                              onTap: () {
                                setDlgState(() {
                                  selectedMkh = item['name']!;
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
                Text("Обрано: $selectedMkh", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Скасувати")),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                
                // Автоматична генерація ІРП за протоколами МОЗ
                final autoData = Patient.generateAutoIRP(selectedMkh);

                final newPatient = Patient(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  fullName: nameCtrl.text,
                  age: int.tryParse(ageCtrl.text) ?? 50,
                  chamber: chamberCtrl.text,
                  diagnosis: selectedMkh,
                  currentSmartGoal: autoData['goal']!,
                  icfCodes: autoData['icf']!,
                  irpInterventions: autoData['interventions']!,
                );

                _patients.add(newPatient);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('patients_database', json.encode(_patients.map((p) => p.toMap()).toList()));
                _filterPatients();
                Navigator.pop(context);
              },
              child: const Text("Створити ІРП"),
            )
          ],
        ),
      ),
    );
  }

  void _showStandaloneSmartConstructor() {
    final domainCtrl = TextEditingController(text: "Неврологія (ГПМК)");
    final targetCtrl = TextEditingController(text: "Мобільність та переміщення в ліжку");
    final timeCtrl = TextEditingController(text: "7 днів");
    final resultGoal = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Автономний SMART-конструктор цілей", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: domainCtrl, decoration: const InputDecoration(labelText: "Нозологічна група / Операція")),
            TextField(controller: targetCtrl, decoration: const InputDecoration(labelText: "Порушена функція за МКФ")),
            TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: "Термін досягнення")),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                resultGoal.text = "Пацієнт зможе відновити функцію [${targetCtrl.text}] у профілі [${domainCtrl.text}] повністю самостійно, безпечно протягом ${timeCtrl.text} реабілітації.";
              },
              child: const Text("Згенерувати формулу SMART"),
            ),
            TextField(controller: resultGoal, maxLines: 3, decoration: const InputDecoration(labelText: "Результат")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Закрити")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Реабілітація ВІТ & ІРП (МОЗ України)", style: TextStyle(color: Colors.white, fontSize: 15)),
      ),
      body: Column(
        children: [
          // 4 ГОЛОВНІ ЗОНИ НА ГОЛОВНОМУ ЕКРАНІ
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                _buildMainZoneCard("Карта пацієнта & ІРП", Icons.assignment_turned_in, Colors.teal, () {}),
                _buildMainZoneCard("SMART Конструктор", Icons.psychology, Colors.purple, _showStandaloneSmartConstructor),
                _buildMainZoneCard("База вправ МОЗ", Icons.fitness_center, Colors.orange, () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Каталог вправ відкривається безпосередньо всередині карти пацієнта для дозування.")));
                }),
                _buildMainZoneCard("16 Клінічних Шкал", Icons.analytics, Colors.blue, () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Оберіть пацієнта нижче для запуску тестування з питаннями шкал.")));
                }),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                const Text("🏥 ПАЦІЄНТИ / РЕАБІЛІТАЦІЙНІ КАРТКИ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ElevatedButton.icon(
                  onPressed: _showAddPatientDialog,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text("Новий ІРП", style: TextStyle(fontSize: 11)),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Пошук пацієнта за ПІБ у списку відділення...",
                border: OutlineInputBorder()
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredPatients.length,
              itemBuilder: (context, index) {
                final p = _filteredPatients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Color(0xFF1E293B), child: Icon(Icons.person, color: Colors.white)),
                    title: Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text("Палата: ${p.chamber} | ${p.diagnosis}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen(patient: p))).then((_) => _loadPatients()),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMainZoneCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: color, width: 1.5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Flexible(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 11), textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
