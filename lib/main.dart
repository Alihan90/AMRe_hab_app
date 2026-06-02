import 'package:flutter/material.dart';

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
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Робочий простір МРК (Мультидисциплінарної команди)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
            ),
            SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green, size: 32),
                title: Text("Система готова до інтеграції"),
                subtitle: Text("Базовий каркас успішно скомпіровано. Наступним кроком ми розгорнемо повні медичні модулі."),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
