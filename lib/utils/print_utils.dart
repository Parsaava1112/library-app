import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<void> printLabel({
  required String title,
  required String code,
  required Uint8List qrImageBytes,
}) async {
  final doc = pw.Document();
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(4 * PdfPageFormat.cm, 2.5 * PdfPageFormat.cm),
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Image(pw.MemoryImage(qrImageBytes), width: 50, height: 50),
              pw.SizedBox(height: 2),
              pw.Text(title, style: pw.TextStyle(fontSize: 8)),
              pw.Text(code, style: pw.TextStyle(fontSize: 8)),
            ],
          ),
        );
      },
    ),
  );
  await Printing.layoutPdf(onLayout: (format) async => doc.save());
}