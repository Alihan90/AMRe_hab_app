import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const RehabApp());
}

class RehabApp extends StatelessWidget {
  const RehabApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Фізична Терапія & Шкали',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      home: const HomeScreen(), // Головний екран завантажується першим
    );
  }
}
