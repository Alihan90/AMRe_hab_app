import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const VitRehabApp());
}

class VitRehabApp extends StatelessWidget {
  const VitRehabApp({Key? super.key}) : super(key: super);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ВІТ Реабілітація',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
      home: const MainDashboardScreen(),
    );
  }
}

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({Key? super.key}) : super(key: super);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("ВІТ-Реабілітація: Панель Лікаря", style: TextStyle(color: Colors.white)),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Робочий простір МРК (Мультидисциплінарної команди)",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildMenuCard(context, "Карта Пацієнта", Icons.assignment_ind_rounded, const PatientCardsScreen(), Colors.blue),
                  _buildMenuCard(context, "SMART Майстер", Icons.psychology_rounded, const SmartConstructorScreen(), Colors.purple),
                  _buildMenuCard(context, "Шкала IMS", Icons.accessibility_new_rounded, const ImsTestingScreen(), Colors.green),
                  _buildMenuCard(context, "Сила MRC", Icons.fitness_center_rounded, const MrcSumScoreScreen(), Colors.teal),
                  _buildMenuCard(context, "Base Вправ", Icons.directions_run_rounded, const ExerciseBaseScreen(currentPatientIms: 3), Colors.orange),
                  _buildMenuCard(context, "Аналітика", Icons.trending_up_rounded, const PatientAnalyticsScreen(), Colors.indigo),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                icon: const Icon(Icons.print_rounded),
                label: const Text("Передперегляд та Друк Епікризу (А4)"),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EpicrisisPreviewScreen())),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Widget targetScreen, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class PatientCardData {
  String fullName = "";
  String birthDate = "";
  String icd10Code = "Не обрано";
  String icd10Name = "Оберіть діагноз із довідника";
  List<String> selectedScales = [];
  List<String> selectedExercises = [];
  String smartGoalText = "";
}

class PatientCardsScreen extends StatefulWidget {
  const PatientCardsScreen({Key? super.key}) : super(key: super);

  @override
  State<PatientCardsScreen> createState() => _PatientCardsScreenState();
}

class _PatientCardsScreenState extends State<PatientCardsScreen> {
  final PatientCardData _currentPatient = PatientCardData();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _smartGoalController = TextEditingController();

  void _selectIcd10Diagnosis() async {
    final selectedDisease = await Navigator.push(context, MaterialPageRoute(builder: (_) => const Icd10DirectoryScreen()));
    if (selectedDisease != null) {
      setState(() {
        _currentPatient.icd10Code = selectedDisease.code;
        _currentPatient.icd10Name = selectedDisease.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue, title: const Text("Карта Пацієнта (Редактор)")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: "ПІБ Пацієнта", prefixIcon: Icon(Icons.person))),
                    const SizedBox(height: 12),
                    TextField(controller: _ageController, decoration: const InputDecoration(labelText: "Вік / Дата народження", prefixIcon: Icon(Icons.calendar_today))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Chip(label: Text(_currentPatient.icd10Code, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.blue[900]),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_currentPatient.icd10Name, style: const TextStyle(fontWeight: FontWeight.w500))),
                        IconButton(icon: const Icon(Icons.search, color: Colors.blue), onPressed: _selectIcd10Diagnosis)
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("SMART-ЦІЛЬ РЕАБІЛІТАЦІЇ:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(controller: _smartGoalController, maxLines: 3, decoration: const InputDecoration(hintText: "Вкажіть або згенеруйте ціль...")),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], foregroundColor: Colors.white),
                icon: const Icon(Icons.share),
                label: const Text("Експорт в PDF / Надіслати"),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("PDF сформовано!")));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Icd10DirectoryScreen extends StatelessWidget {
  const Icd10DirectoryScreen({Key? super.key}) : super(key: super);

  @override
  Widget build(BuildContext context) {
    final List<_DiseaseStub> diseases = [
      _DiseaseStub("I63.9", "Інфаркт головного мозку (Ішемічний інсульт)"),
      _DiseaseStub("T08", "Перелом хребта на неуточненому рівні"),
      _DiseaseStub("G72.8", "Інша уточнена міопатія (Синдром ICUAW у ВІТ)"),
      _DiseaseStub("S72.0", "Перелом шийки стегна"),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Довідник МКХ-10")),
      body: ListView.builder(
        itemCount: diseases.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(child: Text(diseases[index].code[0])),
            title: Text("${diseases[index].code} ${diseases[index].name}"),
            onTap: () => Navigator.pop(context, diseases[index]),
          );
        },
      ),
    );
  }
}
class _DiseaseStub { final String code; final String name; _DiseaseStub(this.code, this.name); }

class SmartConstructorScreen extends StatefulWidget {
  const SmartConstructorScreen({Key? super.key}) : super(key: super);

  @override
  State<SmartConstructorScreen> createState() => _SmartConstructorScreenState();
}

class _SmartConstructorScreenState extends State<SmartConstructorScreen> {
  final TextEditingController _sController = TextEditingController();
  final TextEditingController _mController = TextEditingController();
  final TextEditingController _finalGoalController = TextEditingController();

  void _assembleGoal() {
    setState(() {
      _finalGoalController.text = "Пацієнт зміг ${_sController.text.trim()}, ${_mController.text.trim()}, самостійно під контролем терапевта у термін до 5 днів.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.purple, title: const Text("SMART Конструктор")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("S - Специфічна дія пацієнта:", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(value: "перейти в положення сидячи", child: Text("перейти в положення сидячи")),
                DropdownMenuItem(value: "встати з ліжка в ходунки", child: Text("встати з ліжка в ходунки")),
              ],
              onChanged: (val) => setState(() => _sController.text = val!),
            ),
            TextField(controller: _sController, decoration: const InputDecoration(hintText: "Або впишіть дію вручну...")),
            const SizedBox(height: 16),
            const Text("M - Критерій вимірювання:", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _mController, decoration: const InputDecoration(hintText: "Наприклад: протягом 5 хвилин без підтримки")),
            const SizedBox(height: 20),
            Center(child: ElevatedButton(onPressed: _assembleGoal, style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white), child: const Text("Сформувати фінальну ціль"))),
            const SizedBox(height: 16),
            TextField(controller: _finalGoalController, maxLines: 3, decoration: const InputDecoration(labelText: "Результат")),
          ],
        ),
      ),
    );
  }
}

class ImsTestingScreen extends StatefulWidget {
  const ImsTestingScreen({Key? super.key}) : super(key: super);

  @override
  State<ImsTestingScreen> createState() => _ImsTestingScreenState();
}

class _ImsTestingScreenState extends State<ImsTestingScreen> {
  int _selectedScore = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.green, title: const Text("Тестування: Шкала IMS")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Оберіть найвищий досягнутий рівень мобільності за 24 год:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(4, (index) {
            List<String> labels = ["IMS 0: Пасивний ліжковий режим", "IMS 1: Вправи в ліжку", "IMS 2: Пасивне висаджування", "IMS 3: Сидіння на краю ліжка (Баланс)"];
            return RadioListTile<int>(
              title: Text(labels[index]),
              value: index,
              groupValue: _selectedScore,
              onChanged: (val) => setState(() => _selectedScore = val!),
            );
          }),
          const Divider(),
          Text(_selectedScore <= 2 ? "⚠️ Безпека: Дозволена лише пасивна мобілізація." : "✅ Безпека: Дозволено тренування балансу.", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        ],
      ),
    );
  }
}

class MrcSumScoreScreen extends StatefulWidget {
  const MrcSumScoreScreen({Key? super.key}) : super(key: super);

  @override
  State<MrcSumScoreScreen> createState() => _MrcSumScoreScreenState();
}

class _MrcSumScoreScreenState extends State<MrcSumScoreScreen> {
  int _shoulderLeft = 4;
  int _shoulderRight = 4;

  @override
  Widget build(BuildContext context) {
    int total = (_shoulderLeft + _shoulderRight) * 3;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.teal, title: const Text("Тест сили: MRC-SumScore")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: total < 48 ? Colors.red[100] : Colors.green[100],
              child: ListTile(title: const Text("Загальний Бал MRC:"), trailing: Text("$total / 60 б.", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
            const SizedBox(height: 16),
            const Text("Відвідні м'язи плеча (0-5 балів):", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DropdownButton<int>(value: _shoulderLeft, items: List.generate(6, (i) => DropdownMenuItem(value: i, child: Text("Зліва: $i"))), onChanged: (v) => setState(() => _shoulderLeft = v!)),
                DropdownButton<int>(value: _shoulderRight, items: List.generate(6, (i) => DropdownMenuItem(value: i, child: Text("Справа: $i"))), onChanged: (v) => setState(() => _shoulderRight = v!)),
              ],
            ),
            const Spacer(),
            if (total < 48) const Text("🚨 ВИЯВЛЕНО СИНДРОМ ICUAW (Слабкість у ВІТ)", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class ExerciseBaseScreen extends StatelessWidget {
  final int currentPatientIms;
  const ExerciseBaseScreen({Key? super.key, required this.currentPatientIms}) : super(key: super);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.orange, title: const Text("База Кінезіотерапії")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExRow("1. Губний гальмуючий видих", 0, "Респіраторна"),
          _buildExRow("2. Пасивні рухи (Суглобова гімнастика)", 0, "Пасивна"),
          _buildExRow("3. Сидіння на краю кушетки з підтримкою", 3, "Вертикалізація"),
          _buildExRow("4. Ходьба з високими ходунками", 6, "Локомоція"),
        ],
      ),
    );
  }

  Widget _buildExRow(String name, int minIms, String cat) {
    bool isAllowed = currentPatientIms >= minIms;
    return Card(
      color: isAllowed ? Colors.white : Colors.red[50],
      child: ListTile(
        title: Text(name),
        subtitle: Text("Категорія: $cat | Мін. IMS: $minIms"),
        trailing: isAllowed ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.block, color: Colors.red),
      ),
    );
  }
}

class PatientAnalyticsScreen extends StatelessWidget {
  const PatientAnalyticsScreen({Key? super.key}) : super(key: super);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.indigo, title: const Text("Графіки відновлення")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text("Динаміка індексу мобільності IMS по днях госпіталізації:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [const FlSpot(1, 0), const FlSpot(3, 1), const FlSpot(5, 3), const FlSpot(7, 5), const FlSpot(10, 8)],
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 4,
                    )
                  ]
                )
              ),
            ),
            const SizedBox(height: 20),
            const Text("📈 Середній темп приросту позитивний, програма реабілітації ефективна.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}

class EpicrisisPreviewScreen extends StatelessWidget {
  const EpicrisisPreviewScreen({Key? super.key}) : super(key: super);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[700],
      appBar: AppBar(backgroundColor: const Color(0xFF1E293B), title: const Text("Екранна форма бланку друку")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Container(
            width: double.infinity,
            maxWidth: 600,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("КНП 'ОБЛАСНА КЛІНІЧНА ЛІКАРНЯ' | ФОРМА № 025/о", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                Divider(color: Colors.black),
                Center(child: Text("РЕАБІЛІТАЦІЙНИЙ ВИСНОВОК (ЕПІКРИЗ)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                SizedBox(height: 12),
                Text("Пацієнт: Коваленко О.П., 54 роки.", style: TextStyle(fontSize: 12)),
                Text("Діагноз МКХ-10: I63.3 Інсульт з лівобічним геміпарезом.", style: TextStyle(fontSize: 12)),
                Text("Динаміка за шкалами: IMS підвищено з 0 до 8 балів. Синдром ICUAW ліквідовано (MRC 58/60).", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text("Проведена терапія: Комплекс дихальної кінезіотерапії, рання вертикалізація.", style: TextStyle(fontSize: 12)),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Лікар ФРМ: ___________"), Text("Дата: 02.06.2026")],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
