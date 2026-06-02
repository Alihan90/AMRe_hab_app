import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const VitRehabApp());
}

class VitRehabApp extends StatelessWidget {
  const VitRehabApp({super.key}); // Спрощений та повністю правильний конструктор

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ВІТ Реабілітація',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF1E293B),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E293B),
          primary: const Color(0xFF1E293B),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
