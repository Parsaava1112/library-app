import 'package:isar/isar.dart';

part 'loan.g.dart';

@collection
class Loan {
  Id id = Isar.autoIncrement;

  late int bookId;
  late int studentId;
  DateTime loanDate = DateTime.now();
  late DateTime dueDate;
  DateTime? returnDate;
  bool isReturned = false;
  int renewCount = 0;
  double fineAmount = 0.0; // اختیاری

  // وضعیت نمایشی
  bool get isOverdue => !isReturned && DateTime.now().isAfter(dueDate);
}