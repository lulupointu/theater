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
  final List<Book> books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Theater(
        initialPageStack: BooksListPageStack(
          books: books,
          onFilterChanged: onFilterChanged,
          filter: null,
        ),
        translatorsBuilder: (_) => [
          PathTranslator<BooksListPageStack>.parse(
            path: '/',
            matchToPageStack: (match) => BooksListPageStack(
              books: books,
              onFilterChanged: onFilterChanged,
              filter: match.queryParams['filter'],
            ),
            pageStackToWebEntry: (route) => WebEntry(
              path: '/',
              queryParams: {if (route.filter != null) 'filter': route.filter!},
            ),
          ),
        ],
      ),
    );
  }

  void onFilterChanged(BuildContext context, String filter) {
    context.to(BooksListPageStack(
      books: books,
      onFilterChanged: onFilterChanged,
      filter: filter.isEmpty ? null : filter,
    ));
  }
}

class BooksListPageStack extends PageStack {
  final List<Book> books;
  final String? filter;
  final void Function(BuildContext context, String filter) onFilterChanged;

  BooksListPageStack({
    required this.books,
    required this.onFilterChanged,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return BooksListScreen(books: books, onFilterChanged: onFilterChanged, filter: filter);
  }
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;
  final String? filter;
  final void Function(BuildContext context, String filter) onFilterChanged;

  BooksListScreen({
    required this.books,
    required this.onFilterChanged,
    this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          TextField(
            controller: TextEditingController(text: filter),
            decoration: InputDecoration(
              hintText: 'filter',
            ),
            onSubmitted: (value) => onFilterChanged(context, value),
          ),
          for (var book in books)
            if (filter == null || book.title.toLowerCase().contains(filter!))
              ListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
              )
        ],
      ),
    );
  }
}
