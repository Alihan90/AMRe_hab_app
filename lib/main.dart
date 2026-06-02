import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

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
        useMaterial3: true, // Включаємо сучасний дизайн Material 3
        primaryColor: const Color(0xFF1E293B),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Світле приємне тло
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E293B),
          primary: const Color(0xFF1E293B),
        ),
      ),
      home: const DashboardScreen(), // Запускаємо наш створений головний екран
    );
  }
}
