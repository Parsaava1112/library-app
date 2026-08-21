import 'package:isar/isar.dart';

part 'student.g.dart';

@collection
class Student {
  Id id = Isar.autoIncrement;

  late String name;
  late String className; // برای معلم می‌تواند مثلاً «دبیرستان» یا خالی باشد
  late String studentNumber; // شماره دانش‌آموزی یا کد پرسنلی

  // نقش کاربر: 'student' یا 'teacher'
  @Index()
  late String role;

  String? nationalCode;
  String? photoPath;
  DateTime membershipStart = DateTime.now();
  DateTime membershipEnd = DateTime.now().add(const Duration(days: 365));

  // کد QR داخلی
  String get qrCode => 'LIB-STU-$id';
}