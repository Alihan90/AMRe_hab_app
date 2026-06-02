import 'package:flutter/material.dart';

class SmartGoalScreen extends StatefulWidget {
  const SmartGoalScreen({super.key});

  @override
  State<SmartGoalScreen> createState() => _SmartGoalScreenState();
}

class _SmartGoalScreenState extends State<SmartGoalScreen> {
  // Компоненти конструктора цілей
  String _specific = "самостійно переходити в положення сидіння на краю ліжка";
  String _measurable = "з утриманням балансу протягом 5 хвилин";
  String _achievable = "без підтримки рук та допомоги персоналу";
  String _relevant = "для підготовки до подальшого вставання та ходьби";
  String _timeBound = "до кінця поточного тижня (за 5 днів)";

  // Контроллер для ручного редагування фінального результату
  late TextEditingController _resultController;

  @override
  void initState() {
    super.initState();
    _resultController = TextEditingController(text: _generateGoalText());
  }

  String _generateGoalText() {
    return "Пацієнт зможе $_specific, $_measurable, $_achievable, $_relevant, $_timeBound.";
  }

  void _updateResult() {
    _resultController.text = _generateGoalText();
  }

  @override
  void dispose() {
    _resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "SMART Майстер цілей",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Конструктор реабілітаційної цілі",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 4),
            const Text("Виберіть або відредагуйте кожен параметр SMART:", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),

            // S - Specific (Специфічність)
            _buildDropdownField(
              label: "S - Специфічна дія (Що робити?)",
              value: _specific,
              items: [
                "самостійно переходити в положення сидіння на краю ліжка",
                "самостійно пересаджуватися з ліжка у крісло-коляску",
                "утримувати стояння біля ліжка з опорою на ходунки",
                "зробити 10 кроків по палаті з чотириопорною палицею"
              ],
              onChanged: (val) => setState(() { _specific = val!; _updateResult(); }),
            ),

            // M - Measurable (Вимірюваність)
            _buildDropdownField(
              label: "M - Вимірюваність (Скільки / Як довго?)",
              value: _measurable,
              items: [
                "з утриманням балансу протягом 5 хвилин",
                "протягом 1 хвилини без запаморочення",
                "на відстань до 5 метрів",
                "з рівнем втоми не більше 4 балів за шкалою Борга"
              ],
              onChanged: (val) => setState(() { _measurable = val!; _updateResult(); }),
            ),

            // A - Achievable (Досяжність)
            _buildDropdownField(
              label: "A - Досяжність (Які умови?)",
              value: _achievable,
              items: [
                "без підтримки рук та допомоги персоналу",
                "за допомогою однієї особи (страховка)",
                "використовуючи приліжкову трапецію",
                "з опорою на високі ходунки"
              ],
              onChanged: (val) => setState(() { _achievable = val!; _updateResult(); }),
            ),

            // R - Relevant (Реалістичність / Доцільність)
            _buildDropdownField(
              label: "R - Доцільність (Навіщо це пацієнту?)",
              value: _relevant,
              items: [
                "для підготовки до подальшого вставання та ходьби",
                "для відновлення навичок самообслуговування (прийом їжі)",
                "для можливості самостійного відвідування туалету",
                "для профілактики гіпостатичних ускладнень"
              ],
              onChanged: (val) => setState(() { _relevant = val!; _updateResult(); }),
            ),

            // T - Time-bound (Обмеженість у часі)
            _buildDropdownField(
              label: "T - Час (Коли результат?)",
              value: _timeBound,
              items: [
                "до кінця поточного тижня (за 5 днів)",
                "через 3 дні регулярних тренувань",
                "до моменту переведення з ВІТ (за 7-10 днів)",
                "наприкінці сьогоднішнього заняття"
              ],
              onChanged: (val) => setState(() { _timeBound = val!; _updateResult(); }),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // ФІНАЛЬНИЙ РЕЗУЛЬТАТ (Згенерований текст)
            const Text(
              "Сформована SMART-ціль:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _resultController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.purple.withOpacity(0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.purple),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Кнопка збереження цілі
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("SMART-ціль успішно записана в карту пацієнта!")),
                  );
                  Navigator.pop(context);
                },
                child: const Text("Затвердити ціль", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontSize: 14)));
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
