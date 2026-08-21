import 'package:flutter/material.dart';
import '../db/database_service.dart';
import '../models/settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // کنترلرها
  final _studentLoanDays = TextEditingController();
  final _studentMaxBooks = TextEditingController();
  final _studentMaxRenews = TextEditingController();

  final _teacherLoanDays = TextEditingController();
  final _teacherMaxBooks = TextEditingController();
  final _teacherMaxRenews = TextEditingController();

  final _finePerDay = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await DatabaseService.instance.getSettings();
    setState(() {
      _studentLoanDays.text = settings.studentLoanDays.toString();
      _studentMaxBooks.text = settings.studentMaxBooks.toString();
      _studentMaxRenews.text = settings.studentMaxRenews.toString();

      _teacherLoanDays.text = settings.teacherLoanDays.toString();
      _teacherMaxBooks.text = settings.teacherMaxBooks.toString();
      _teacherMaxRenews.text = settings.teacherMaxRenews.toString();

      _finePerDay.text = settings.finePerDay.toString();
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final settings = Settings()
        ..studentLoanDays = int.parse(_studentLoanDays.text)
        ..studentMaxBooks = int.parse(_studentMaxBooks.text)
        ..studentMaxRenews = int.parse(_studentMaxRenews.text)
        ..teacherLoanDays = int.parse(_teacherLoanDays.text)
        ..teacherMaxBooks = int.parse(_teacherMaxBooks.text)
        ..teacherMaxRenews = int.parse(_teacherMaxRenews.text)
        ..finePerDay = double.parse(_finePerDay.text.replaceAll(',', '.'));

      await DatabaseService.instance.updateSettings(settings);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تنظیمات ذخیره شد')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تنظیمات دانش‌آموزان',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildNumberField(
                controller: _studentLoanDays,
                label: 'مدت امانت (روز)',
              ),
              _buildNumberField(
                controller: _studentMaxBooks,
                label: 'حداکثر تعداد کتاب',
              ),
              _buildNumberField(
                controller: _studentMaxRenews,
                label: 'حداکثر تمدید',
              ),
              const SizedBox(height: 24),
              const Text(
                'تنظیمات معلمان',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildNumberField(
                controller: _teacherLoanDays,
                label: 'مدت امانت (روز)',
              ),
              _buildNumberField(
                controller: _teacherMaxBooks,
                label: 'حداکثر تعداد کتاب',
              ),
              _buildNumberField(
                controller: _teacherMaxRenews,
                label: 'حداکثر تمدید',
              ),
              const SizedBox(height: 24),
              const Text(
                'سایر تنظیمات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildNumberField(
                controller: _finePerDay,
                label: 'جریمه روزانه (تومان)',
                isDouble: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('ذخیره تنظیمات'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    bool isDouble = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: isDouble
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) return 'الزامی است';
          if (isDouble) {
            if (double.tryParse(value.replaceAll(',', '.')) == null) {
              return 'عدد معتبر وارد کنید';
            }
          } else {
            if (int.tryParse(value) == null) {
              return 'عدد صحیح وارد کنید';
            }
          }
          return null;
        },
      ),
    );
  }
}