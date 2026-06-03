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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_filterPatients);
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
      {"id": "1", "fullName": "Іванов Петро Сидорович", "age": 54, "chamber": "ВІТ-2, ліжко 3", "diagnosis": "I63.3 Інфаркт головного мозку (ГПМК)", "currentSmartGoal": "Стабілізація сидячи без підтримки 10 хвилин"},
      {"id": "2", "fullName": "Сидоров Олег Миколайович", "age": 43, "chamber": "ВІТ-1, ліжко 1", "diagnosis": "S06.2 Дифузне травматичне ушкодження головного мозку (ЧМТ)", "currentSmartGoal": "Збільшення мобільності в ліжку, повороти"}
    ];
    setState(() {
      _patients = mockData.map((p) => Patient.fromMap(p)).toList();
      _filteredPatients = _patients;
    });
    await prefs.setString('patients_list', json.encode(mockData));
  }

  void _filterPatients() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _patients.where((p) => p.fullName.toLowerCase().contains(query)).toList();
    });
  }

  void _showAddPatientDialog() {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final chamberCtrl = TextEditingController();
    final goalCtrl = TextEditingController();
    String selectedMkh = "I63.3 Інфаркт головного мозку";

    final List<String> mkhOptions = [
      "I63.3 Інфаркт головного мозку",
      "I61 Внутрішньомозковий крововилив",
      "S06.2 Дифузна ЧМТ",
      "G62.8 Інші визначені полінейропатії (Слабість ВІТ)",
      "G72.8 Інші визначені міопатії"
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Реєстрація пацієнта ВІТ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "ПІБ пацієнта")),
              TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: "Вік (років)"), keyboardType: TextInputType.number),
              TextField(controller: chamberCtrl, decoration: const InputDecoration(labelText: "Палата / Ліжко")),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedMkh,
                items: mkhOptions.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) => selectedMkh = v ?? selectedMkh,
                decoration: const InputDecoration(labelText: "Діагноз МКХ-10"),
              ),
              TextField(controller: goalCtrl, decoration: const InputDecoration(labelText: "Початкова SMART-ціль")),
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
                "age": int.tryParse(ageCtrl.text) ?? 30,
                "chamber": chamberCtrl.text.isEmpty ? "ВІТ" : chamberCtrl.text,
                "diagnosis": selectedMkh,
                "currentSmartGoal": goalCtrl.text.isEmpty ? "Мобілізація за протоколом" : goalCtrl.text,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("ВІТ Реабілітація", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
            onPressed: _showAddPatientDialog,
            tooltip: "Додати пацієнта",
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Клінічні оцінки та шкали", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Швидкий доступ до інструкцій та калькуляторів без прив'язки до картки пацієнта.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700, foregroundColor: Colors.white),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScalesScreen(patient: null))),
                  icon: const Icon(Icons.assessment),
                  label: const Text("Відкрити каталог шкал"),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Пошук пацієнта за ПІБ...",
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
                      // Безпечно витягуємо дані
                      final Map<String, dynamic> pMap = patient.toMap();
                      final String chamber = pMap['chamber'] ?? 'ВІТ';
                      final String diagnosis = pMap['diagnosis'] ?? 'Діагноз не вказано';

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: Color(0xFF334155), child: Icon(Icons.person, color: Colors.white)),
                          title: Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text("$chamber • $diagnosis", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
