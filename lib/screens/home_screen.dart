import 'package:flutter/material.dart';
import 'scales_list_screen.dart';
import '../data/clinical_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Демонстраційний список пацієнтів (імітація бази даних)
  final List<Map<String, dynamic>> _patients = [
    {
      "id": "p1",
      "name": "Іванов Петро Миколайович",
      "age": 45,
      "diagnosis": "ГПМК (Інсульт), лівобічний геміпарез. Гострий період.",
      "history": [
        {"scaleId": "ims", "date": "2026-06-01", "score": 3, "interpretation": "Помірна мобільність (межі палати з підтримкою)"},
        {"scaleId": "vas", "date": "2026-06-01", "score": 2, "interpretation": "Слабкий біль (допускаються всі види вправ)"}
      ]
    },
    {
      "id": "p2",
      "name": "Сидоренко Ольга Володимирівна",
      "age": 62,
      "diagnosis": "Стан після ШВЛ, Набута слабкість у відділенні інтенсивної терапії (ICUAW).",
      "history": [
        {"scaleId": "mrc", "date": "2026-05-28", "score": 42, "interpretation": "Синдром ICUAW (набута слабкість м'язів у ВІТ)"}
      ]
    }
  ];

  // Функція для відкриття детальної карти пацієнта зі шкалами та вправами
  void _openPatientCard(Map<String, dynamic> patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16.0),
              children: [
                // Шапка картки пацієнта
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "📊 КАРТКА ПАЦІЄНТА",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                Text(
                  patient['name'],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text("Вік: ${patient['age']} років", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(
                  "Діагноз: ${patient['diagnosis']}",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const Divider(height: 30),

                // Секція 1: Історія проведених тестувань
                const Text(
                  "📜 Результати клінічних оцінок (Історія шкал)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 8),
                if (patient['history'].isEmpty)
                  const Text("Тестувань ще не проводилось", style: TextStyle(fontStyle: FontStyle.italic))
                else
                  ...patient['history'].map<Widget>((session) {
                    return Card(
                      color: Colors.grey.shade50,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.assignment_turned_in, color: Colors.teal),
                        title: Text("Шкала: ${session['scaleId'].toString().toUpperCase()} (${session['date']})"),
                        subtitle: Text("Результат: ${session['interpretation']}"),
                        trailing: session['score'] != 0 
                            ? Chip(label: Text("${session['score']} б.")) 
                            : null,
                      ),
                    );
                  }).toList(),

                const Divider(height: 30),

                // Секція 2: Призначені вправи (Каталог МОЗ)
                const Text(
                  "🏋️‍♂️ Рекомендований протокол фізичної терапії",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 8),
                ...ClinicalData.exercisesCatalog.map<Widget>((cat) {
                  return ExpansionTile(
                    title: Text(cat['category'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    children: (cat['items'] as List).map<Widget>((item) {
                      return ListTile(
                        title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text(item['desc'], style: const TextStyle(fontSize: 13, height: 1.3)),
                        leading: const Icon(Icons.check_box_outline_blank, color: Colors.teal, size: 20),
                      );
                    }).toList(),
                  );
                }).toList(),
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
        title: const Text('Пацієнти та Реабілітація'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScalesListScreen()),
              );
            },
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _patients.length,
        itemBuilder: (context, index) {
          final patient = _patients[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(
                patient['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                patient['diagnosis'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () => _openPatientCard(patient),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScalesListScreen()),
          );
        },
        backgroundColor: Colors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Клінічні шкали", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
