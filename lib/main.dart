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
      title: 'Клінічний Комплекс ФТ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey.shade50,
        cardTheme: const CardTheme(elevation: 3, margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4)),
      ),
      home: const MainDashboard(),
    );
  }
}

// СИСТЕМА ЕЛЕКТРОННОГО ЗДОРОВ'Я ПАЦІЄНТІВ (З ПІДТРИМКОЮ СЕСІЙНИХ ОГЛЯДІВ ЗА ДАТАМИ)
List<Map<String, dynamic>> globalPatients = [
  {
    "id": "p_1",
    "name": "Іванов Петро Миколайович",
    "age": 45,
    "mkch10Code": "I63.3",
    "mkch10Name": "Інфаркт мозку внаслідок тромбозу церебральних артерій (Ішемічний інсульт)",
    "icfCodes": ["b730 (Сила м'язів)", "d450 (Ходьба)", "d415 (Баланс)"],
    // Огляди пацієнта розбиті по конкретних днях (Сесіях)
    "sessions": [
      {
        "date": "2026-06-02",
        "scalesData": [
          {"scaleId": "ims", "scaleName": "IMS", "score": 3, "interpretation": "Активне утримання сидячого положення на краю ліжка"}
        ],
        "assignedExercises": ["Діафрагмальне дихання", "Пасивна суглобова гімнастика"],
        "smartGoal": "Пацієнт зможе самостійно утримувати положення сидячи на краю ліжка (домен d415) більше 5 хвилин для підготовки до вертикалізації до 08.06.2026."
      }
    ]
  }
];

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  String _currentScreen = "dashboard"; // dashboard, patients_list, create_patient, patient_card, scales_catalog, mckh_catalog, exercises_catalog, test_exec
  
  // Пошукові рушії
  String _globalSearch = "";
  String _patientSearch = "";
  String _scaleSearch = "";
  String _mckhSearch = "";
  String _exerciseSearch = "";

  Map<String, dynamic>? _selectedPatient;
  Map<String, dynamic>? _activeSession; // Поточний день огляду, з яким ми працюємо
  ClinicalScale? _selectedScale;
  
  // Стан покрокового проходження тестів
  int _currentQuestionIndex = 0;
  int _accumulatedScore = 0;
  List<int> _bbsAnswers = []; // Локальний буфер для 14 відповідей Берга

  // Контролери нової карти
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  Map<String, String> _chosenMckh = ClinicalData.mckh10Catalog.first;
  final List<String> _chosenIcfCodes = [];

  // Тимчасовий буфер для вправ поточного дня
  List<String> _tempSelectedExercises = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.teal.shade900,
        actions: [
          if (_currentScreen != "dashboard")
            IconButton(
              icon: const Icon(Icons.grid_view, size: 28, color: Colors.white),
              tooltip: "На головний екран",
              onPressed: () => setState(() => _currentScreen = "dashboard"),
            )
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          _handleBackButton();
          return false;
        },
        child: _buildBody(),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentScreen) {
      case "dashboard": return "🏥 Головне Меню ФТ";
      case "patients_list": return "👥 Реєстр Пацієнтів";
      case "create_patient": return "📝 Формування Карти";
      case "patient_card": return "🗂 Електронна Карта Пацієнта";
      case "scales_catalog": return "📊 Діагностичні Шкали (16)";
      case "mckh_catalog": return "🩺 Довідник МКХ-10";
      case "exercises_catalog": return "🏋️‍♂️ Реабілітаційні Комплекси";
      case "test_exec": return "⏱ Покроковий Клінічний Тест";
      default: return "Клінічний Комплекс";
    }
  }

  void _handleBackButton() {
    setState(() {
      if (_currentScreen == "patient_card" || _currentScreen == "create_patient") {
        _currentScreen = "patients_list";
      } else if (_currentScreen == "test_exec") {
        _currentScreen = "scales_catalog";
      } else {
        _currentScreen = "dashboard";
      }
    });
  }

  Widget _buildBody() {
    switch (_currentScreen) {
      case "dashboard": return _screenDashboard();
      case "patients_list": return _screenPatientsList();
      case "create_patient": return _screenCreatePatient();
      case "patient_card": return _screenPatientCard();
      case "scales_catalog": return _screenScalesCatalog();
      case "mckh_catalog": return _screenMckhCatalog();
      case "exercises_catalog": return _screenExercisesCatalog();
      case "test_exec": return _screenTestExecutor();
      default: return _screenDashboard();
    }
  }

  // =========================================================
  // ЕКРАН: ГОЛОВНЕ МЕНЮ З ГЛОБАЛЬНИМ ПОШУКОМ ПАЦІЄНТІВ
  // =========================================================
  Widget _screenDashboard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.teal.shade800,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Швидкий глобальний пошук карти пацієнта:", style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                onChanged: (v) => setState(() => _globalSearch = v),
                decoration: InputDecoration(
                  hintText: "Введіть ПІБ для миттєвого виклику ІРП...",
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _globalSearch.isNotEmpty 
            ? _buildGlobalSearchResults() 
            : GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: [
                  _buildMenuCard("👥 Пацієнти", "Реєстр, щоденні огляди, формування ІРП", Colors.blue.shade700, () => setState(() => _currentScreen = "patients_list")),
                  _buildMenuCard("📊 Шкали Оцінки", "16 шкал, покрокові інтерактивні тести", Colors.teal.shade700, () => setState(() => _currentScreen = "scales_catalog")),
                  _buildMenuCard("🩺 МКХ-10", "Повний спектр кодів та домени МКФ", Colors.purple.shade700, () => setState(() => _currentScreen = "mckh_catalog")),
                  _buildMenuCard("🏋️‍♂️ Вправи", "Повні протоколи терапевтичних втручань", Colors.orange.shade800, () => setState(() => _currentScreen = "exercises_catalog")),
                ],
              ),
        )
      ],
    );
  }

  Widget _buildGlobalSearchResults() {
    final matches = globalPatients.where((p) => p['name'].toLowerCase().contains(_globalSearch.toLowerCase())).toList();
    if (matches.isEmpty) return const Center(child: Text("За вказаним ПІБ пацієнтів не знайдено."));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: matches.length,
      itemBuilder: (context, i) {
        final p = matches[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.account_box, color: Colors.teal, size: 36),
            title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Код: ${p['mkch10Code']} | Сесій огляду: ${p['sessions'].length}"),
            onTap: () => setState(() { 
              _selectedPatient = p; 
              _activeSession = p['sessions'].first;
              _tempSelectedExercises = List<String>.from(_activeSession!['assignedExercises']);
              _currentScreen = "patient_card"; 
            }),
          ),
        );
      },
    );
  }

  Widget _buildMenuCard(String title, String desc, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 3),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ЕКРАН: РЕЄСТР КАРТОК ПАЦІЄНТІВ
  // =========================================================
  Widget _screenPatientsList() {
    final filtered = globalPatients.where((p) => p['name'].toLowerCase().contains(_patientSearch.toLowerCase())).toList();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _currentScreen = "dashboard")),
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _patientSearch = v),
                  decoration: const InputDecoration(labelText: "Пошук пацієнта в базі...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, minimumSize: const Size.fromHeight(48)),
            onPressed: () => setState(() => _currentScreen = "create_patient"),
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text("ЗАРЕЄСТРУВАТИ НОВУ КАРТУ ПАЦІЄНТА", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final p = filtered[i];
                return Card(
                  child: ListTile(
                    title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Діагноз: ${p['mkch10Code']} | Кількість проведених оглядів: ${p['sessions'].length}"),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.teal),
                    onTap: () => setState(() { 
                      _selectedPatient = p; 
                      _activeSession = p['sessions'].first;
                      _tempSelectedExercises = List<String>.from(_activeSession!['assignedExercises']);
                      _currentScreen = "patient_card"; 
                    }),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // =========================================================
  // ЕКРАН: СТВОРЕННЯ МЕДИЧНОЇ КАРТИ ПАЦІЄНТА
  // =========================================================
  Widget _screenCreatePatient() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _currentScreen = "patients_list")),
            const Text("Первинне заведення медичної карти", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        const Divider(),
        TextField(controller: _nameController, decoration: const InputDecoration(labelText: "ПІБ Пацієнта (Повністю)", border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: _ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Вік (повних років)", border: OutlineInputBorder())),
        const SizedBox(height: 16),
        const Text("🩺 Профільний діагноз МКХ-10 (Оберіть із клінічної бази):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
          child: DropdownButton<Map<String, String>>(
            value: _chosenMckh,
            isExpanded: true,
            underline: const SizedBox(),
            items: ClinicalData.mckh10Catalog.map((item) {
              return DropdownMenuItem(value: item, child: Text("${item['code']} - ${item['name']}", style: const TextStyle(fontSize: 12)));
            }).toList(),
            onChanged: (v) => setState(() => _chosenMckh = v!),
          ),
        ),
        const SizedBox(height: 16),
        const Text("📌 Функціональний дефіцит за доменами МКФ:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
        ...ClinicalData.icfDomains.map((domain) {
          final stringRepresentation = "${domain['code']} ${domain['name']}";
          return CheckboxListTile(
            title: Text(stringRepresentation, style: const TextStyle(fontSize: 12)),
            value: _chosenIcfCodes.contains(stringRepresentation),
            onChanged: (val) {
              setState(() {
                if (val!) { _chosenIcfCodes.add(stringRepresentation); } else { _chosenIcfCodes.remove(stringRepresentation); }
              });
            },
          );
        }).toList(),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800, padding: const EdgeInsets.all(16)),
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              final newPatient = {
                "id": "p_${DateTime.now().millisecondsSinceEpoch}",
                "name": _nameController.text,
                "age": int.tryParse(_ageController.text) ?? 50,
                "mkch10Code": _chosenMckh['code'],
                "mkch10Name": _chosenMckh['name'],
                "icfCodes": List<String>.from(_chosenIcfCodes),
                "sessions": [
                  {
                    "date": "2026-06-03",
                    "scalesData": [],
                    "assignedExercises": <String>[],
                    "smartGoal": "Ціль за SMART сформується автоматично після проведення тестувань шкалами."
                  }
                ]
              };
              globalPatients.add(newPatient);
              _nameController.clear(); _ageController.clear(); _chosenIcfCodes.clear();
              setState(() {
                _selectedPatient = newPatient;
                _activeSession = newPatient['sessions'].first;
                _tempSelectedExercises = [];
                _currentScreen = "patient_card";
              });
            }
          },
          child: const Text("ЗБЕРЕГТИ КАРТКУ В БАЗУ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  // =========================================================
  // ЕКРАН: КАРТКА ПАЦІЄНТА ТА СЕСІЙНІ ОГЛЯДИ (ЯДРО EHR)
  // =========================================================
  Widget _screenPatientCard() {
    final p = _selectedPatient!;
    final List sessionsList = p['sessions'];

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(onPressed: () => setState(() => _currentScreen = "patients_list"), icon: const Icon(Icons.arrow_back), label: const Text("Реєстр")),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade900),
              onPressed: () => _showComprehensiveClinicalReport(p),
              icon: const Icon(Icons.print_outlined, color: Colors.white),
              label: const Text("ОФІЦІЙНИЙ ЕПІКРИЗ (ОБ'ЄДНАНИЙ)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
            )
          ],
        ),
        const SizedBox(height: 12),
        // Паспортна частина карти
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.teal.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 4),
              Text("Вік: ${p['age']} років | МКХ-10: ${p['mkch10Code']} - ${p['mkch10Name']}", style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text("Коди МКФ: ${p['icfCodes'].join('; ')}", style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
        ),
        const Divider(height: 24),

        // СЕЛЕКТОР ДАТИ ОГЛЯДУ (КЛІНІЧНІ СЕСІЇ)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("📅 Огляд за дату:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
              onPressed: () {
                _createNewSessionForSelectedPatient(p);
              },
              icon: const Icon(Icons.calendar_today, size: 14, color: Colors.white),
              label: const Text("СТВОРІТИ НОВИЙ ВІЗИТ (ДЕНЬ)", style: TextStyle(fontSize: 10, color: Colors.white)),
            )
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sessionsList.length,
            itemBuilder: (context, idx) {
              final sess = sessionsList[idx];
              final isCurrent = sess == _activeSession;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(sess['date'], style: TextStyle(color: isCurrent ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                  selected: isCurrent,
                  selectedColor: Colors.teal.shade700,
                  backgroundColor: Colors.grey.shade300,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _activeSession = sess;
                        _tempSelectedExercises = List<String>.from(sess['assignedExercises']);
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),
        
        // ВНУТРІШНІ ДАНІ ДЛЯ ОБРАНОЇ СЕСІЇ (ОГЛЯДУ)
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("📋 Статус візиту [${_activeSession!['date']}]", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    IconButton(
                      icon: const Icon(Icons.share, size: 18, color: Colors.teal),
                      tooltip: "Сформувати виписку лише за цей день",
                      onPressed: () => _showSingleSessionReport(p, _activeSession!),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                // МЕДИЧНА ЦІЛЬ ЗА СИСТЕМОЮ SMART
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.amber)),
                  child: Text("🎯 SMART-ціль сесії: ${_activeSession!['smartGoal']}", style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800, minimumSize: const Size.fromHeight(36)),
                  onPressed: () => setState(() => _currentScreen = "scales_catalog"),
                  icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                  label: const Text("Запустити тестування шкалами на цей день", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 12),
                const Text("Результати шкал за цей огляд:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                if ((_activeSession!['scalesData'] as List).isEmpty)
                  const Padding(padding: EdgeInsets.all(8.0), child: Text("Шкали ще не проводились у цей день.", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)))
                else
                  ...(_activeSession!['scalesData'] as List).map<Widget>((sc) {
                    return ListTile(
                      dense: true,
                      leading: Chip(label: Text(sc['scaleName'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.teal),
                      title: Text("Результат: ${sc['score']} балів", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(sc['interpretation'], style: const TextStyle(fontSize: 11)),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),
        // БЛОК ВПРАВ З ЖОРСТКОЮ КНОПКОЮ ЗБЕРЕЖЕННЯ В ІРП
        const Text("🏋️‍♂️ Призначення фізичних вправ на цей день огляду:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.teal)),
        const SizedBox(height: 4),
        ...ClinicalData.exercisesCatalog.map((cat) {
          return ExpansionTile(
            title: Text(cat['category'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.indigo)),
            children: (cat['items'] as List).map<Widget>((ex) {
              final isChecked = _tempSelectedExercises.contains(ex['name']);
              return CheckboxListTile(
                title: Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                subtitle: Text(ex['desc'], style: const TextStyle(fontSize: 11)),
                value: isChecked,
                onChanged: (val) {
                  setState(() {
                    if (val!) {
                      _tempSelectedExercises.add(ex['name']);
                    } else {
                      _tempSelectedExercises.remove(ex['name']);
                    }
                  });
                },
              );
            }).toList(),
          );
        }).toList(),
        
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade900, padding: const EdgeInsets.all(14)),
          onPressed: () {
            setState(() {
              _activeSession!['assignedExercises'] = List<String>.from(_tempSelectedExercises);
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green.shade800,
              content: Text("💾 Комплекс вправ успішно зафіксовано в ІРП за день ${_activeSession!['date']}!"),
            ));
          },
          icon: const Icon(Icons.save, color: Colors.white),
          label: const Text("💾 ЗБЕРЕГТИ КОМПЛЕКС ВПРАВ В ІРП ЦЬОГО ДНЯ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  void _createNewSessionForSelectedPatient(Map<String, dynamic> p) {
    // Автоматично вираховуємо наступний день для сесії
    final List sessions = p['sessions'];
    final lastDateStr = sessions.first['date']; // Останній доданий завжди попереду
    final parts = lastDateStr.split('-');
    int day = int.parse(parts[2]) + 1;
    String dayStr = day < 10 ? "0$day" : "$day";
    String newDate = "${parts[0]}-${parts[1]}-$dayStr";

    final newSess = {
      "date": newDate,
      "scalesData": [],
      "assignedExercises": <String>[],
      "smartGoal": "Ціль за SMART адаптується після проведення нових вимірів."
    };

    setState(() {
      sessions.insert(0, newSess); // Додаємо на початок списку
      _activeSession = newSess;
      _tempSelectedExercises = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Створено чистий огляд на нову дату: $newDate. Проведіть повторне тестування."),
    ));
  }

  // =========================================================
  // ЕКРАН: КАТАЛОГ ШКАЛ ОЦІНКИ ТА ЗАПУСК ПОКРОКОВИХ ТЕСТІВ
  // =========================================================
  Widget _screenScalesCatalog() {
    final filtered = ClinicalData.allScales.where((s) => s.name.toLowerCase().contains(_scaleSearch.toLowerCase()) || s.fullName.toLowerCase().contains(_scaleSearch.toLowerCase())).toList();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _currentScreen = _selectedPatient != null ? "patient_card" : "dashboard")),
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _scaleSearch = v),
                  decoration: const InputDecoration(labelText: "Пошук серед 16 шкал оцінки...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final s = filtered[i];
                return Card(
                  color: Colors.teal.shade50,
                  child: ExpansionTile(
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                    subtitle: Text(s.fullName, style: const TextStyle(fontSize: 11)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("📌 Домен МКФ: ${s.icfCategory}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text("📋 Показання: ${s.indications}", style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text("ℹ️ Інструкція проведення: ${s.instruction}", style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black87)),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800),
                              onPressed: () {
                                setState(() {
                                  _selectedScale = s;
                                  _currentQuestionIndex = 0;
                                  _accumulatedScore = 0;
                                  _bbsAnswers.clear();
                                  _currentScreen = "test_exec";
                                });
                              },
                              icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                              label: Text("ЗАПУСТИТИ ПОВНИЙ ПОКРОКОВИЙ ТЕСТ (${s.questions.length} ПУНКТІВ)", style: const TextStyle(color: Colors.white)),
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
      ),
    );
  }

  // =========================================================
  // ЕКРАН: ПОКРОКОВИЙ ІНТЕРАКТИВНИЙ КОНСТРУКТОР ТЕСТІВ
  // =========================================================
  Widget _screenTestExecutor() {
    final s = _selectedScale!;
    final totalQuestions = s.questions.length;
    final q = s.questions[_currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: (_currentQuestionIndex + 1) / totalQuestions, backgroundColor: Colors.grey.shade300, color: Colors.teal),
          const SizedBox(height: 12),
          Text("Шкала: ${s.fullName}", style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text("Пункт ${_currentQuestionIndex + 1} з $totalQuestions", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
            child: Text(q.text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black900)),
          ),
          const SizedBox(height: 14),
          const Text("Оберіть фактичну відповідь або дію пацієнта:", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              itemCount: q.options.length,
              itemBuilder: (context, idx) {
                final opt = q.options[idx];
                return Card(
                  elevation: 1,
                  child: ListTile(
                    title: Text(opt.text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    trailing: CircleAvatar(backgroundColor: Colors.teal.shade700, radius: 14, child: Text("${opt.score}", style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold))),
                    onTap: () {
                      _handleOptionSelected(opt.score);
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            onPressed: () => setState(() => _currentScreen = "scales_catalog"),
            child: const Text("Перервати тест"),
          )
        ],
      ),
    );
  }

  void _handleOptionSelected(int score) {
    final s = _selectedScale!;
    _bbsAnswers.add(score);
    _accumulatedScore += score;

    if (_currentQuestionIndex < s.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // ТЕСТ ЗАКІНЧЕНО — АВТОМАТИЧНИЙ КЛІНІЧНИЙ КАЛЬКУЛЯТОР ТА SMART-ПРОГНОЗУВАЧ
      int finalCalculatedScore = _accumulatedScore;
      if (s.id == "bbs") {
        // Для Берга вираховуємо точну суму всіх 14 відповідей
        finalCalculatedScore = _bbsAnswers.reduce((a, b) => a + b);
      }

      String interpretation = "Стабільний стан за шкалою ${s.name}";
      String smartGoal = "Пацієнт покращить рухові можливості в межах доменів МКФ.";

      if (s.id == "bbs") {
        if (finalCalculatedScore <= 20) {
          interpretation = "Сума: $finalCalculatedScore балів. Високий ризик падінь! Пацієнт прикутий до візка.";
          smartGoal = "Безпечне пересаджування (домен d510) та утримання балансу сидячи без опори більше 10 хв за допомогою рук до 15.06.2026.";
        } else if (finalCalculatedScore <= 40) {
          interpretation = "Сума: $finalCalculatedScore балів. Помірний ризик падінь, пересування з ходунками.";
          smartGoal = "Пацієнт зможе стояти без підтримки (домен d415) протягом 1 хвилини та здійснювати розвороти на місці до 20.06.2026.";
        } else {
          interpretation = "Сума: $finalCalculatedScore балів. Низький ризик падінь. Безпечна автономна ходьба.";
          smartGoal = "Досягнення повної координації ходьби та утримання балансу на одній нозі більше 10 секунд (домен d415) до 25.06.2026.";
        }
      } else if (s.id == "ashworth") {
        interpretation = "Тонус за Ешвортом: $finalCalculatedScore балів. " + (finalCalculatedScore >= 3 ? "Виражена спастична контрактура ригідності." : "Легка/помірна спастичність кінцівки.");
        smartGoal = "Знизити тонус в ураженому суглобі до 1+ балів за Ешвортом за допомогою укладань та PNF-технік до 12.06.2026 (домен b735).";
      } else if (s.id == "rass") {
        interpretation = "Рівень седації RASS: $finalCalculatedScore балів.";
        smartGoal = "Стабілізація свідомості та досягнення 0 балів за RASS для початку кінезіотерапії.";
      } else if (s.id == "ims") {
        interpretation = "Рівень мобільності IMS: $finalCalculatedScore балів.";
        smartGoal = "Перехід на рівень 5 за IMS (активна ходьба на місці біля ліжка з підтримкою) до 10.06.2026.";
      }

      if (_selectedPatient != null && _activeSession != null) {
        final List sessionScales = _activeSession!['scalesData'];
        // Видаляємо дублікат цієї ж шкали за цей день, якщо тестували повторно
        sessionScales.removeWhere((element) => element['scaleId'] == s.id);
        sessionScales.add({
          "scaleId": s.id,
          "scaleName": s.name,
          "score": finalCalculatedScore,
          "interpretation": interpretation
        });
        _activeSession!['smartGoal'] = smartGoal;
      }

      setState(() {
        _currentScreen = _selectedPatient != null ? "patient_card" : "dashboard";
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.teal.shade900,
        content: Text("📊 Тест ${s.name} завершено! Зафіксовано: $finalCalculatedScore балів. Сформовано SMART-ціль."),
      ));
    }
  }

  // =========================================================
  // ЕКРАНИ ДОВІДНИКІВ МКХ-10 ТА ВПРАВ З ПОШУКОМ
  // =========================================================
  Widget _screenMckhCatalog() {
    final filtered = ClinicalData.mckh10Catalog.where((m) => m['code']!.toLowerCase().contains(_mckhSearch.toLowerCase()) || m['name']!.toLowerCase().contains(_mckhSearch.toLowerCase())).toList();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _mckhSearch = v),
            decoration: const InputDecoration(labelText: "Глибокий пошук кодів за МКХ-10...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final item = filtered[i];
                return Card(
                  child: ListTile(
                    leading: Chip(label: Text(item['code']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.purple.shade700),
                    title: Text(item['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _screenExercisesCatalog() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _exerciseSearch = v),
            decoration: const InputDecoration(labelText: "Пошук вправ за назвою та ключовими словами...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: ClinicalData.exercisesCatalog.map((category) {
                final List items = category['items'];
                final matched = items.where((i) => i['name'].toLowerCase().contains(_exerciseSearch.toLowerCase()) || i['desc'].toLowerCase().contains(_exerciseSearch.toLowerCase())).toList();
                if (matched.isEmpty) return const SizedBox();
                return Card(
                  child: ExpansionTile(
                    title: Text(category['category'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900, fontSize: 14)),
                    initiallyExpanded: _exerciseSearch.isNotEmpty,
                    children: matched.map<Widget>((ex) {
                      return ListTile(
                        leading: const Icon(Icons.fitness_center, color: Colors.orange),
                        title: Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(ex['desc'], style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  // =========================================================
  // БЛАНКИ ОФІЦІЙНИХ МЕДИЧНИХ ДОКУМЕНТІВ (ЗАМІСТЬ ЧЕКІВ)
  // =========================================================
  
  // 1. ЛОКАЛЬНИЙ ОГЛЯД ЗА ОДИН КОНКРЕТНИЙ ДЕНЬ
  void _showSingleSessionReport(Map<String, dynamic> p, Map<String, dynamic> session) {
    final report = """
МІНІСТЕРСТВО ОХОРОНИ ЗДОРОВ'Я УКРАЇНИ
КЛІНІЧНИЙ ОГЛЯД ФІЗИЧНОГО ТЕРАПЕВТА ВІД ${session['date']}

Пацієнт: ${p['name']}
Вік: ${p['age']} років
Діагноз (МКХ-10): ${p['mkch10Code']} - ${p['mkch10Name']}
Кодифікатор МКФ: ${p['icfCodes'].join(', ')}
--------------------------------------------------
РЕЗУЛЬТАТИ ОБСТЕНЖЕННЯ ЗА ШКАЛАМИ В ЦЕЙ ДЕНЬ:
${(session['scalesData'] as List).isEmpty ? '- Тестування шкалами в цей день не проводились.' : (session['scalesData'] as List).map((s) => '• [Шкала ${s['scaleName']}]: Оцінка: ${s['score']} балів\n  Клінічний статус: ${s['interpretation']}').join('\n')}

ЗАТВЕРДЖЕНА СЕСІЙНА SMART-ЦІЛЬ:
🎯 ${session['smartGoal']}

ПРИЗНАЧЕНИЙ ПРОТОКОЛ ФІЗИЧНИХ ВПРАВ В ІРП:
${(session['assignedExercises'] as List).isEmpty ? '- Фізичні вправи на цей день не призначались.' : (session['assignedExercises'] as List).map((e) => '✔ $e').join('\n')}
--------------------------------------------------
Документ сформовано автономним модулем ФТ. 
Дата друку: 2026-06-03. Підпис терапевта: _________
""";
    _showDocumentDialog("📄 Клінічний протокол візиту", report);
  }

  // 2. ОБ'ЄДНАНИЙ ФІНАЛЬНИЙ ЕПІКРИЗ З ДИНАМІКОЮ ПО ДНЯХ
  void _showComprehensiveClinicalReport(Map<String, dynamic> p) {
    final List sessions = p['sessions'];
    
    // Формуємо хронологічну таблицю динаміки шкал
    String timelineScales = "";
    String timelineExercises = "";
    
    // Перебираємо сесії у зворотному порядку (від старих до нових), щоб показати хід реабілітації
    final reversedSessions = sessions.reversed.toList();
    for (var sess in reversedSessions) {
      timelineScales += "\n📈 Візит від [${sess['date']}]:\n";
      final List scales = sess['scalesData'];
      if (scales.isEmpty) {
        timelineScales += "  - Оцінки шкалами не проводились.\n";
      } else {
        for (var sc in scales) {
          timelineScales += "  • Шкала ${sc['scaleName']}: ${sc['score']} балів (${sc['interpretation']})\n";
        }
      }
      timelineScales += "  🎯 Ціль дня: ${sess['smartGoal']}\n";

      timelineExercises += "• [${sess['date']}]: " + (sess['assignedExercises'] as List).join(', ') + "\n";
    }

    final comprehensiveReport = """
==================================================
ОФІЦІЙНИЙ ВИПИСКОВИЙ ЕПІКРИЗ ФІЗИЧНОЇ РЕАБІЛІТАЦІЇ
==================================================
ЗАКЛАД: Центр комплексної реабілітації та ФТ
ДАТА ФОРМУВАННЯ ДОКУМЕНТА: 2026-06-03

1. ПАСПОРТНІ ДАНІ ПАЦІЄНТА
   ПІБ: ${p['name']}
   Вік: ${p['age']} років

2. КЛІНІЧНИЙ СТАТУС НА МОМЕНТ НАДХОДЖЕННЯ
   Основний діагноз за МКХ-10: ${p['mkch10Code']}
   Розшифровка: ${p['mkch10Name']}
   Профільні обмеження за доменами МКФ: ${p['icfCodes'].join('; ')}

3. КЛІНІЧНА ДИНАМІКА ОБСТЕНЖЕННЯ (ОБ'ЄДНАНА ІСТОРІЯ ВІЗИТІВ)
$timelineScales
4. МОНІТОР ПРИЗНАЧЕНИХ РЕАБІЛІТАЦІЙНИХ КОМПЛЕКСІВ
$timelineExercises
5. ЗАКЛЮЧНИЙ ВИСНОВОК ТА РЕКОМЕНДАЦІЇ
   Зафіксовано позитивну/стабільну кінетичну динаміку. Рекомендовано продовжити виконання затвердженого комплексу вправ в домашніх умовах за розробленою схемою ІРП.

--------------------------------------------------
Відповідальний завідувач відділення ФТ: ___________
М.П. 
==================================================
""";
    _showDocumentDialog("📜 Загальний об'єднаний епікриз пацієнта", comprehensiveReport);
  }

  void _showDocumentDialog(String title, String bodyText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(child: Text(bodyText, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.black))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Назад")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Медичний бланк скопійовано! Вставте його у Viber, Telegram або надішліть на друк.")));
            },
            child: const Text("Копіювати бланк для друку"),
          )
        ],
      ),
    );
  }
}
