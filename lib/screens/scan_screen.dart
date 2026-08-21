import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

class ScanScreen extends StatefulWidget {
  final String title;
  final Future<bool> Function(String) onCodeScanned; // تابعی که بعد از اسکن صدا زده می‌شود

  const ScanScreen({
    super.key,
    required this.title,
    required this.onCodeScanned,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          ZXingReaderWidget(
            onScan: (result) async {
              final code = result.text;
              // اسکن انجام شد؛ تابع والد را صدا بزن
              final success = await widget.onCodeScanned(code);
              if (success) {
                Navigator.pop(context); // بستن صفحه در صورت موفقیت
              } else {
                // نمایش خطا و ادامه اسکن
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('کد نامعتبر است')),
                );
              }
            },
          ),
          // راهنمای کاربر
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black54,
                child: const Text(
                  'بارکد QR را مقابل دوربین بگیرید',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}