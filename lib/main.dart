import 'package:flutter/material.dart';
import 'screens/main_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ВІТ Реабілітація',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E293B),
        useMaterial3: true, // Виправлено тут!
      ),
      home: const MainListScreen(),
    );
  }
}
