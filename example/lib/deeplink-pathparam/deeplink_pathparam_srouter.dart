// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:srouter/src/route/s_route_interface.dart';
import 'package:srouter/srouter.dart';

void main() {
  initializeSRouter();

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
      title: 'Books App',
      home: SRouter(
        initialRoute: BooksListScreenSRoute(books: _books),
        translatorsBuilder: (_) => [
          SPathTranslator<BooksListScreenSRoute, SPushable>(
            path: '/',
            route: BooksListScreenSRoute(books: _books),
          ),
          SPathTranslator<BookDetailsSRoute, SPushable>.parse(
            path: '/book/:id',
            matchToRoute: (match) => BookDetailsSRoute(
              books: _books,
              selectedBook: int.parse(match.pathParams['id']!),
            ),
            routeToWebEntry: (route) => WebEntry(path: '/book/${route.selectedBook}'),
          ),
          SRedirectorTranslator(path: '*', route: BooksListScreenSRoute(books: _books)),
        ],
      ),
    );
  }
}

class BooksListScreenSRoute extends SRoute<SPushable> {
  final List<Book> books;

  BooksListScreenSRoute({required this.books});

  @override
  Widget build(BuildContext context) => BooksListScreen(books: books);
}

class BookDetailsSRoute extends SRoute<SPushable> {
  final List<Book> books;
  final int selectedBook;

  BookDetailsSRoute({
    required this.books,
    required this.selectedBook,
  }) : super(key: ValueKey(selectedBook));

  @override
  Widget build(BuildContext context) => BookDetailsScreen(book: books[selectedBook]);

  @override
  SRouteInterface<SPushable> buildSRouteBellow(BuildContext context) =>
      BooksListScreenSRoute(books: books);
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
              onTap: () => context.sRouter.to(
                BookDetailsSRoute(books: books, selectedBook: books.indexOf(book)),
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
          ],
        ),
      ),
    );
  }
}
