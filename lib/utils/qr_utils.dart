import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrUtils {
  static Widget generateQr(String data, {double size = 200}) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
    );
  }

  static String bookQr(int id) => 'LIB-BOOK-$id';
  static String studentQr(int id) => 'LIB-STU-$id';

  static int? extractId(String code, String prefix) {
    if (code.startsWith(prefix)) {
      final idStr = code.substring(prefix.length);
      return int.tryParse(idStr);
    }
    return null;
  }
}