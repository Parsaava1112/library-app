import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/student.dart';
import '../utils/qr_utils.dart';

class QrLabelScreen extends StatelessWidget {
  final Book? book;
  final Student? student;

  const QrLabelScreen({super.key, this.book, this.student})
      : assert(book != null || student != null, 'باید یا کتاب یا دانش‌آموز داده شود');

  @override
  Widget build(BuildContext context) {
    final String qrData;
    final String title;
    final String subtitle;

    if (book != null) {
      qrData = book!.qrCode;
      title = book!.title;
      subtitle = 'کتاب - ${book!.author}';
    } else {
      qrData = student!.qrCode;
      title = student!.name;
      subtitle = 'دانش‌آموز - ${student!.className}';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('برچسب QR')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrUtils.generateQr(qrData, size: 250),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text(qrData, style: const TextStyle(fontSize: 14, fontFamily: 'monospace')),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // چاپ لیبل (در اینجا فقط چاپ PDF می‌کنیم)
                    // برای سادگی، فقط یک SnackBar نشان می‌دهیم
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('چاپ در نسخه نهایی فعال می‌شود')),
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('چاپ'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('بازگشت به خانه'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}