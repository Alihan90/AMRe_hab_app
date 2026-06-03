```dart
import 'package:flutter/material.dart';
import '../data/clinical_data.dart';
import '../models/scale_model.dart';

class ScalesListScreen extends StatefulWidget {
  const ScalesListScreen({Key? key}) : super(key: key);

  @override
  State<ScalesListScreen> createState() => _ScalesListScreenState();
}

class _ScalesListScreenState extends State<ScalesListScreen> {
  // Набір ID шкал, які зараз розгорнуті для перегляду інструкції
  final Set<String> _expandedScaleIds = {};

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedScaleIds.contains(id)) {
        _expandedScaleIds.remove(id);
      } else {
        _expandedScaleIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scales = ClinicalData.allScales;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Клінічні шкали та тести'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: scales.length,
        itemBuilder: (context, index) {
          final scale = scales[index];
          final isExpanded = _expandedScaleIds.contains(scale.id);

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Основна інформація картки
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        color: Colors.teal, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  title: Text(
                    scale.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.top(4.0),
                    child: Text(
                      "МКФ: ${scale.icfCategory}",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      isExpanded ? Icons.info : Icons.info_outline,
                      color: Colors.teal,
                    ),
                    onPressed: () => _toggleExpand(scale.id),
                  ),
                ),

                // Блок з інструкцією та описом, який розгортається
                if (isExpanded)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.menu_book, size: 18, color: Colors.amber McCutcheon = Colors.amber.shade800),
                            SizedBox(width: 6),
                            Text(
                              "Інструкція та обґрунтування:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          scale.instruction,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.3
                          ),
                        ),
                      ],
                    ),
                  ),

                // Кнопка для запуску тестування
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0, top: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Додамо перехід на екран проведення конкретного тесту в наступному кроці
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Запуск тесту: ${scale.id}')),
                          );
                        },
                        icon: const Icon(Icons.play_arrow, color: Colors.teal),
                        label: const Text(
                          'Почати тестування',
                          style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
