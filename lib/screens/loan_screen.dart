import 'package:flutter/material.dart';
import '../db/database_service.dart';
import '../models/book.dart';
import '../models/student.dart';
import '../models/loan.dart';
import '../utils/qr_utils.dart';
import '../screens/scan_screen.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  Book? _selectedBook;
  Student? _selectedStudent;

  final _bookCodeController = TextEditingController();
  final _studentCodeController = TextEditingController();

  @override
  void dispose() {
    _bookCodeController.dispose();
    _studentCodeController.dispose();
    super.dispose();
  }

  // پردازش کد کتاب
  Future<bool> _scanBook(String code) async {
    final id = QrUtils.extractId(code, 'LIB-BOOK-');
    if (id == null) return false;
    final book = await DatabaseService.instance.getBookById(id);
    if (book == null) return false;
    setState(() => _selectedBook = book);
    return true;
  }

  // پردازش کد دانش‌آموز/معلم
  Future<bool> _scanStudent(String code) async {
    final id = QrUtils.extractId(code, 'LIB-STU-');
    if (id == null) return false;
    final student = await DatabaseService.instance.getStudentById(id);
    if (student == null) return false;
    setState(() => _selectedStudent = student);
    return true;
  }

  // ورود دستی کتاب
  Future<void> _manualBookEntry() async {
    final code = _bookCodeController.text.trim();
    if (code.isEmpty) return;
    final success = await _scanBook(code);
    if (!success) {
      _showError('کد کتاب نامعتبر است');
    } else {
      _bookCodeController.clear();
    }
  }

  // ورود دستی دانش‌آموز
  Future<void> _manualStudentEntry() async {
    final code = _studentCodeController.text.trim();
    if (code.isEmpty) return;
    final success = await _scanStudent(code);
    if (!success) {
      _showError('کد دانش‌آموز نامعتبر است');
    } else {
      _studentCodeController.clear();
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // ثبت امانت با اعمال قوانین
  Future<void> _confirmLoan() async {
    if (_selectedBook == null || _selectedStudent == null) return;

    final book = _selectedBook!;
    final student = _selectedStudent!;
    final settings = await DatabaseService.instance.getSettings();

    // تعیین سقف تعداد و مدت امانت بر اساس نقش
    final isTeacher = student.role == 'teacher';
    final maxBooks = isTeacher ? settings.teacherMaxBooks : settings.studentMaxBooks;
    final loanDays = isTeacher ? settings.teacherLoanDays : settings.studentLoanDays;

    // بررسی موجودی کتاب
    if (book.availableCopies <= 0) {
      _showError('این کتاب در حال حاضر موجود نیست');
      return;
    }

    // بررسی تعداد کتاب‌های امانتی فعال کاربر
    final activeLoans = await DatabaseService.instance.getLoansByStudent(student.id);
    final activeCount = activeLoans.where((l) => !l.isReturned).length;
    if (activeCount >= maxBooks) {
      _showError('حداکثر تعداد کتاب مجاز ($maxBooks) رسیده است');
      return;
    }

    // ساخت رکورد امانت
    final loan = Loan()
      ..bookId = book.id
      ..studentId = student.id
      ..dueDate = DateTime.now().add(Duration(days: loanDays));

    await DatabaseService.instance.addLoan(loan);

    _showSuccess('امانت با موفقیت ثبت شد (بازگشت: ${loan.dueDate.toLocal().toString().split(' ')[0]})');

    // پاک‌سازی فرم برای امانت بعدی
    setState(() {
      _selectedBook = null;
      _selectedStudent = null;
    });
    _bookCodeController.clear();
    _studentCodeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('امانت سریع')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // کارت انتخاب کتاب
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.book, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'کتاب',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_selectedBook != null) ...[
                        Text(_selectedBook!.title, style: const TextStyle(fontSize: 16)),
                        Text(_selectedBook!.author ?? '', style: const TextStyle(color: Colors.grey)),
                        Text(
                          'موجودی: ${_selectedBook!.availableCopies}/${_selectedBook!.totalCopies}',
                          style: TextStyle(
                            color: _selectedBook!.availableCopies > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ] else
                        const Text('کتابی انتخاب نشده است', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _bookCodeController,
                              decoration: const InputDecoration(
                                labelText: 'کد QR کتاب',
                                hintText: 'LIB-BOOK-1001',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _manualBookEntry(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: _manualBookEntry,
                            tooltip: 'ثبت کد دستی',
                          ),
                          IconButton(
                            icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ScanScreen(
                                    title: 'اسکن کتاب',
                                    onCodeScanned: _scanBook,
                                  ),
                                ),
                              );
                            },
                            tooltip: 'اسکن با دوربین',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // کارت انتخاب دانش‌آموز/معلم
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'دانش‌آموز / معلم',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_selectedStudent != null) ...[
                        Text(_selectedStudent!.name, style: const TextStyle(fontSize: 16)),
                        Text(
                          '${_selectedStudent!.className} - ${_selectedStudent!.role == 'teacher' ? 'معلم' : 'دانش‌آموز'}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ] else
                        const Text('عضوی انتخاب نشده است', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _studentCodeController,
                              decoration: const InputDecoration(
                                labelText: 'کد QR دانش‌آموز',
                                hintText: 'LIB-STU-2045',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _manualStudentEntry(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: _manualStudentEntry,
                            tooltip: 'ثبت کد دستی',
                          ),
                          IconButton(
                            icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ScanScreen(
                                    title: 'اسکن دانش‌آموز',
                                    onCodeScanned: _scanStudent,
                                  ),
                                ),
                              );
                            },
                            tooltip: 'اسکن با دوربین',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: (_selectedBook != null && _selectedStudent != null)
                    ? _confirmLoan
                    : null,
                icon: const Icon(Icons.check),
                label: const Text('ثبت امانت'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}