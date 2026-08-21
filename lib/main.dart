import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'کتابخانه مدرسه',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Vazir', // اگر فونت فارسی اضافه کنید
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}