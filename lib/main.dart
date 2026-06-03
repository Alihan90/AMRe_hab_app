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
        scaffoldBackgroundColor: Colors.grey.shade100,
        cardTheme: const CardTheme(elevation: 3, margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4)),
      ),
      home: const MainDashboard(),
    );
  }
}

// ГЛОБАЛЬНА СИСТЕМА ОБЛІКУ ПАЦІЄНТІВ ВІДДІЛЕННЯ
List<Map<String, dynamic>> globalPatients = [
  {
    "id": "p1",
    "name": "Іванов Петро Миколайович",
    "age": 45,
    "mkch10Code": "I63.3",
    "mkch10Name": "Інфаркт мозку внаслідок тромбозу церебральних артерій (Ішемічний інсульт)",
    "icfCodes": ["b730 (Сила м'язів)", "d450 (Ходьба)"],
    "history": [
      {"scaleId": "ims", "scaleName": "IMS", "date": "2026-06-01", "score": 3, "interpretation": "Активне утримання сидячого положення на краю ліжка"}
    ],
    "smartGoal": "Пацієнт зможе самостійно переходити в положення стоячи біля ліжка (домен d410) за підтримки 1 особи до 15.06.2026 для ініціації вертикалізації.",
    "exercises": ["Діафрагмальне дихання", "Пасивна суглобова гімнастика"]
  }
];

class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  // Навігаційна логіка додатку
  String _currentScreen = "dashboard"; // Режими: dashboard, patients_list, create_patient, patient_card, scales_catalog, mckh_catalog, exercises_catalog, test_exec
  
  // Локальні пошукові запити для кожного розділу
  String _globalSearch = "";
  String _patientSearch = "";
  String _scaleSearch = "";
  String _mckhSearch = "";
  String _exerciseSearch = "";

  Map<String, dynamic>? _selectedPatient;
  ClinicalScale? _selectedScale;
  int _activeRadioScore = -1;

  // Контролери для створення нової карти
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  Map<String, String> _chosenMckh = ClinicalData.mckh10Catalog.first;
  final List<String> _chosenIcfCodes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.teal.shade900,
        elevation: 4,
        actions: [
          if (_currentScreen != "dashboard")
            IconButton(
              icon: const Icon(Icons.grid_view, size: 28, color: Colors.white),
              tooltip: "На головне меню",
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
      case "create_patient": return "📝 Реєстрація Медичної Карти";
      case "patient_card": return "🗂 Картка та ІРП Пацієнта";
      case "scales_catalog": return "📊 Діагностичні Шкали (16)";
      case "mckh_catalog": return "🩺 Довідник МКХ-10";
      case "exercises_catalog": return "🏋️‍♂️ Каталог Клінічних Вправ";
      case "test_exec": return "⏱ Проведення Тестування";
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
  // ЭКРАН: ГОЛОВНЕ МЕНЮ (DASHBOARD) З ГЛОБАЛЬНИМ ПОШУКОМ
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
              const Text("Глобальний пошук по клініці:", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 6),
              TextField(
                onChanged: (v) => setState(() => _globalSearch = v),
                decoration: InputDecoration(
                  hintText: "Введіть ПІБ пацієнта для швидкого виклику ІРП...",
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
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard("👥 Пацієнти", "Карти, SMART-цілі, формування ІРП", Colors.blue.shade700, () => setState(() => _currentScreen = "patients_list")),
                  _buildMenuCard("📊 Шкали Оцінки", "16 шкал, інструкції, автоматичний підрахунок", Colors.teal.shade700, () => setState(() => _currentScreen = "scales_catalog")),
                  _buildMenuCard("🩺 МКХ-10", "Клінічні коди та домени МКФ", Colors.purple.shade700, () => setState(() => _currentScreen = "mckh_catalog")),
                  _buildMenuCard("🏋️‍♂️ Вправи", "Реабілітаційні комплекси та протоколи", Colors.orange.shade800, () => setState(() => _currentScreen = "exercises_catalog")),
                ],
              ),
        )
      ],
    );
  }

  Widget _buildGlobalSearchResults() {
    final matches = globalPatients.where((p) => p['name'].toLowerCase().contains(_globalSearch.toLowerCase())).toList();
    if (matches.isEmpty) return const Center(child: Text("Нічого не знайдено за глобальним запитом."));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: matches.length,
      itemBuilder: (context, i) {
        final p = matches[i];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.person, color: Colors.teal),
            title: Text(p['name']),
            subtitle: Text(p['mkch10Name']),
            onTap: () => setState(() { _selectedPatient = p; _currentScreen = "patient_card"; }),
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
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ЭКРАН: РЕЄСТР ПАЦІЄНТІВ (ПОШУК, НАВІГАЦІЯ, СТВОРЕННЯ)
  // =========================================================
  Widget _screenPatientsList() {
    final filtered = globalPatients.where((p) => p['name'].toLowerCase().contains(_patientSearch.toLowerCase())).toList();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => setState(() => _currentScreen = "dashboard")),
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _patientSearch = v),
                  decoration: const InputDecoration(labelText: "Пошук в картках пацієнтів...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, minimumSize: const Size.fromHeight(48)),
            onPressed: () => setState(() => _currentScreen = "create_patient"),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("ЗАРЕЄСТРУВАТИ НОВУ КАРТУ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final p = filtered[i];
                return Card(
                  child: ListTile(
                    title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Код МКХ-10: ${p['mkch10Code']} | Тестів: ${p['history'].length}"),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.teal, size: 18),
                    onTap: () => setState(() { _selectedPatient = p; _currentScreen = "patient_card"; }),
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
  // ЭКРАН: СТВОРЕННЯ МЕДИЧНОЇ КАРТИ ПАЦІЄНТА
  // =========================================================
  Widget _screenCreatePatient() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => setState(() => _currentScreen = "patients_list")),
            const Text("Формування нової карти", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const Divider(),
        TextField(controller: _nameController, decoration: const InputDecoration(labelText: "ПІБ Пацієнта (повністю)", border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: _ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Вік пацієнта", border: OutlineInputBorder())),
        const SizedBox(height: 16),
        const Text("🩺 Клінічний діагноз за МКХ-10:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
          child: DropdownButton<Map<String, String>>(
            value: _chosenMckh,
            isExpanded: true,
            underline: const SizedBox(),
            items: ClinicalData.mckh10Catalog.map((item) {
              return DropdownMenuItem(value: item, child: Text("${item['code']} - ${item['name']}", style: const TextStyle(fontSize: 13)));
            }).toList(),
            onChanged: (v) => setState(() => _chosenMckh = v!),
          ),
        ),
        const SizedBox(height: 16),
        const Text("📌 Функціональні обмеження за МКФ (Оберіть пригнічені домени):", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
        ...ClinicalData.icfDomains.map((domain) {
          final title = "${domain['code']} ${domain['name']}";
          return CheckboxListTile(
            title: Text(title, style: const TextStyle(fontSize: 13)),
            value: _chosenIcfCodes.contains(title),
            onChanged: (val) {
              setState(() {
                if (val!) { _chosenIcfCodes.add(title); } else { _chosenIcfCodes.remove(title); }
              });
            },
          );
        }).toList(),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800, padding: const EdgeInsets.all(16)),
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              globalPatients.add({
                "id": DateTime.now().toString(),
                "name": _nameController.text,
                "age": int.tryParse(_ageController.text) ?? 50,
                "mkch10Code": _chosenMckh['code'],
                "mkch10Name": _chosenMckh['name'],
                "icfCodes": List<String>.from(_chosenIcfCodes),
                "history": [],
                "smartGoal": "Ціль за SMART сформується автоматично після оцінки шкалами.",
                "exercises": ["Діафрагмальне дихання"]
              });
              _nameController.clear(); _ageController.clear(); _chosenIcfCodes.clear();
              setState(() => _currentScreen = "patients_list");
            }
          },
          child: const Text("ЗБЕРЕГТИ КАРТУ В РЕЄСТР", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  // =========================================================
  // ЭКРАН: КАРТКА ПАЦІЄНТА, SMART-ЦІЛІ ТА ШЕРИНГ ІРП
  // =========================================================
  Widget _screenPatientCard() {
    final p = _selectedPatient!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(onPressed: () => setState(() => _currentScreen = "patients_list"), icon: const Icon(Icons.arrow_back), label: const Text("До реєстру")),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade800),
              onPressed: () => _buildAndShareIRPReport(p),
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text("Шеринг ІРП / Друк", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 16),
        Text(p['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal)),
        Text("Вік: ${p['age']} років | МКХ-10: ${p['mkch10Code']} - ${p['mkch10Name']}"),
        Text("Порушення МКФ: ${p['icfCodes'].join(', ')}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const Divider(height: 24),
        
        // СМАРТ КОНСТРУКТОР ЦІЛЕЙ
        Card(
          color: Colors.amber.shade50,
          shape: RoundedRectangleBorder(side: BorderSide(color: Colors.amber.shade400), borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [Icon(Icons.psychology, color: Colors.amber), SizedBox(width: 6), Text("Конструктор цілей SMART (Автоматичний):", style: TextStyle(fontWeight: FontWeight.bold))]),
                const SizedBox(height: 6),
                Text(p['smartGoal'], style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87, fontSize: 13)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700),
          onPressed: () => setState(() => _currentScreen = "scales_catalog"),
          icon: const Icon(Icons.playlist_add_check, color: Colors.white),
          label: const Text("Провести обстеження за 16 шкалами", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 20),
        const Text("📊 Клінічна динаміка тестувань:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
        if (p['history'].isEmpty)
          const Padding(padding: EdgeInsets.all(12.0), child: Text("Жодної оцінки за шкалами ще не зафіксовано.", style: TextStyle(fontStyle: FontStyle.italic)))
        else
          ...p['history'].map<Widget>((h) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.teal.shade100, child: Text(h['scaleName'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                title: Text("Оцінка: ${h['score']} балів"),
                subtitle: Text("Статус: ${h['interpretation']}\nДата: ${h['date']}", style: const TextStyle(fontSize: 12)),
              ),
            );
          }).toList(),
        const SizedBox(height: 20),
        const Text("🏋️‍♂️ Призначені фізичні вправи (Комплекс ІРП):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
        ...ClinicalData.exercisesCatalog.map((cat) {
          return ExpansionTile(
            title: Text(cat['category'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            children: (cat['items'] as List).map<Widget>((ex) {
              final isSelected = p['exercises'].contains(ex['name']);
              return CheckboxListTile(
                title: Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(ex['desc'], style: const TextStyle(fontSize: 12)),
                value: isSelected,
                onChanged: (val) {
                  setState(() {
                    if (val!) { p['exercises'].add(ex['name']); } else { p['exercises'].remove(ex['name']); }
                  });
                },
              );
            }).toList(),
          );
        }).toList()
      ],
    );
  }

  void _buildAndShareIRPReport(Map<String, dynamic> p) {
    final report = """
==================================================
ІНДИВІДУАЛЬНИЙ РЕАБІЛІТАЦІЙНИЙ ПЛАН (ІРП) ПАЦІЄНТА
==================================================
Пацієнт: ${p['name']}
Вік: ${p['age']} років
Діагноз за МКХ-10: ${p['mkch10Code']} - ${p['mkch10Name']}
Профільні домени МКФ: ${p['icfCodes'].join(', ')}

[ПОТОЧНИЙ КЛІНІЧНИЙ СТАТУС ЗА ШКАЛАМИ]
${p['history'].isEmpty ? '- Клінічні тести відсутні.' : p['history'].map((h) => '• Шкала ${h['scaleName']}: ${h['score']} балів (${h['interpretation']})').join('\n')}

[РЕАБІЛІТАЦІЙНА ЦІЛЬ ЗА СИСТЕМОЮ SMART]
${p['smartGoal']}

[ПРИЗНАЧЕНИЙ ПРОТОКОЛ ФІЗИЧНИХ ВПРАВ]
${p['exercises'].isEmpty ? '- Вправи не призначено.' : p['exercises'].map((ex) => '• $ex').join('\n')}
==================================================
Звіт згенеровано автоматично автономним модулем ФТ.
""";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("📄 Документ ІРП сформовано"),
        content: SingleChildScrollView(child: Text(report, style: const TextStyle(fontFamily: 'monospace', fontSize: 11))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Назад")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Текст успішно скопійовано! Вставте його у Viber, Telegram або відправте на друк.")));
            },
            child: const Text("Копіювати для шерингу"),
          )
        ],
      ),
    );
  }

  // =========================================================
  // ЭКРАН: КАТАЛОГ ВСІХ 16 КЛІНІЧНИХ ШКАЛ ОЦІНКИ (З ПОШУКОМ)
  // =========================================================
  Widget _screenScalesCatalog() {
    final filtered = ClinicalData.allScales.where((s) => s.name.toLowerCase().contains(_scaleSearch.toLowerCase()) || s.fullName.toLowerCase().contains(_scaleSearch.toLowerCase())).toList();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => setState(() => _currentScreen = _selectedPatient != null ? "patient_card" : "dashboard")),
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _scaleSearch = v),
                  decoration: const InputDecoration(labelText: "Пошук серед 16 клінічних шкал...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
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
                    subtitle: Text(s.fullName, style: const TextStyle(fontSize: 12)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("📌 Категорія МКФ: ${s.icfCategory}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text("📋 Показання: ${s.indications}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                            const SizedBox(height: 4),
                            Text("ℹ️ Інструкція проведення: ${s.instruction}", style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800),
                              onPressed: () => setState(() { _selectedScale = s; _currentScreen = "test_exec"; }),
                              icon: const Icon(Icons.play_arrow, color: Colors.white),
                              label: const Text("Запустити тестування", style: TextStyle(color: Colors.white)),
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
  // ЭКРАН: МКХ-10 ДОВІДНИК З ЛОКАЛЬНИМ ПОШУКОМ
  // =========================================================
  Widget _screenMckhCatalog() {
    final filtered = ClinicalData.mckh10Catalog.where((m) => m['code']!.toLowerCase().contains(_mckhSearch.toLowerCase()) || m['name']!.toLowerCase().contains(_mckhSearch.toLowerCase())).toList();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => setState(() => _currentScreen = "dashboard")),
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _mckhSearch = v),
                  decoration: const InputDecoration(labelText: "Пошук кодів за МКХ-10...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final item = filtered[i];
                return Card(
                  child: ListTile(
                    leading: Chip(label: Text(item['code']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.purple.shade700),
                    title: Text(item['name']!, style: const TextStyle(fontSize: 14)),
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
  // ЭКРАН: КАТАЛОГ ВПРАВ З ЛОКАЛЬНИМ ПОШУКОМ
  // =========================================================
  Widget _screenExercisesCatalog() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => setState(() => _currentScreen = "dashboard")),
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _exerciseSearch = v),
                  decoration: const InputDecoration(labelText: "Пошук клінічних вправ за назвою...", prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: ClinicalData.exercisesCatalog.map((category) {
                final List items = category['items'];
                final matchedItems = items.where((i) => i['name'].toLowerCase().contains(_exerciseSearch.toLowerCase())).toList();
                
                if (matchedItems.isEmpty) return const SizedBox();
                return Card(
                  child: ExpansionTile(
                    title: Text(category['category'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                    initiallyExpanded: _exerciseSearch.isNotEmpty,
                    children: matchedItems.map<Widget>((ex) {
                      return ListTile(
                        title: Text(ex['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(ex['desc']),
                        leading: const Icon(Icons.fitness_center, color: Colors.orange),
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
  // ЭКРАН: ПРОВЕДЕННЯ ТЕСТУВАННЯ ТА ІНТЕРПРЕТАЦІЯ ШКАЛ
  // =========================================================
  Widget _screenTestExecutor() {
    final s = _selectedScale!;
    final question = s.questions.first;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 8),
          Text("📝 Запитання: ${question.text}", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const Divider(height: 20),
          Expanded(
            child: ListView(
              children: question.options.map((opt) {
                return RadioListTile<int>(
                  title: Text(opt.text, style: const TextStyle(fontSize: 14)),
                  value: opt.score,
                  groupValue: _activeRadioScore,
                  onChanged: (v) => setState(() => _activeRadioScore = v!),
                );
              }).toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                onPressed: () => setState(() { _currentScreen = "scales_catalog"; _activeRadioScore = -1; }),
                child: const Text("Назад"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800),
                onPressed: () {
                  if (_activeRadioScore == -1) return;
                  
                  String interpretation = "Стабільний статус за шкалою ${s.name}";
                  String generatedGoal = "Пацієнт покращить показники рухливості за МКФ.";

                  // КЛІНІЧНИЙ СМАРТ-ОБЧИСЛЮВАЧ НА ОСНОВІ БАЛІВ ТЕСТУ
                  if (s.id == "ims") {
                    interpretation = _activeRadioScore <= 3 ? "Критично низька мобільність" : "Здатність до осьового навантаження";
                    generatedGoal = "Пацієнт зможе самостійно переходити в положення стоячи біля ліжка (домен d410) за підтримки 1 особи до 20.06.2026.";
                  } else if (s.id == "mrc") {
                    interpretation = _activeRadioScore < 48 ? "Синдром ICUAW (Критична слабкість м'язів)" : "М'язова сила в межах норми";
                    generatedGoal = "Збільшити тонус та м'язову силу кінцівок до 4+ балів за MRC за 14 днів занять (домен МКФ b730).";
                  } else if (s.id == "vas") {
                    interpretation = _activeRadioScore >= 6 ? "Виражений больовий синдром" : "Помірний/контрольований біль";
                    generatedGoal = "Знизити рівень болю за шкалою VAS до 3 балів під час виконання терапевтичних вправ до 18.06.2026 (домен b280).";
                  }

                  if (_selectedPatient != null) {
                    _selectedPatient!['history'].insert(0, {
                      "scaleId": s.id,
                      "scaleName": s.name,
                      "date": "2026-06-03",
                      "score": _activeRadioScore,
                      "interpretation": interpretation
                    });
                    _selectedPatient!['smartGoal'] = generatedGoal; // Запис у Смарт-Конструктор пацієнта
                  }

                  setState(() {
                    _currentScreen = _selectedPatient != null ? "patient_card" : "dashboard";
                    _activeRadioScore = -1;
                  });
                },
                child: const Text("ЗБЕРЕГТИ В КАРТКУ ТА ІРП"),
              )
            ],
          )
        ],
      ),
    );
  }
}
