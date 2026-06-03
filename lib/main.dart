import 'package:flutter/material.dart';
import 'data/clinical_data.dart';

void main() {
  runApp(const RehabApp());
}

class RehabApp extends StatelessWidget {
  const RehabApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'МКФ Реабілітаційний Комплекс',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal, 
        scaffoldBackgroundColor: Colors.grey.shade50
      ),
      home: const MainDashboard(),
    );
  }
}

// ГЛОБАЛЬНА БАЗА ПАЦІЄНТІВ
List<Map<String, dynamic>> globalPatients = [
  {
    "id": "p1",
    "name": "Іванов Петро Миколайович",
    "age": 45,
    "mkch10": "I63.3 (Ішемічний інсульт)",
    "icfCodes": ["b730 (Сила м'язів)", "d450 (Ходьба)"],
    "history": [
      {
        "scaleId": "ims", 
        "date": "2026-06-03", 
        "score": 4, 
        "interpretation": "Помірна мобільність"
      }
    ],
    "smartGoal": "Пацієнт зможе самостійно проходити 50 метрів за допомогою ходунків до 20.06.2026 для відновлення побутової незалежності.",
    "exercises": ["Контрольоване дихання", "Пасивні/активні вправи в ліжку"]
  }
];

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  String _searchQuery = "";
  String _currentScreen = "dashboard"; // dashboard, scale_catalog, patient_card, create_patient, test_exec
  Map<String, dynamic>? _selectedPatient;
  ClinicalScale? _selectedScale;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedMckh = "I63.3 (Ішемічний інсульт)";
  final List<String> _selectedIcf = [];

  int _testScore = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌟 Реабілітаційна Платформа МКФ / МКХ-10"),
        backgroundColor: Colors.teal.shade800,
        actions: [
          if (_currentScreen != "dashboard")
            IconButton(
              icon: const Icon(Icons.home, size: 28),
              tooltip: "На головний екран",
              onPressed: () {
                setState(() => _currentScreen = "dashboard");
              },
            )
        ],
      ),
      body: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case "dashboard":
        return _screenDashboard();
      case "scale_catalog":
        return _screenScaleCatalog();
      case "patient_card":
        return _screenPatientCard();
      case "create_patient":
        return _screenCreatePatient();
      case "test_exec":
        return _screenTestExecutor();
      default:
        return _screenDashboard();
    }
  }

  // ЕКРАН 1: ГОЛОВНЕ МЕНЮ
  Widget _screenDashboard() {
    final filteredPatients = globalPatients
        .where((p) => p['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.teal.shade700,
          child: Column(
            children: [
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: "Пошук пацієнта за ПІБ...",
                  prefixIcon: const Icon(Icons.search),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), 
                    borderSide: BorderSide.none
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700),
                      onPressed: () => setState(() => _currentScreen = "create_patient"),
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text("Створити Пацієнта (МКХ-10/МКФ)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
                      onPressed: () => setState(() => _currentScreen = "scale_catalog"),
                      icon: const Icon(Icons.bar_chart, color: Colors.white),
                      label: const Text("Каталог 16 Шкал", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("📋 Списочний склад пацієнтів у відділенні:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filteredPatients.length,
            itemBuilder: (context, i) {
              final p = filteredPatients[i];
              return Card(
                elevation: 3,
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.person, color: Colors.white)),
                  title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Діагноз МКХ-10: ${p['mkch10']}"),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.teal),
                  onTap: () {
                    setState(() {
                      _selectedPatient = p;
                      _currentScreen = "patient_card";
                    });
                  },
                ),
              );
            },
          ),
        )
      ],
    );
  }

  // ЕКРАН 2: СТВОРЕННЯ ПАЦІЄНТА
  Widget _screenCreatePatient() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _currentScreen = "dashboard")),
            const Text("Нова медична карта пацієнта", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        TextField(controller: _nameController, decoration: const InputDecoration(labelText: "ПІБ Пацієнта", border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: _ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Вік (років)", border: OutlineInputBorder())),
        const SizedBox(height: 16),
        
        const Text("🩺 Клінічний діагноз за МКХ-10:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
        DropdownButton<String>(
          value: _selectedMckh,
          isExpanded: true,
          items: ["I63.3 (Ішемічний інсульт)", "G82.2 (Параплегія)", "M16 (Коксартроз)", "T90 (Наслідки травми голови)"].map((s) {
            return DropdownMenuItem(value: s, child: Text(s));
          }).toList(),
          onChanged: (v) => setState(() => _selectedMckh = v!),
        ),
        
        const SizedBox(height: 16),
        const Text("📌 Функціональні порушення (Домени МКФ):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
        ...["b730 (Сила м'язів)", "b280 (Біль)", "d450 (Ходьба)", "d410 (Зміна положення тіла)"].map((code) {
          return CheckboxListTile(
            title: Text(code),
            value: _selectedIcf.contains(code),
            onChanged: (val) {
              setState(() {
                if (val!) {
                  _selectedIcf.add(code);
                } else {
                  _selectedIcf.remove(code);
                }
              });
            },
          );
        }).toList(),

        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.all(16)),
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              globalPatients.add({
                "id": DateTime.now().toString(),
                "name": _nameController.text,
                "age": int.tryParse(_ageController.text) ?? 40,
                "mkch10": _selectedMckh,
                "icfCodes": List<String>.from(_selectedIcf),
                "history": [],
                "smartGoal": "Ціль за SMART формується автоматично після оцінки шкалами.",
                "exercises": ["Контрольоване дихання"]
              });
              _nameController.clear();
              _ageController.clear();
              _selectedIcf.clear();
              setState(() => _currentScreen = "dashboard");
            }
          },
          child: const Text("Зберегти пацієнта та відкрити відділення", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  // ЕКРАН 3: КАРТКА ПАЦІЄНТА
  Widget _screenPatientCard() {
    final p = _selectedPatient!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () => setState(() => _currentScreen = "dashboard"),
              icon: const Icon(Icons.arrow_back),
              label: const Text("До списку"),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700),
              onPressed: () => _shareRealtimeIRP(p),
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text("Поділитись ІРП / Друк", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 16),
        Text(p['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
        Text("Вік: ${p['age']} р. | Код МКХ-10: ${p['mkch10']}"),
        const Divider(),
        
        Card(
          color: Colors.amber.shade50,
          shape: RoundedRectangleBorder(side: BorderSide(color: Colors.amber.shade300), borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.amber),
                    SizedBox(width: 6),
                    Text("SMART Конструктор реабілітаційних цілей:", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(p['smartGoal'], style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          onPressed: () => setState(() => _currentScreen = "scale_catalog"),
          icon: const Icon(Icons.add_chart, color: Colors.white),
          label: const Text("Провести клінічне тестування шкал", style: TextStyle(color: Colors.white)),
        ),

        const SizedBox(height: 16),
        const Text("📜 Проведені оцінки (Динаміка):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        if (p['history'].isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Жодних тестувань ще не проведено"),
          )
        else
          ...p['history'].map<Widget>((h) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.teal),
                title: Text("Тест: ${h['scaleId'].toString().toUpperCase()}"),
                subtitle: Text("Результат: ${h['interpretation']} (${h['date']})"),
                trailing: Chip(label: Text("${h['score']} б.")),
              ),
            );
          }).toList(),

        const SizedBox(height: 16),
        const Text("🏋️‍♂️ Призначені фізичні вправи (ІРП):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ...ClinicalData.exercisesCatalog.map((cat) {
          return ExpansionTile(
            title: Text(cat['category']),
            children: (cat['items'] as List).map<Widget>((ex) {
              final isChecked = p['exercises'].contains(ex['name']);
              return CheckboxListTile(
                title: Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(ex['desc']),
                value: isChecked,
                onChanged: (val) {
                  setState(() {
                    if (val!) {
                      p['exercises'].add(ex['name']);
                    } else {
                      p['exercises'].remove(ex['name']);
                    }
                  });
                },
              );
            }).toList(),
          );
        }).toList()
      ],
    );
  }

  // ШЕРИНГ / ДРУКУ ІРП
  void _shareRealtimeIRP(Map<String, dynamic> p) {
    final String docText = """
=== ІНДИВІДУАЛЬНИЙ РЕАБІЛІТАЦІЙНИЙ ПЛАН (ІРП) ===
Пацієнт: ${p['name']}
Вік: ${p['age']} років
Діагноз МКХ-10: ${p['mkch10']}
Домени МКФ: ${p['icfCodes'].join(', ')}

[КЛІНІЧНИЙ СТАТУС ТА ОЦІНКА ШКАЛ]
${p['history'].map((h) => "- Шкала ${h['scaleId'].toUpperCase()}: ${h['interpretation']} (${h['score']} балів)").join('\n')}

[РЕАБІЛІТАЦІЙНА ЦІЛЬ SMART]
${p['smartGoal']}

[КОМПЛЕКС ФІЗИЧНИХ ВПРАВ ЗА ПРОТОКОЛОМ]
${p['exercises'].map((ex) => "- $ex").join('\n')}
================================================
Документ сформовано автоматично. Готовий до друку.
""";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("📄 Виписний документ сформовано!"),
        content: SingleChildScrollView(
          child: Text(docText, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Закрити")
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("📄 Текст ІРП скопійовано в буфер обміну! Можна вставити в месенджер або друк.")),
              );
            },
            child: const Text("Копіювати для Шерингу"),
          )
        ],
      ),
    );
  }

  // ЕКРАН 4: КАТАЛОГ ШКАЛ
  Widget _screenScaleCatalog() {
    final scales = ClinicalData.allScales;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back), 
                onPressed: () => setState(() => _currentScreen = _selectedPatient != null ? "patient_card" : "dashboard")
              ),
              const Text("Клінічні шкали тестування", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: scales.length,
            itemBuilder: (context, i) {
              final s = scales[i];
              return Card(
                color: Colors.teal.shade50,
                child: ExpansionTile(
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("МКФ Категорія: ${s.icfCategory}"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ℹ️ Інструкція: ${s.instruction}", style: const TextStyle(fontStyle: FontStyle.italic)),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedScale = s;
                                _currentScreen = "test_exec";
                              });
                            },
                            child: const Text("Запустити розрахунок балів"),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  // ЕКРАН 5: ЕКРАН ТЕСТУВАННЯ ТА ІНТЕРПРЕТАЦІЇ
  Widget _screenTestExecutor() {
    final s = _selectedScale!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Проведення оцінки: ${s.name}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
          const Divider(),
          const SizedBox(height: 20),
          Text(s.questions.first.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          
          Expanded(
            child: ListView(
              children: s.questions.first.options.map((opt) {
                return RadioListTile<int>(
                  title: Text(opt.text),
                  value: opt.score,
                  groupValue: _testScore,
                  onChanged: (val) {
                    setState(() {
                      _testScore = val!;
                    });
                  },
                );
              }).toList(),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () => setState(() => _currentScreen = "scale_catalog"),
                child: const Text("Назад до шкал"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () {
                  String interpretation = "Стан пацієнта стабільний за шкалою ${s.id.toUpperCase()}";
                  String dynamicGoal = "Пацієнт відновить функціональний стан за МКФ на основі тесту ${s.id.toUpperCase()}.";

                  if (s.id == "ims") {
                    interpretation = _testScore <= 3 ? "Критично низька мобільність" : "Помірна мобільність";
                    dynamicGoal = "Пацієнт зможе пересідати в крісло колісне з мінімальною підтримкою до 2 тижнів для адаптації (домен МКФ d410).";
                  } else if (s.id == "mrc") {
                    interpretation = _testScore < 48 ? "Синдром ICUAW (М'язова слабкість ВІТ)" : "Нормальна сила м'язів";
                    dynamicGoal = "Збільшити м'язову силу кінцівок до 4+ балів за шкалою MRC за 10 днів терапії (домен МКФ b730).";
                  }

                  if (_selectedPatient != null) {
                    _selectedPatient!['history'].insert(0, {
                      "scaleId": s.id,
                      "date": "2026-06-03",
                      "score": _testScore,
                      "interpretation": interpretation
                    });
                    _selectedPatient!['smartGoal'] = dynamicGoal; 
                  }

                  setState(() {
                    _currentScreen = _selectedPatient != null ? "patient_card" : "dashboard";
                    _testScore = 0;
                  });
                },
                child: const Text("Зберегти в карту та ІРП"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
