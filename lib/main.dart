import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      // Налаштування локалізації для коректного відображення системних елементів
      supportedLocales: const [Locale('uk', 'UA'), Locale('en', 'US')],
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey.shade50,
        cardTheme: const CardTheme(elevation: 3, margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4)),
      ),
      home: const MainDashboard(),
    );
  }
}

// ГЛОБАЛЬНА БАЗА ДАНИХ (EHR)
List<Map<String, dynamic>> globalPatients = [
  {
    "id": "p_1",
    "name": "Іванов Петро Миколайович",
    "age": 45,
    "mkch10Code": "I63.3",
    "mkch10Name": "Інфаркт мозку внаслідок тромбозу церебральних артерій (Ішемічний інсульт)",
    "icfCodes": ["b730 (Сила м'язів)", "d450 (Ходьба)", "d415 (Баланс)"],
    "sessions": [
      {
        "id": "s_1",
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
  // =========================================================
  // ГЛОБАЛЬНИЙ ФОРМАТТЕР ДЛЯ ТЕКСТОВИХ ПОЛІВ (УКР / ENG / АПОСТРОФ / ПРОБІЛ / ДЕФІС)
  // =========================================================
  final FilteringTextInputFormatter ukrEngFormatter = FilteringTextInputFormatter.allow(
    RegExp(r"[a-zA-Zа-яА-ЯіІїЇєЄґҐʼ\s-]")
  );

  String _currentScreen = "dashboard"; // dashboard, patients_list, create_patient, patient_card, scales_catalog, test_exec
  
  String _globalSearch = "";
  String _patientSearch = "";
  String _scaleSearch = "";

  Map<String, dynamic>? _selectedPatient;
  Map<String, dynamic>? _activeSession; 
  ClinicalScale? _selectedScale;
  
  int _currentQuestionIndex = 0;
  int _accumulatedScore = 0;
  List<int> _bbsAnswers = []; 

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _editGoalController = TextEditingController();
  
  Map<String, String> _chosenMckh = ClinicalData.mckh10Catalog.first;
  final List<String> _chosenIcfCodes = [];
  List<String> _tempSelectedExercises = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.teal.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_currentScreen != "dashboard")
            IconButton(
              icon: const Icon(Icons.grid_view, size: 28, color: Colors.white),
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
      case "test_exec": return _screenTestExecutor();
      default: return _screenDashboard();
    }
  }

  // =========================================================
  // ЕКРАН: ГОЛОВНЕ МЕНЮ (ПОШУК З ПОДТРИМКОЮ УКР/ENG)
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
              const Text("Глобальний пошук пацієнта (Укр/Eng):", style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                inputFormatters: [ukrEngFormatter], // ВАЛІДАЦІЯ ТУТ
                onChanged: (v) => setState(() => _globalSearch = v),
                decoration: InputDecoration(
                  hintText: "Введіть ПІБ пацієнта...",
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
                  _buildMenuCard("👥 Пацієнти", "Реєстр, редагування карт та сесій", Colors.blue.shade700, () => setState(() => _currentScreen = "patients_list")),
                  _buildMenuCard("📊 Шкали Оцінки", "16 шкал з інструкціями та тестами", Colors.teal.shade700, () => setState(() => _currentScreen = "scales_catalog")),
                ],
              ),
        )
      ],
    );
  }

  Widget _buildGlobalSearchResults() {
    final matches = globalPatients.where((p) => p['name'].toLowerCase().contains(_globalSearch.toLowerCase())).toList();
    if (matches.isEmpty) return const Center(child: Text("За вказаним ПІБ нікого не знайдено."));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: matches.length,
      itemBuilder: (context, i) {
        final p = matches[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.account_box, color: Colors.teal, size: 36),
            title: Text(p['name']),
            subtitle: Text("МКХ-10: ${p['mkch10Code']} | Візитів: ${p['sessions'].length}"),
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
  // ЕКРАН: РЕЄСТР ПАЦІЄНТІВ + ВИДАЛЕННЯ КАРТКИ
  // =========================================================
  Widget _screenPatientsList() {
    final filtered = globalPatients.where((p) => p['name'].toLowerCase().contains(_patientSearch.toLowerCase())).toList();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            inputFormatters: [ukrEngFormatter], // ВАЛІДАЦІЯ ТУТ
            onChanged: (v) => setState(() => _patientSearch = v),
            decoration: const InputDecoration(labelText: "Пошук пацієнта (укр/eng)...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
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
                    subtitle: Text("Діагноз: ${p['mkch10Code']} | Оглядів: ${p['sessions'].length}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                          onPressed: () => _confirmDeletePatient(p),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.teal, size: 16),
                      ],
                    ),
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

  void _confirmDeletePatient(Map<String, dynamic> p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Видалити карту пацієнта?"),
        content: Text("Ви дійсно хочете повністю видалити карту: ${p['name']} та всю історію візитів?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Скасувати")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                globalPatients.removeWhere((element) => element['id'] == p['id']);
                if (_selectedPatient?['id'] == p['id']) _selectedPatient = null;
              });
              Navigator.pop(ctx);
            },
            child: const Text("Видалити", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // =========================================================
  // ЕКРАН: СТВОРЕННЯ КАРТИ ПАЦІЄНТА (З ПІДТРИМКОЮ УКРАЇНСЬКОЇ)
  // =========================================================
  Widget _screenCreatePatient() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _nameController,
          inputFormatters: [ukrEngFormatter], // ВАЛІДАЦІЯ ТУТ (ПІБ УКР/ENG)
          decoration: const InputDecoration(labelText: "ПІБ Пацієнта (українською або англійською)", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ageController, 
          keyboardType: TextInputType.number, 
          inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Тільки цифри для віку
          decoration: const InputDecoration(labelText: "Вік (повних років)", border: OutlineInputBorder())
        ),
        const SizedBox(height: 16),
        const Text("🩺 Профільний діагноз МКХ-10:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
          child: DropdownButton<Map<String, String>>(
            value: _chosenMckh,
            isExpanded: true,
            underline: const SizedBox(),
            items: ClinicalData.mckh10Catalog.map((item) {
              return DropdownMenuItem(value: item, child: Text("${item['code']} - ${item['name']}", style: const TextStyle(fontSize: 11)));
            }).toList(),
            onChanged: (v) => setState(() => _chosenMckh = v!),
          ),
        ),
        const SizedBox(height: 16),
        const Text("📌 Функціональний дефіцит МКФ:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
        ...ClinicalData.icfDomains.map((domain) {
          final str = "${domain['code']} ${domain['name']}";
          return CheckboxListTile(
            title: Text(str, style: const TextStyle(fontSize: 12)),
            value: _chosenIcfCodes.contains(str),
            onChanged: (val) {
              setState(() { if (val!) { _chosenIcfCodes.add(str); } else { _chosenIcfCodes.remove(str); } });
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
                    "id": "s_${DateTime.now().millisecondsSinceEpoch}",
                    "date": "2026-06-03",
                    "scalesData": [],
                    "assignedExercises": <String>[],
                    "smartGoal": "Ціль за SMART адаптується після проведення тестів."
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
  // ЕКРАН: ЕЛЕКТРОННА КАРТА + ПОВНЕ РЕДАГУВАННЯ ДАНИХ ТА СЕСІЙ
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
            const Text("📊 EHR Стан", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))
          ],
        ),
        const SizedBox(height: 12),
        
        // Паспортна частина з кнопкою редагування ПІБ, Віку, МКХ-10
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.teal.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(p['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal))),
                  IconButton(
                    icon: const Icon(Icons.edit_note, color: Colors.teal),
                    onPressed: () => _showEditPatientBaseInfoDialog(p),
                    tooltip: "Редагувати ПІБ, Вік та МКХ-10",
                  )
                ],
              ),
              const SizedBox(height: 4),
              Text("Вік: ${p['age']} років | МКХ-10: ${p['mkch10Code']} - ${p['mkch10Name']}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 4),
              Text("Коди МКФ: ${p['icfCodes'].join('; ')}", style: const TextStyle(color: Colors.black54, fontSize: 11)),
            ],
          ),
        ),
        const Divider(height: 24),

        // СЕЛЕКТОР СЕСІЙ ВІЗИТІВ
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("📅 Сесії оглядів:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
              onPressed: () => _createNewSessionForSelectedPatient(p),
              icon: const Icon(Icons.calendar_today, size: 12, color: Colors.white),
              label: const Text("НОВИЙ ВІЗИТ", style: TextStyle(fontSize: 10, color: Colors.white)),
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
                  label: Text(sess['date'], style: TextStyle(color: isCurrent ? Colors.white : Colors.black)),
                  selected: isCurrent,
                  selectedColor: Colors.teal.shade700,
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
        
        // ПОТОЧНИЙ СЕСІЙНИЙ БЛОК ДАНИХ
        if (_activeSession != null) Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("📋 Дані візиту від ${_activeSession!['date']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      tooltip: "Видалити цю сесію",
                      onPressed: () => _deleteCurrentSession(p, _activeSession!),
                    ),
                  ],
                ),
                
                // РЕДАГУВАННЯ SMART-ЦІЛІ (З ПІДТРИМКОЮ УКРАЇНСЬКОЇ)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("🎯 SMART-ціль сесії:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16, color: Colors.orange),
                      onPressed: () => _showEditSmartGoalDialog(_activeSession!),
                    )
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.amber.shade200)),
                  child: Text(_activeSession!['smartGoal'], style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                ),
                
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800, minimumSize: const Size.fromHeight(36)),
                  onPressed: () => setState(() => _currentScreen = "scales_catalog"),
                  icon: const Icon(Icons.analytics_outlined, color: Colors.white),
                  label: const Text("Запустити тестування шкалами на цей день", style: TextStyle(color: Colors.white)),
                ),
                
                const SizedBox(height: 12),
                // СПИСОК ШКАЛ З МОЖЛИВІСТЮ ВИДАЛЕННЯ/РЕДАГУВАННЯ РЕЗУЛЬТАТУ
                const Text("Результати шкал за цей огляд:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                if ((_activeSession!['scalesData'] as List).isEmpty)
                  const Padding(padding: EdgeInsets.all(8.0), child: Text("Шкали ще не проводились.", style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)))
                else
                  ...(_activeSession!['scalesData'] as List).map<Widget>((sc) {
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Chip(label: Text(sc['scaleName'], style: const TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: Colors.teal),
                      title: Text("Результат: ${sc['score']} балів", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      subtitle: Text(sc['interpretation'], style: const TextStyle(fontSize: 11)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 16, color: Colors.orange),
                            onPressed: () => _showEditScaleScoreDialog(_activeSession!, sc),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 16, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                (_activeSession!['scalesData'] as List).removeWhere((element) => element['scaleId'] == sc['scaleId']);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),
        // ВПРАВИ В ІРП
        const Text("🏋️‍♂️ Призначення фізичних вправ на цей день:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.teal)),
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
                  setState(() { if (val!) { _tempSelectedExercises.add(ex['name']); } else { _tempSelectedExercises.remove(ex['name']); } });
                },
              );
            }).toList(),
          );
        }).toList(),
        
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade900, padding: const EdgeInsets.all(14)),
          onPressed: () {
            setState(() { _activeSession!['assignedExercises'] = List<String>.from(_tempSelectedExercises); });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("💾 Зміни вправ успішно зафіксовано в ІРП!")));
          },
          icon: const Icon(Icons.save, color: Colors.white),
          label: const Text("💾 ЗБЕРЕГТИ КОМПЛЕКС ВПРАВ В ІРП ЦЬОГО ДНЯ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // =========================================================
  // ДІАЛОГОВІ ВІКНА ДЛЯ РЕДАГУВАННЯ ДАНИХ (З ВАЛІДАЦІЄЮ УКР/ENG)
  // =========================================================
  void _showEditPatientBaseInfoDialog(Map<String, dynamic> p) {
    final _nameEditController = TextEditingController(text: p['name']);
    final _ageEditController = TextEditingController(text: p['age'].toString());
    Map<String, String> _tempMckh = ClinicalData.mckh10Catalog.firstWhere((element) => element['code'] == p['mkch10Code'], orElse: () => ClinicalData.mckh10Catalog.first);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Редагувати базову інформацію"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameEditController, 
                inputFormatters: [ukrEngFormatter], // ВАЛІДАЦІЯ ТУТ
                decoration: const InputDecoration(labelText: "ПІБ")
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _ageEditController, 
                keyboardType: TextInputType.number, 
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: "Вік")
              ),
              const SizedBox(height: 12),
              const Text("Змінити код МКХ-10:"),
              DropdownButton<Map<String, String>>(
                value: _tempMckh,
                isExpanded: true,
                items: ClinicalData.mckh10Catalog.map((item) {
                  return DropdownMenuItem(value: item, child: Text("${item['code']} - ${item['name']}", style: const TextStyle(fontSize: 10)));
                }).toList(),
                onChanged: (v) => _tempMckh = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Скасувати")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                p['name'] = _nameEditController.text;
                p['age'] = int.tryParse(_ageEditController.text) ?? p['age'];
                p['mkch10Code'] = _tempMckh['code'];
                p['mkch10Name'] = _tempMckh['name'];
              });
              Navigator.pop(ctx);
            },
            child: const Text("Зберегти"),
          )
        ],
      ),
    );
  }

  void _showEditSmartGoalDialog(Map<String, dynamic> session) {
    _editGoalController.text = session['smartGoal'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Редагувати SMART-ціль"),
        content: TextField(
          controller: _editGoalController, 
          inputFormatters: [ukrEngFormatter], // ВАЛІДАЦІЯ ТУТ
          maxLines: 3, 
          decoration: const InputDecoration(border: OutlineInputBorder())
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Скасувати")),
          ElevatedButton(
            onPressed: () {
              setState(() { session['smartGoal'] = _editGoalController.text; });
              Navigator.pop(ctx);
            },
            child: const Text("Оновити ціль"),
          )
        ],
      ),
    );
  }

  void _showEditScaleScoreDialog(Map<String, dynamic> session, Map<String, dynamic> scaleItem) {
    final _scoreEditController = TextEditingController(text: scaleItem['score'].toString());
    final _interpEditController = TextEditingController(text: scaleItem['interpretation']);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Редагувати результат: ${scaleItem['scaleName']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _scoreEditController, 
              keyboardType: TextInputType.number, 
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: "Виставлений бал")
            ),
            TextField(
              controller: _interpEditController, 
              inputFormatters: [ukrEngFormatter], // ВАЛІДАЦІЯ ТУТ
              decoration: const InputDecoration(labelText: "Клінічний статус")
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Скасувати")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                scaleItem['score'] = int.tryParse(_scoreEditController.text) ?? scaleItem['score'];
                scaleItem['interpretation'] = _interpEditController.text;
              });
              Navigator.pop(ctx);
            },
            child: const Text("Зберегти"),
          )
        ],
      ),
    );
  }

  void _deleteCurrentSession(Map<String, dynamic> p, Map<String, dynamic> session) {
    final List list = p['sessions'];
    if (list.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Неможливо видалити єдину сесію пацієнта!")));
      return;
    }
    setState(() {
      list.removeWhere((element) => element['id'] == session['id']);
      _activeSession = list.first;
      _tempSelectedExercises = List<String>.from(_activeSession!['assignedExercises']);
    });
  }

  void _createNewSessionForSelectedPatient(Map<String, dynamic> p) {
    final List sessions = p['sessions'];
    final lastDateStr = sessions.first['date']; 
    final parts = lastDateStr.split('-');
    int day = int.parse(parts[2]) + 1;
    String dayStr = day < 10 ? "0$day" : "$day";
    String newDate = "${parts[0]}-${parts[1]}-$dayStr";

    final newSess = {
      "id": "s_${DateTime.now().millisecondsSinceEpoch}",
      "date": newDate,
      "scalesData": [],
      "assignedExercises": <String>[],
      "smartGoal": "Ціль за SMART адаптується після проведення нових вимірів."
    };

    setState(() {
      sessions.insert(0, newSess); 
      _activeSession = newSess;
      _tempSelectedExercises = [];
    });
  }

  // =========================================================
  // ЕКРАН: КАТАЛОГ ШКАЛ ОЦІНКИ ТА ПОКРОКОВИЙ ТЕСТЕР + ІНСТРУКЦІЇ
  // =========================================================
  Widget _screenScalesCatalog() {
    final filtered = ClinicalData.allScales.where((s) => s.name.toLowerCase().contains(_scaleSearch.toLowerCase()) || s.fullName.toLowerCase().contains(_scaleSearch.toLowerCase())).toList();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            inputFormatters: [ukrEngFormatter], // ВАЛІДАЦІЯ ТУТ
            onChanged: (v) => setState(() => _scaleSearch = v),
            decoration: const InputDecoration(labelText: "Пошук серед 16 шкал оцінки...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
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
                            Text("📌 Опис (Навіщо потрібна): ${s.indications}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                            const SizedBox(height: 6),
                            Text("ℹ️ Інструкція (Як проводити): ${s.instruction}", style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.blueGrey)),
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
          Text("Шкала: ${s.fullName}", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Пункт ${_currentQuestionIndex + 1} з $totalQuestions", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
            child: Text(q.text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.builder(
              itemCount: q.options.length,
              itemBuilder: (context, idx) {
                final opt = q.options[idx];
                return Card(
                  child: ListTile(
                    title: Text(opt.text, style: const TextStyle(fontSize: 13)),
                    trailing: CircleAvatar(backgroundColor: Colors.teal.shade700, radius: 12, child: Text("${opt.score}", style: const TextStyle(fontSize: 10, color: Colors.white))),
                    onTap: () => _handleOptionSelected(opt.score),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleOptionSelected(int score) {
    final s = _selectedScale!;
    _bbsAnswers.add(score);
    _accumulatedScore += score;

    if (_currentQuestionIndex < s.questions.length - 1) {
      setState(() { _currentQuestionIndex++; });
    } else {
      int finalCalculatedScore = s.id == "bbs" ? _bbsAnswers.reduce((a, b) => a + b) : _accumulatedScore;
      
      // Автоматична інтерпретація результату під час завершення тесту
      String interpretation = "Стабільний стан за шкалою ${s.name} ($finalCalculatedScore балів)";
      if (s.id == "bbs" && finalCalculatedScore < 21) interpretation = "Високий ризик падіння ($finalCalculatedScore балів)";
      if (s.id == "ims" && finalCalculatedScore <= 3) interpretation = "Обмежена мобільність у ліжку";

      setState(() {
        if (_activeSession != null) {
          final data = _activeSession!['scalesData'] as List;
          data.removeWhere((element) => element['scaleId'] == s.id);
          data.add({
            "scaleId": s.id,
            "scaleName": s.name,
            "score": finalCalculatedScore,
            "interpretation": interpretation
          });
        }
        _currentScreen = "patient_card";
      });
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.teal, content: Text("📊 Результат ${s.name}: $finalCalculatedScore балів додано до сесії!")));
    }
  }
}
