import 'package:flutter/material.dart';
import '../db/database_service.dart';
import '../models/loan.dart';
import '../models/book.dart';
import '../models/student.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<List<Loan>> _activeLoansFuture;

  @override
  void initState() {
    super.initState();
    _activeLoansFuture = DatabaseService.instance.getActiveLoans();
  }

  Future<String> _getBookTitle(int bookId) async {
    final book = await DatabaseService.instance.getBookById(bookId);
    return book?.title ?? 'نامشخص';
  }

  Future<String> _getStudentName(int studentId) async {
    final student = await DatabaseService.instance.getStudentById(studentId);
    return student?.name ?? 'نامشخص';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('گزارش‌ها')),
      body: FutureBuilder<List<Loan>>(
        future: _activeLoansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('امانت فعالی وجود ندارد'));
          }
          final activeLoans = snapshot.data!;
          final overdueLoans = activeLoans.where((l) => l.isOverdue).toList();
          final normalLoans = activeLoans.where((l) => !l.isOverdue).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // خلاصه آماری
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'کل امانت‌های فعال',
                          value: activeLoans.length.toString(),
                        ),
                        _StatItem(
                          label: 'دیرکرد',
                          value: overdueLoans.length.toString(),
                          color: Colors.red,
                        ),
                        _StatItem(
                          label: 'در موعد',
                          value: normalLoans.length.toString(),
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text('کتاب‌های دیرکردی',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                if (overdueLoans.isEmpty)
                  Text('موردی یافت نشد')
                else
                  ...overdueLoans.map((loan) => _LoanTile(loan: loan)),
                SizedBox(height: 24),
                Text('همه امانت‌های فعال',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ...activeLoans.map((loan) => _LoanTile(loan: loan)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}

class _LoanTile extends StatelessWidget {
  final Loan loan;

  const _LoanTile({required this.loan});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          loan.isOverdue ? Icons.warning : Icons.check_circle,
          color: loan.isOverdue ? Colors.red : Colors.green,
        ),
        title: FutureBuilder<String>(
          future: _getBookTitle(loan.bookId),
          builder: (context, snapshot) =>
              Text(snapshot.data ?? 'در حال بارگذاری...'),
        ),
        subtitle: FutureBuilder<String>(
          future: _getStudentName(loan.studentId),
          builder: (context, snapshot) =>
              Text('دانش‌آموز: ${snapshot.data ?? '...'}'),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'تا ${loan.dueDate.toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 12),
            ),
            if (loan.isOverdue)
              Text(
                '${DateTime.now().difference(loan.dueDate).inDays} روز تأخیر',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}