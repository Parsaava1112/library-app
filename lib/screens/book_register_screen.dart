import 'package:flutter/material.dart';
import '../db/database_service.dart';
import '../models/book.dart';
import '../utils/qr_utils.dart';
import '../screens/scan_screen.dart';

class BookRegisterScreen extends StatefulWidget {
  const BookRegisterScreen({super.key});

  @override
  State<BookRegisterScreen> createState() => _BookRegisterScreenState();
}

class _BookRegisterScreenState extends State<BookRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _categoryController = TextEditingController();
  final _shelfController = TextEditingController();
  final _copiesController = TextEditingController(text: '1');
  int? _year;

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final book = Book()
        ..title = _titleController.text.trim()
        ..author = _authorController.text.trim()
        ..publisher = _publisherController.text.trim()
        ..category = _categoryController.text.trim()
        ..shelfLocation = _shelfController.text.trim()
        ..totalCopies = int.parse(_copiesController.text)
        ..availableCopies = int.parse(_copiesController.text)
        ..year = _year;

      await DatabaseService.instance.addBook(book);
      if (!mounted) return;
      // نمایش QR برای چاپ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QrLabelScreen(book: book),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ثبت کتاب جدید')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'عنوان کتاب *'),
                validator: (v) => v!.isEmpty ? 'الزامی است' : null,
              ),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'نویسنده *'),
                validator: (v) => v!.isEmpty ? 'الزامی است' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _publisherController,
                      decoration: const InputDecoration(labelText: 'ناشر'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'دسته‌بندی'),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _shelfController,
                      decoration: const InputDecoration(labelText: 'قفسه'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _copiesController,
                      decoration: const InputDecoration(labelText: 'تعداد نسخه'),
                      keyboardType: TextInputType.number,
                      validator: (v) => int.tryParse(v!) == null ? 'عدد وارد کنید' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('ذخیره و تولید QR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}