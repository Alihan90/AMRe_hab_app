import 'package:flutter/material.dart';
import 'scales_list_screen.dart';
import 'test_executor_screen.dart';
import '../data/clinical_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Демонстраційна база даних пацієнтів з повною клінічною картиною
  final List<Map<String, dynamic>> _patients = [
    {
      "id": "p1",
      "name": "Іванов Петро Миколайович",
      "age": 45,
      "gender": "Чоловік",
      "chamber": "Палата №302",
      "dateIn": "2026-05-20",
      "diagnosis": "Гострий порушення мозкового кровообігу (Ішемічний інсульт в басейні правої СМА), лівобічний геміпарез, виражені порушення ходьби та рівноваги.",
      "icfStatus": "b730.3 (Тяжке порушення функцій сили м'язів), d450.2 (Помірне порушення функції ходьби)",
      "history": [
        {"scaleId": "ims", "date": "2026-06-01", "score": 3, "interpretation": "Помірна мобільність (межі палати з підтримкою)"},
        {"scaleId": "vas", "date": "2026-06-01", "score": 2, "interpretation": "Слабкий біль (допускаються всі види вправ)"},
        {"scaleId": "rass", "date": "2026-05-22", "score": 0, "interpretation": "Норма (спокійний, уважний)"}
      ]
    },
    {
      "id": "p2",
      "name": "Сидоренко Ольга Володимирівна",
      "age": 62,
      "gender": "Жінка",
      "chamber": "ВІТ (Реанімація), ліжко 2",
      "dateIn": "2026-05-15",
      "diagnosis": "Стан після тривалої ШВЛ (позалікарняна полісегментарна пневмонія). Набута слабкість у відділенні інтенсивної терапії (ICUAW). Severe deconditioning.",
      "icfStatus": "b440.2 (Помірне порушення дихальних функцій), b730.3 (Тяжке зниження сили м'язів)",
      "history": [
        {"scaleId": "mrc", "date": "2026-05-28", "score": 42, "interpretation": "Синдром ICUAW (набута слабкість м'язів у ВІТ)"}
      ]
    }
  ];

  // Логіка запуску тесту для пацієнта
  void _startTestForPatient(Map<String, dynamic> patient) async {
    final scale = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (context) => const ScalesListScreen()),
    );

    if (scale != null) {
      final result = await Navigator.push<dynamic>(
        context,
        MaterialPageRoute(builder: (context) => TestExecutorScreen(scale: scale)),
      );

      if (result != null) {
        setState(() {
          patient['history'].insert(0, result);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Результат тесту ${scale.id.toUpperCase()} збережено для пацієнта!'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    }
  }

  // Детальна клінічна картка пацієнта з вкладками
  void _openDetailedPatientCard(Map<String, dynamic> patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: DefaultTabController(
            length: 3, // Три повноцінні вкладки архітектури додатку
            child: Column(
              children: [
                // Кастомний красивий заголовок картки
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              patient['chamber'],
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.teal),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                      Text(
                        patient['name'],
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${patient['gender']}, ${patient['age']} років • Дата госпіталізації: ${patient['dateIn']}",
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 10),
                      // Перемикач вкладок (Дизайн та Навігація)
                      const TabBar(
                        labelColor: Colors.teal,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.teal,
                        indicatorWeight: 3,
                        tabs: [
                          Tab(icon: Icon(Icons.assignment), text: "Анамнез / МКФ"),
                          Tab(icon: Icon(Icons.analytics), text: "Оцінка (Шкали)"),
                          Tab(icon: Icon(Icons.fitness_center), text: "Втручання"),
                        ],
                      ),
                    ],
                  ),
                ),

                // Вміст вкладок картки пацієнта
                Expanded(
                  child: TabBarView(
                    children: [
                      // ВКЛАДКА 1: Клінічний анамнез та кодування МКФ
                      ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          const Text("Клінічний діагноз:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                          const SizedBox(height: 6),
                          Text(patient['diagnosis'], style: const TextStyle(fontSize: 15, height: 1.4)),
                          const Divider(height: 30),
                          const Text("Поточний статус за МКФ:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                          const SizedBox(height: 6),
                          Card(
                            color: Colors.orange.shade50,
                            borderOnForeground: true,
                            shape: RoundedRectangleBorder(side: BorderSide(color: Colors.orange.shade200), borderRadius: BorderRadius.circular(8)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(patient['icfStatus'], style: TextStyle(fontSize: 14, color: Colors.orange.shade900, fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ],
                      ),

                      // ВКЛАДКА 2: Історія шкал та запуск нових тестів
                      ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _startTestForPatient(patient);
                            },
                            icon: const Icon(Icons.add_chart, color: Colors.white),
                            label: const Text("Провести нове тестування", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text("Історія обстежень пацієнта:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                          const SizedBox(height: 10),
                          if (patient['history'].isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Text("Жодної шкали ще не проведено.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey), textAlign: Center),
                            )
                          else
                            ...patient['history'].map<Widget>((session) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                elevation: 1.5,
                                child: ListTile(
                                  leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.done, color: Colors.white, size: 18)),
                                  title: Text(
                                    "Шкала: ${session['scaleId'].toString().toUpperCase()}",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2),
                                      Text("Статус: ${session['interpretation']}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                      Text("Дата: ${session['date']}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                  trailing: session['score'] != 0 
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.teal.shade100, borderRadius: BorderRadius.circular(12)),
                                          child: Text("${session['score']} бал.", style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                        ],
                      ),

                      // ВКЛАДКА 3: Призначення фізичних вправ (Протоколи МОЗ)
                      ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                            child: Text(
                              "Призначені терапевтичні втручання:",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
                            ),
                          ),
                          ...ClinicalData.exercisesCatalog.map<Widget>((cat) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 1,
                              child: ExpansionTile(
                                leading: const Icon(Icons.accessibility_new, color: Colors.teal),
                                title: Text(cat['category'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                                children: (cat['items'] as List).map<Widget>((item) {
                                  return Container(
                                    decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))),
                                    child: ListTile(
                                      title: Text(item['name'], style: const TextStyle(vertical: 2, fontWeight: FontWeight.w600, fontSize: 14, color: Colors.teal)),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 4.0, bottom: 6.0),
                                        child: Text(item['desc'], style: const TextStyle(fontSize: 13, height: 1.3, color: Colors.black54)),
                                      ),
                                      leading: const Icon(Icons.check_box, color: Colors.teal, size: 22),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Клінічне відділення регенерації'),
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Інформаційний банер зверху екрана
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.teal.shade700,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Робоче місце фізичного терапевта",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  "МКФ-орієнтоване ведення пацієнтів та 16 діагностичних шкал",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Активні медичні карти пацієнтів:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),

          // Список пацієнтів у відділенні
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _patients.length,
              itemBuilder: (context, index) {
                final patient = _patients[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.teal.shade100,
                      child: const Icon(Icons.elderly_rounded, color: Colors.teal, size: 28),
                    ),
                    title: Text(
                      patient['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        patient['diagnosis'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.2),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.teal),
                    onTap: () => _openDetailedPatientCard(patient),
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
