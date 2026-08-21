import 'package:flutter/material.dart';
import '../db/database_service.dart';
import '../models/student.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لیست دانش‌آموزان')),
      body: FutureBuilder<List<Student>>(
        future: DatabaseService.instance.getAllStudents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                title: Text(student.name),
                subtitle: Text('${student.className} - ${student.studentNumber}'),
                trailing: Text(student.qrCode),
              );
            },
          );
        },
      ),
    );
  }
}