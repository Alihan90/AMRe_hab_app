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

  // Повний вбудований довідник МКХ для реанімації
  final List<String> _icdCatalog = [
    "I63.9 Інфаркт мозку (ГПМК)",
    "G73.7 Міопатія при критичних станах (ПІТ-М)",
    "T06.8 Інші множинні травми (Політравма)",
    "J96.0 Гостра дихальна недостатність (ГДН)",
    "A41.9 Сепсис неуточнений",
    "U07.1 COVID-19",
  ];

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_filterPatients);
  }

  // Завантаження пацієнтів із пам'яті телефона
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
      // Якщо база порожня, додамо одного тестового
      final defaultPatient = Patient(
        id: "1",
        fullName: "Коваленко Андрій Петрович",
        age: "58",
        roomNumber: "3",
        icdDiagnosis: "I63.9 Інфаркт мозку (ГПМК)",
        mrcHistory: [24, 28, 34, 40, 44],
        imsHistory: [1, 1, 2, 3, 4],
        sessionDates: List.generate(5, (i) => DateTime.now().subtract(Duration(days: 4 - i))),
        currentSmartGoal: "Пацієнт зможе самостійно переходити в положення сидіння.",
      );
      setState(() {
        _patients = [defaultPatient];
        _filteredPatients = _patients;
      });
      _savePatients();
    }
  }

  Future<void> _savePatients() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_patients.map((p) => p.toMap()).toList());
    await prefs.setString('patients_list', encoded);
  }

  void _filterPatients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _patients.where((p) {
        return p.fullName.toLowerCase().contains(query) || p.roomNumber.contains(query);
      }).toList();
    });
  }

  // Вікно створення нового пацієнта
  void _showAddPatientDialog() {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final roomCtrl = TextEditingController();
    String selectedIcd = _icdCatalog.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Додати пацієнта ВІТ"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "ПІБ Пацієнта")),
                    TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: "Вік"), keyboardType: TextInputType.number),
                    TextField(controller: roomCtrl, decoration: const InputDecoration(labelText: "Палата / Ліжко")),
                    const SizedBox(height: 16),
                    const Text("Діагноз МКХ:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: selectedIcd,
                      isExpanded: true,
                      items: _icdCatalog.map((icd) => DropdownMenuItem(value: icd, child: Text(icd, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) => setDialogState(() => selectedIcd = val!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Скасувати")),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty) return;
                    final newPatient = Patient(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      fullName: nameCtrl.text,
                      age: ageCtrl.text,
                      roomNumber: roomCtrl.text,
                      icdDiagnosis: selectedIcd,
                      mrcHistory: [20], // Початкова точка
                      imsHistory: [0],  // Початковий IMS
                      sessionDates: [DateTime.now()],
                    );
                    setState(() {
                      _patients.add(newPatient);
                      _filterPatients();
                    });
                    _savePatients();
                    Navigator.pop(context);
                  },
                  child: const Text("Зберегти"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Електронний Журнал ВІТ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Пошуковий рядок
          Padding(
            padding: const EdgeInsets.all(12.0),
            key: const ValueKey("search_bar"),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Пошук за ПІБ або палатою...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          // Список пацієнтів
          Expanded(
            child: _filteredPatients.isEmpty
                ? const Center(child: Text("Пацієнтів не знайдено"))
                : ListView.builder(
                    itemCount: _filteredPatients.length,
                    itemBuilder: (context, index) {
                      final p = _filteredPatients[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade800,
                            child: Text(p.roomNumber, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("МКХ: ${p.icdDiagnosis}\nВік: ${p.age} р."),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            // Переходимо в карту конкретного пацієнта
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DashboardScreen(patient: p)),
                            );
                            _loadPatients(); // Оновлюємо дані при поверненні
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E293B),
        onPressed: _showAddPatientDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
