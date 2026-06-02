import 'package:flutter/material.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  // Поточний фільтр: 0 - Всі, 1 - У ліжку (IMS 0-1), 2 - Сидячи (IMS 2-3), 3 - Стоячи/Ходьба (IMS 4+)
  int _selectedFilter = 0;

  final List<Map<String, dynamic>> _allExercises = [
    {
      'title': 'Пасивні дихальні вправи',
      'category': 'У ліжку (IMS 0-1)',
      'filterId': 1,
      'desc': 'Синхронізація дихання з пасивним відведенням рук. Профілактика гіпостатичної пневмонії.',
      'time': '5-7 хв'
    },
    {
      'title': 'Циклічне пасивне тренування стоп',
      'category': 'У ліжку (IMS 0-1)',
      'filterId': 1,
      'desc': 'Профілактика тромбозу глибоких вен та контрактур гомілковостопного суглоба.',
      'time': '10 хв'
    },
    {
      'title': 'Тренування балансу сидіння на краю ліжка',
      'category': 'Сидячи (IMS 2-3)',
      'filterId': 2,
      'desc': 'Активація м\'язів кору. Контроль ортостатичної реакції (адаптація до вертикального положення).',
      'time': '5 хв'
    },
    {
      'title': 'Активне розгинання коліна з опорою',
      'category': 'Сидячи (IMS 2-3)',
      'filterId': 2,
      'desc': 'Зміцнення квадрицепса для підготовки до вставання. Виконується на краю ліжка.',
      'time': '10-12 повторень'
    },
    {
      'title': 'Перенесення ваги тіла біля ліжка',
      'category': 'Стоячи/Ходьба (IMS 4+)',
      'filterId': 3,
      'desc': 'Стимуляція пропріоцепції, підготовка до перших кроків. Виконується зі страховкою.',
      'time': '3-5 хв'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Фільтруємо список залежно від вибору лікаря
    final filteredExercises = _selectedFilter == 0
        ? _allExercises
        : _allExercises.where((ex) => ex['filterId'] == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "База вправ ранньої реабілітації",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Горизонтальний фільтр вгорі екрана
          Container(
            height: 60,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              children: [
                _buildFilterChip(0, "Всі вправи"),
                _buildFilterChip(1, "У ліжку"),
                _buildFilterChip(2, "Сидячи"),
                _buildFilterChip(3, "Стоячи / Ходьба"),
              ],
            ),
          ),
          
          // Список відфільтрованих вправ
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final ex = filteredExercises[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(ex['title'], 
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(ex['time'], 
                                  style: TextStyle(fontSize: 12, color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(ex['category'], style: TextStyle(color: Colors.blue.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(ex['desc'], style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int id, String label) {
    bool isSelected = _selectedFilter == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF1E293B),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (bool selected) {
          setState(() {
            if (selected) _selectedFilter = id;
          });
        },
      ),
    );
  }
}
