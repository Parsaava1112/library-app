import 'package:flutter/material.dart';
import '../widgets/action_card.dart';
import 'book_register_screen.dart';
import 'student_register_screen.dart';
import 'loan_screen.dart';
import 'return_screen.dart';
import 'book_list_screen.dart';
import 'student_list_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('کتابخانه مدرسه')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          ActionCard(
            icon: Icons.book,
            label: 'ثبت کتاب',
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookRegisterScreen()),
            ),
          ),
          ActionCard(
            icon: Icons.person_add,
            label: 'ثبت دانش‌آموز/معلم',
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudentRegisterScreen()),
            ),
          ),
          ActionCard(
            icon: Icons.qr_code_scanner,
            label: 'امانت سریع',
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoanScreen()),
            ),
          ),
          ActionCard(
            icon: Icons.assignment_return,
            label: 'بازگشت کتاب',
            color: Colors.red,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReturnScreen()),
            ),
          ),
          ActionCard(
            icon: Icons.list,
            label: 'لیست کتاب‌ها',
            color: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookListScreen()),
            ),
          ),
          ActionCard(
            icon: Icons.people,
            label: 'لیست اعضا',
            color: Colors.teal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudentListScreen()),
            ),
          ),
          ActionCard(
            icon: Icons.bar_chart,
            label: 'گزارش‌ها',
            color: Colors.indigo,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportsScreen()),
            ),
          ),
          ActionCard(
            icon: Icons.settings,
            label: 'تنظیمات',
            color: Colors.grey,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}