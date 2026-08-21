import 'package:flutter/material.dart';
import '../db/database_service.dart';
import '../models/loan.dart';
import '../models/book.dart';
import '../utils/qr_utils.dart';
import '../screens/scan_screen.dart';

class ReturnScreen extends StatefulWidget {
  const ReturnScreen({super.key});

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  Loan? _activeLoan;
  final _bookCodeController = TextEditingController();

  Future<bool> _scanBook(String code) async {
    final id = QrUtils.extractId(code, 'LIB-BOOK-');
    if (id == null) return false;
    final loans = await DatabaseService.instance.getLoansByBook(id);
    final activeLoans = loans.where((l) => !l.isReturned).toList();
    if (activeLoans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('این کتاب در امانت نیست')),
      );
      return false;
    }
    final loan = activeLoans.last;
    setState(() => _activeLoan = loan);
    return true;
  }

  Future<void> _manualEntry() async {
    final code = _bookCodeController.text.trim();
    if (code.isEmpty) return;
    final success = await _scanBook(code);
    if (!success) {
      // پیام خطا قبلاً نمایش داده شده
    } else {
      _bookCodeController.clear();
    }
  }

  Future<void> _confirmReturn() async {
    if (_activeLoan == null) return;
    await DatabaseService.instance.returnLoan(_activeLoan!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('بازگشت ثبت شد')),
    );
    setState(() => _activeLoan = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بازگشت کتاب')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ورود دستی یا اسکن
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bookCodeController,
                    decoration: InputDecoration(
                      labelText: 'کد QR کتاب',
                      hintText: 'LIB-BOOK-1001',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _manualEntry(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.check_circle),
                  onPressed: _manualEntry,
                  tooltip: 'ثبت کد دستی',
                ),
                IconButton(
                  icon: Icon(Icons.qr_code_scanner),
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
            SizedBox(height: 24),
            Expanded(
              child: _activeLoan == null
                  ? Center(
                      child: Text(
                        'کتابی انتخاب نشده است',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : FutureBuilder(
                      future: DatabaseService.instance.getBookById(_activeLoan!.bookId),
                      builder: (context, snapshot) {
                        final book = snapshot.data;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('کتاب: ${book?.title ?? 'نامشخص'}',
                                style: TextStyle(fontSize: 18)),
                            Text('نویسنده: ${book?.author ?? ''}'),
                            Divider(),
                            Text('دانش‌آموز ID: ${_activeLoan!.studentId}'),
                            Text('تاریخ امانت: ${_activeLoan!.loanDate.toLocal()}'),
                            Text('موعد بازگشت: ${_activeLoan!.dueDate.toLocal()}'),
                            if (_activeLoan!.isOverdue)
                              Text('دیرکرد دارد',
                                  style: TextStyle(color: Colors.red)),
                            SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _confirmReturn,
                              icon: Icon(Icons.check),
                              label: Text('ثبت بازگشت'),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}