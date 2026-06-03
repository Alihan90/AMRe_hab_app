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
    // Використовуємо універсальний імпорт з мапи, щоб обійти відсутні поля в конструкторі
    List<Map<String, dynamic>> mockData = [
      {"id": "1", "fullName": "Іванов Петро Сидорович", "age": 54, "chamber": "ВІТ-2", "diagnosis": "ГПМК", "currentSmartGoal": "Стабілізація сидячи"},
      {"id": "2", "fullName": "Сидоров Олег Миколайович", "age": 43, "chamber": "ВІТ-1", "diagnosis": "ЧМТ", "currentSmartGoal": "Мобільність в ліжку"}
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("ВІТ Реабілітація", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: Color(0xFF334155), child: Icon(Icons.person, color: Colors.white)),
                          title: Text(patient.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(patient.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
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
