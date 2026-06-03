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
      // Підтримка локалізації для коректного введення та відображення дат/тексту
      supportedLocales: const [
        Locale('uk', 'UA'),
        Locale('en', 'US'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey.shade50,
        cardTheme: const CardTheme(
          elevation: 3, 
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        ),
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
          {
            "scaleId": "ims", 
            "scaleName": "IMS", 
            "score": 3, 
            "interpretation": "Активне утримання сидячого положення на краю ліжка"
          }
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
  
  String _globalSearch = "";
  String _patientSearch = "";
  String _scaleSearch = "";
  String _mckhSearch = "";
  String _exerciseSearch = "";

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

  final _formKey = GlobalKey<FormState>();

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
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _handleBackButton();
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
  // ЕКРАН: ГОЛОВНЕ МЕНЮ
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
                  _buildMenuCard("📊 Шкали Оцінки", "16 шкал, покрокові інструкції", Colors.teal.shade700, () => setState(() => _currentScreen = "scales_catalog")),
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
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameController,
            // Дозволяємо українські літери (І, Є, Ї, Ґ, апостроф), англійську, дефіси та пробіли
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Zа-яА-ЯіІїЇєЄґҐʼ\s-]"))],
            decoration: const InputDecoration(labelText: "ПІБ Пацієнта (українською або англійською)", border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return "Будь ласка, введіть ПІБ";
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ageController, 
            keyboardType: TextInputType.number, 
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: "Вік (повних років)", border: OutlineInputBorder()),
            validator: (value) {
              if (value == null || value.isEmpty) return "Будь ласка, введіть вік";
              return null;
            },
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
              if (_formKey.currentState!.validate()) {
                final newPatient = {
                  "id": "p_${DateTime.now().millisecondsSinceEpoch}",
                  "name": _nameController.text.trim(),
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
      ),
    );
  }

  // =========================================================
  // ЕКРАН: ЕЛЕКТРОННА КАРТА + РЕДАГУВАННЯ ДАНИХ ТА СЕСІЙ
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
        
        // Паспортна частина з кнопкою повного редагування
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
                    icon: const Icon(Icons.edit_note, color: Colors.teal, size: 28),
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
        SizedBox(
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
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          tooltip: "Видалити цю сесію",
                          onPressed: () => _deleteCurrentSession(p, _activeSession!),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, size: 20, color: Colors.teal),
                          onPressed: () => _showSingleSessionReport(p, _activeSession!),
                        ),
                      ],
                    )
                  ],
                ),
                
                // РЕДАГУВАННЯ SMART-ЦІЛІ
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

                // РЕДАГУВАННЯ РЕЗУЛЬТАТІВ ШКАЛ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("📊 Динаміка шкал:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal)),
                    TextButton.icon(
                      onPressed: () => setState(() => _currentScreen = "scales_catalog"),
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text("Провести тест", style: TextStyle(fontSize: 11)),
                    )
                  ],
                ),
                ...(_activeSession!['scalesData'] as List).map((scale) {
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text("${scale['scaleName']}: ${scale['score']} балів", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(scale['interpretation'], style: const TextStyle(fontSize: 11)),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 16),
                      onPressed: () {
                        setState(() {
                          (_activeSession!['scalesData'] as List).removeWhere((s) => s['scaleId'] == scale['scaleId']);
                        });
                      },
                    ),
                  );
                }).toList(),

                const Divider(),
                // РЕДАГУВАННЯ ВПРАВ В СЕСІЇ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("🏋️‍♂️ Призначені вправи:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange.shade900)),
                    TextButton.icon(
                      onPressed: () => setState(() => _currentScreen = "exercises_catalog"),
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text("Змінити комплекс", style: TextStyle(fontSize: 11)),
                    )
                  ],
                ),
                if (_tempSelectedExercises.isEmpty) 
                  const Text("Комплекс не сформовано.", style: TextStyle(color: Colors.grey, fontSize: 11))
                else 
                  ..._tempSelectedExercises.map((ex) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text("• $ex", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  )).toList(),
              ],
            ),
          ),
        )
      ],
    );
  }

  // =========================================================
  // ДІАЛОГОВІ ВІКНА ДЛЯ РЕДАГУВАННЯ
  // =========================================================
  void _showEditPatientBaseInfoDialog(Map<String, dynamic> p) {
    final nameEditController = TextEditingController(text: p['name']);
    final ageEditController = TextEditingController(text: p['age'].toString());
    Map<String, String> selectedMckh = ClinicalData.mckh10Catalog.firstWhere(
      (m) => m['code'] == p['mkch10Code'], 
      orElse: () => ClinicalData.mckh10Catalog.first
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Редагування даних пацієнта"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameEditController,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Zа-яА-ЯіІїЇєЄґҐʼ\s-]"))],
                  decoration: const InputDecoration(labelText: "ПІБ Пацієнта"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ageEditController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: "Вік"),
                ),
                const SizedBox(height: 15),
                const Text("МКХ-10 Діагноз:", style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<Map<String, String>>(
                  value: selectedMckh,
                  isExpanded: true,
                  items: ClinicalData.mckh10Catalog.map((item) {
                    return DropdownMenuItem(value: item, child: Text("${item['code']} - ${item['name']}", style: const TextStyle(fontSize: 10)));
                  }).toList(),
                  onChanged: (v) => setDialogState(() => selectedMckh = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Скасувати")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  p['name'] = nameEditController.text.trim();
                  p['age'] = int.tryParse(ageEditController.text) ?? p['age'];
                  p['mkch10Code'] = selectedMckh['code'];
                  p['mkch10Name'] = selectedMckh['name'];
                });
                Navigator.pop(ctx);
              },
              child: const Text("Зберегти"),
            )
          ],
        ),
      ),
    );
  }

  void _showEditSmartGoalDialog(Map<String, dynamic> session) {
    _editGoalController.text = session['smartGoal'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Редагувати SMART-ціль сесії"),
        content: TextField(
          controller: _editGoalController,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Сформулюйте SMART ціль..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Скасувати")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                session['smartGoal'] = _editGoalController.text;
              });
              Navigator.pop(ctx);
            },
            child: const Text("Оновити"),
          )
        ],
      ),
    );
  }

  void _createNewSessionForSelectedPatient(Map<String, dynamic> p) {
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final newSess = {
      "id": "s_${now.millisecondsSinceEpoch}",
      "date": dateStr,
      "scalesData": [],
      "assignedExercises": <String>[],
      "smartGoal": "Ціль за SMART адаптується після проведення тестів."
    };
    setState(() {
      (p['sessions'] as List).add(newSess);
      _activeSession = newSess;
      _tempSelectedExercises = [];
    });
  }

  void _deleteCurrentSession(Map<String, dynamic> patient, Map<String, dynamic> session) {
    final List list = patient['sessions'];
    if (list.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Неможливо видалити єдину сесію пацієнта.")));
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Видалити цю сесію?"),
        content: Text("Ви дійсно хочете видалити сесію за дату ${session['date']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Скасувати")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                list.removeWhere((s) => s['id'] == session['id']);
                _activeSession = list.first;
                _tempSelectedExercises = List<String>.from(_activeSession!['assignedExercises']);
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
  // ЕКРАН: 16 КЛІНІЧНИХ ШКАЛ + ІНСТРУКТИВНИЙ БЛОК
  // =========================================================
  Widget _screenScalesCatalog() {
    final list = ClinicalData.scales16.where((s) => s.name.toLowerCase().contains(_scaleSearch.toLowerCase())).toList();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _scaleSearch = v),
            decoration: const InputDecoration(labelText: "Пошук за назвою клінічної шкали...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final scale = list[i];
                return Card(
                  child: ExpansionTile(
                    leading: const Icon(Icons.analytics, color: Colors.teal),
                    title: Text(scale.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Тип тесту: ${scale.type == 'interactive' ? 'Покроковий' : 'Пряме введення балів'}", style: const TextStyle(fontSize: 11)),
                    
                    // Інструктивний методичний блок інтегровано прямо сюди перед початком тестування
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        color: Colors.blue.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.info_outline, color: Colors.blue, size: 18),
                                SizedBox(width: 6),
                                Text("Методичні вказівки до шкали", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue)),
                              ],
                            ),
                            const Divider(),
                            Text("💡 Призначення:\n${scale.description}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text("📋 Процедура та інструкція:\n${scale.instructions}", style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 12),
                            if (_selectedPatient == null)
                              const Text("⚠️ Для запуску тесту оберіть пацієнта в реєстрі!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12))
                            else
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800),
                                onPressed: () => _startScaleTest(scale),
                                child: Text("ПОЧАТИ ОЦІНЮВАННЯ ДЛЯ: ${_selectedPatient!['name']}", style: const TextStyle(fontSize: 11, color: Colors.white)),
                              ),
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

  void _startScaleTest(ClinicalScale scale) {
    setState(() {
      _selectedScale = scale;
      _currentQuestionIndex = 0;
      _accumulatedScore = 0;
      _bbsAnswers = [];
      _currentScreen = "test_exec";
    });
  }

  // =========================================================
  // ЕКРАН: ВИКОНАННЯ ТЕСТУ (З ІНСТРУКЦІЄЮ ЗВЕРХУ)
  // =========================================================
  Widget _screenTestExecutor() {
    final scale = _selectedScale!;
    
    if (scale.type != "interactive") {
      final directController = TextEditingController();
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Пряме введення балів для: ${scale.name}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: directController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Загальний набраний бал", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final score = int.tryParse(directController.text) ?? 0;
                _saveScaleResultToActiveSession(scale.id, scale.name, score, "Введено вручну на основі зовнішнього клінічного протоколу.");
              },
              child: const Text("Зберегти результат"),
            )
          ],
        ),
      );
    }

    final questions = scale.questions!;
    final currentQ = questions[_currentQuestionIndex];

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        LinearProgressIndicator(value: (_currentQuestionIndex + 1) / questions.length, color: Colors.teal),
        const SizedBox(height: 10),
        Text("Питання ${_currentQuestionIndex + 1} з ${questions.length}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        
        // Інструкція до конкретного підпункту
        Card(
          color: Colors.amber.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(currentQ['question']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black80)),
          ),
        ),
        const SizedBox(height: 14),
        
        ...(currentQ['options'] as List<Map<String, dynamic>>).map((opt) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.teal.shade200)
              ),
              onPressed: () {
                if (scale.id == "bbs") {
                  _bbsAnswers.add(opt['score'] as int);
                } else {
                  _accumulatedScore += opt['score'] as int;
                }

                if (_currentQuestionIndex < questions.length - 1) {
                  setState(() { _currentQuestionIndex++; });
                } else {
                  int total = _accumulatedScore;
                  if (scale.id == "bbs") {
                    total = _bbsAnswers.reduce((a, b) => a + b);
                  }
                  String interp = scale.interpret!(total);
                  _saveScaleResultToActiveSession(scale.id, scale.name, total, interp);
                }
              },
              child: Text("[${opt['score']} б.] ${opt['text']}", style: const TextStyle(color: Colors.black80, fontSize: 12)),
            ),
          );
        }).toList()
      ],
    );
  }

  void _saveScaleResultToActiveSession(String id, String name, int score, String interp) {
    if (_activeSession != null) {
      setState(() {
        final existingList = _activeSession!['scalesData'] as List;
        existingList.removeWhere((element) => element['scaleId'] == id);
        existingList.add({
          "scaleId": id,
          "scaleName": name,
          "score": score,
          "interpretation": interp
        });
        _currentScreen = "patient_card";
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Результат шкали $name успішно додано у візит!")));
    }
  }

  // =========================================================
  // ЕКРАН: ДОВІДНИК МКХ-10 / МКФ
  // =========================================================
  Widget _screenMckhCatalog() {
    final list = ClinicalData.mckh10Catalog.where((m) => m['code']!.toLowerCase().contains(_mckhSearch.toLowerCase()) || m['name']!.toLowerCase().contains(_mckhSearch.toLowerCase())).toList();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => _mckhSearch = v),
            decoration: const InputDecoration(labelText: "Пошук коду або нозології...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.medical_services, color: Colors.purple),
                    title: Text("${list[i]['code']} - ${list[i]['name']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
  // ЕКРАН: КОМПЛЕКСИ ВПРАВ + ОНОВЛЕННЯ В КАРТЦІ
  // =========================================================
  Widget _screenExercisesCatalog() {
    final entries = ClinicalData.exerciseCatalog.entries.where((e) => e.key.toLowerCase().contains(_exerciseSearch.toLowerCase()) || e.value.toLowerCase().contains(_exerciseSearch.toLowerCase())).toList();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          if (_selectedPatient != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.orange.shade50,
              child: Text("Редагування комплексу для сесії від ${_activeSession!['date']}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          TextField(
            onChanged: (v) => setState(() => _exerciseSearch = v),
            decoration: const InputDecoration(labelText: "Пошук терапевтичних втручань...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final exName = entries[i].key;
                final exDesc = entries[i].value;
                final isAdded = _tempSelectedExercises.contains(exName);

                return Card(
                  child: ExpansionTile(
                    title: Text(exName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    trailing: _selectedPatient == null 
                      ? null 
                      : IconButton(
                          icon: Icon(isAdded ? Icons.check_circle : Icons.add_circle_outline, color: isAdded ? Colors.green : Colors.grey),
                          onPressed: () {
                            setState(() {
                              if (isAdded) {
                                _tempSelectedExercises.remove(exName);
                              } else {
                                _tempSelectedExercises.add(exName);
                              }
                              _activeSession!['assignedExercises'] = List<String>.from(_tempSelectedExercises);
                            });
                          },
                        ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(exDesc, style: const TextStyle(fontSize: 12, color: Colors.black80)),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          if (_selectedPatient != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade900),
              onPressed: () => setState(() => _currentScreen = "patient_card"),
              child: const Text("ПОВЕРНУТИСЬ ДО КАРТКИ ПАЦІЄНТА", style: TextStyle(color: Colors.white)),
            )
        ],
      ),
    );
  }

  // =========================================================
  // ГЕНЕРАЦІЯ ЗВІТІВ (ОБ'ЄДНАНИЙ ЕПІКРИЗ ТА ОДИНИЧНА СЕСІЯ)
  // =========================================================
  void _showSingleSessionReport(Map<String, dynamic> p, Map<String, dynamic> sess) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Протокол огляду від ${sess['date']}"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Пацієнт: ${p['name']}, ${p['age']} р.", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Діагноз: ${p['mkch10Code']} - ${p['mkch10Name']}"),
              const Divider(),
              const Text("🎯 SMART Ціль:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(sess['smartGoal']),
              const Divider(),
              const Text("📊 Результати тестування:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...(sess['scalesData'] as List).map((s) => Text("• ${s['scaleName']}: ${s['score']} б. (${s['interpretation']})")),
              const Divider(),
              const Text("🏋️‍♂️ Комплекс вправ:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...(sess['assignedExercises'] as List).map((e) => Text("• $e")),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Закрити"))],
      ),
    );
  }

  void _showComprehensiveClinicalReport(Map<String, dynamic> p) {
    final List sessions = p['sessions'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("🏥 ОБ'ЄДНАНИЙ КЛІНІЧНИЙ ЕПІКРИЗ ФТ"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ПІБ Пацієнта: ${p['name']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
              Text("Вік: ${p['age']} років", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Основний діагноз (МКХ-10): ${p['mkch10Code']} ${p['mkch10Name']}"),
              Text("Функціональні обмеження (МКФ): ${p['icfCodes'].join('; ')}"),
              const Divider(height: 20, thickness: 2),
              const Text("📈 ХРОНОЛОГІЯ РЕАБІЛІТАЦІЙНИХ СЕСІЙ:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
              ...sessions.map((sess) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  color: Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📅 Дата огляду: ${sess['date']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                        const SizedBox(height: 4),
                        Text("🎯 Ціль SMART: ${sess['smartGoal']}", style: const TextStyle(fontSize: 11)),
                        const SizedBox(height: 4),
                        const Text("📊 Тести та метрики:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        ...(sess['scalesData'] as List).map((s) => Text("   - ${s['scaleName']}: ${s['score']} балів -> ${s['interpretation']}", style: const TextStyle(fontSize: 11))),
                        const SizedBox(height: 4),
                        const Text("🏋️‍♂️ Призначена програма:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        ...(sess['assignedExercises'] as List).map((e) => Text("   • $e", style: const TextStyle(fontSize: 11))),
                      ],
                    ),
                  ),
                );
              }).toList()
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Готово"))],
      ),
    );
  }
}
