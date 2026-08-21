import 'package:isar/isar.dart';

part 'book.g.dart';

@collection
class Book {
  Id id = Isar.autoIncrement; // شناسه داخلی خودکار

  late String title;
  late String author;
  String? publisher;
  int? year;
  String? category;
  String? shelfLocation;
  int totalCopies = 1;
  int availableCopies = 1;
  String? note;

  // کد QR داخلی
  String get qrCode => 'LIB-BOOK-$id';
}