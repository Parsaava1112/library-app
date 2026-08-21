import 'package:isar/isar.dart';

part 'settings.g.dart';

@collection
class Settings {
  Id id = Isar.autoIncrement;

  // تنظیمات دانش‌آموز
  int studentLoanDays = 14;
  int studentMaxBooks = 2;
  int studentMaxRenews = 2;

  // تنظیمات معلم
  int teacherLoanDays = 30;
  int teacherMaxBooks = 5;
  int teacherMaxRenews = 3;

  // سایر تنظیمات عمومی
  double finePerDay = 0.0; // جریمه روزانه (اختیاری)
}