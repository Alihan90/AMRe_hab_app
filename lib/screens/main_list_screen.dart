import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/patient.dart';
import 'patient_card_screen.dart';
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
    List<Patient> mock = [
      Patient(id: "1", fullName: "Іванов Петро Сидорович", age: 54, chamber: "ВІТ-2, ліжко 3", diagnosis: "ГПМК, правобічний геміпарез", currentSmartGoal: "Стабілізація сидячи 10 хв"),
      Patient(id: "2", fullName: "Сидоров Олег Миколайович", age: 43, chamber: "ВІТ-1, ліжко 1", diagnosis: "ЧМТ, забій головного мозку", currentSmartGoal: "Збільшення мобільності в ліжку"),
    ];
    setState(() {
      _patients = mock;
      _filteredPatients = mock;
    });
    await prefs.setString('patients_list', json.encode(mock.map((p) => p.toMap()).toList()));
  }

  void _filterPatients() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPatients = _patients.where((p) => p.fullName.toLowerCase().contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("ВІТ Реабілітація", style: TextStyle(color: Colors.white, fontWeight: Colors.bold)),
      ),
      body: Column(
        children: [
          // Блок швидкого переходу до загальних шкал
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
                const Text("Клінічні оцінки та шкали", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: Colors.bold)),
                const SizedBox(height: 4),
                const Text("Швидкий доступ до інструкцій та калькуляторів без прив'язки до картки пацієнта.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700, foregroundColor: Colors.white),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ScalesScreen(patient: null))),
                  icon: const Icon(Icons.Assessment),
                  label: const Text("Відкрити каталог шкал"),
                )
              ],
            ),
          ),
          // Пошук пацієнтів
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
          // Список пацієнтів
          Expanded(
            child: _filteredPatients.isEmpty
                ? const Center(child: Text("Пацієнтів не знайдено"))
                : ListView.builder(
                    itemCount: _filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = _filteredPatients[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: Color(0xFF334155), child: Icon(Icons.person, color: Colors.white)),
                          title: Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text("${patient.chamber} • ${patient.diagnosis}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PatientCardScreen(patient: patient))).then((_) => _loadPatients()),
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
