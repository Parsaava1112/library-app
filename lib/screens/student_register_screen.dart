import 'package:flutter/material.dart';
import '../db/database_service.dart';
import '../models/student.dart';
import '../utils/qr_utils.dart';
import '../screens/qr_label_screen.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _classController = TextEditingController();
  final _studentNumberController = TextEditingController();

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final student = Student()
        ..name = _nameController.text.trim()
        ..className = _classController.text.trim()
        ..studentNumber = _studentNumberController.text.trim();

      await DatabaseService.instance.addStudent(student);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QrLabelScreen(student: student),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ثبت دانش‌آموز جدید')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'نام و نام خانوادگی *'),
                validator: (v) => v!.isEmpty ? 'الزامی است' : null,
              ),
              TextFormField(
                controller: _classController,
                decoration: const InputDecoration(labelText: 'کلاس *'),
                validator: (v) => v!.isEmpty ? 'الزامی است' : null,
              ),
              TextFormField(
                controller: _studentNumberController,
                decoration: const InputDecoration(labelText: 'شماره دانش‌آموزی *'),
                validator: (v) => v!.isEmpty ? 'الزامی است' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('ذخیره و تولید کارت QR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}