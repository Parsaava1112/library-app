import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/book.dart';
import '../models/student.dart';
import '../models/loan.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  Isar? _isar;

  Future<Isar> get isar async {
    if (_isar != null && _isar!.isOpen) return _isar!;
    final dir = await getApplicationSupportDirectory();
    _isar = await Isar.open(
      [BookSchema, StudentSchema, LoanSchema],
      directory: dir.path,
    );
    return _isar!;
  }

  // ---------- Book methods ----------
  Future<List<Book>> getAllBooks() async {
    final db = await isar;
    return db.books.where().findAll();
  }

  Future<Book?> getBookById(int id) async {
    final db = await isar;
    return db.books.get(id);
  }

  Future<void> addBook(Book book) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.books.put(book);
    });
  }

  Future<void> updateBook(Book book) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.books.put(book);
    });
  }

  Future<void> deleteBook(int id) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.books.delete(id);
    });
  }

  // ---------- Student methods ----------
  Future<List<Student>> getAllStudents() async {
    final db = await isar;
    return db.students.where().findAll();
  }

  Future<Student?> getStudentById(int id) async {
    final db = await isar;
    return db.students.get(id);
  }

  Future<void> addStudent(Student student) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.students.put(student);
    });
  }

  Future<void> updateStudent(Student student) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.students.put(student);
    });
  }

  Future<void> deleteStudent(int id) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.students.delete(id);
    });
  }

  // ---------- Loan methods ----------
  Future<List<Loan>> getActiveLoans() async {
    final db = await isar;
    return db.loans.filter().isReturnedEqualTo(false).findAll();
  }

  Future<List<Loan>> getLoansByStudent(int studentId) async {
    final db = await isar;
    return db.loans.filter().studentIdEqualTo(studentId).findAll();
  }

  Future<List<Loan>> getLoansByBook(int bookId) async {
    final db = await isar;
    return db.loans.filter().bookIdEqualTo(bookId).findAll();
  }

  Future<void> addLoan(Loan loan) async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.loans.put(loan);
      // کاهش موجودی کتاب
      final book = await db.books.get(loan.bookId);
      if (book != null && book.availableCopies > 0) {
        book.availableCopies--;
        await db.books.put(book);
      }
    });
  }

  Future<void> returnLoan(Loan loan) async {
    final db = await isar;
    await db.writeTxn(() async {
      loan.isReturned = true;
      loan.returnDate = DateTime.now();
      await db.loans.put(loan);
      // افزایش موجودی کتاب
      final book = await db.books.get(loan.bookId);
      if (book != null) {
        book.availableCopies++;
        await db.books.put(book);
      }
    });
  }

  Future<void> renewLoan(Loan loan, int maxRenew) async {
    if (loan.renewCount >= maxRenew) return;
    final db = await isar;
    await db.writeTxn(() async {
      loan.renewCount++;
      loan.dueDate = loan.dueDate.add(Duration(days: 14)); // یا مقدار تنظیم‌شده
      await db.loans.put(loan);
    });
  }
}

// در DatabaseService اضافه کنید:

Future<Settings> getSettings() async {
  final db = await isar;
  final settingsList = await db.settings.where().findAll();
  if (settingsList.isNotEmpty) {
    return settingsList.first;
  } else {
    final defaultSettings = Settings();
    await db.writeTxn(() async {
      await db.settings.put(defaultSettings);
    });
    return defaultSettings;
  }
}

Future<void> updateSettings(Settings settings) async {
  final db = await isar;
  await db.writeTxn(() async {
    await db.settings.put(settings);
  });
}