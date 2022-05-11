// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:theater/theater.dart';

void main() {
  Theater.ensureInitialized();

  runApp(BooksApp());
}

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

class BooksApp extends StatelessWidget {
  final List<Book> _books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Theater(
        initialPageStack: BooksListScreenPageStack(books: _books),
        translatorsBuilder: (_) => [
          PathTranslator<BooksListScreenPageStack>(
            path: '/',
            pageStack: BooksListScreenPageStack(books: _books),
          ),
          PathTranslator<BookDetailsPageStack>.parse(
            path: '/book/:id',
            matchToPageStack: (match) => BookDetailsPageStack(
              books: _books,
              selectedBook: int.parse(match.pathParams['id']!),
            ),
            pageStackToWebEntry: (route) =>
                WebEntry(path: '/book/${route.selectedBook}'),
          ),
          RedirectorTranslator(
              path: '*', pageStack: BooksListScreenPageStack(books: _books)),
        ],
      ),
    );
  }
}

class BooksListScreenPageStack extends PageStack {
  final List<Book> books;

  BooksListScreenPageStack({required this.books});

  @override
  Widget build(BuildContext context) => BooksListScreen(books: books);
}

class BookDetailsPageStack extends PageStack {
  final List<Book> books;
  final int selectedBook;

  BookDetailsPageStack({
    required this.books,
    required this.selectedBook,
  });

  @override
  LocalKey? get key => ValueKey(selectedBook);

  @override
  Widget build(BuildContext context) =>
      BookDetailsScreen(book: books[selectedBook]);

  @override
  PageStackBase get pageStackBellow => BooksListScreenPageStack(books: books);
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;

  BooksListScreen({required this.books});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          for (var book in books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () => context.to(
                BookDetailsPageStack(
                    books: books, selectedBook: books.indexOf(book)),
              ),
            ),
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  BookDetailsScreen({required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title, style: Theme.of(context).textTheme.headline6),
            Text(book.author, style: Theme.of(context).textTheme.subtitle1),
            ElevatedButton(
              onPressed: () => showAboutDialog(context: context),
              child: Text('Click me'),
            ),
          ],
        ),
      ),
    );
  }
}
