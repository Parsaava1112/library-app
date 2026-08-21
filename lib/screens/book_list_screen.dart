import 'package:flutter/material.dart';
import '../db/database_service.dart';
import '../models/book.dart';

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لیست کتاب‌ها')),
      body: FutureBuilder<List<Book>>(
        future: DatabaseService.instance.getAllBooks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final books = snapshot.data!;
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                title: Text(book.title),
                subtitle: Text('${book.author} | موجودی: ${book.availableCopies}/${book.totalCopies}'),
                trailing: Text(book.qrCode),
              );
            },
          );
        },
      ),
    );
  }
}