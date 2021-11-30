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
  final Author author;

  Book(this.title, this.author);
}

class Author {
  String name;

  Author(this.name);
}

class BooksApp extends StatelessWidget {
  final List<Book> books = [
    Book('Stranger in a Strange Land', Author('Robert A. Heinlein')),
    Book('Foundation', Author('Isaac Asimov')),
    Book('Fahrenheit 451', Author('Ray Bradbury')),
  ];

  List<Author> get authors => books.map<Author>((e) => e.author).toList();

  void toBooks(BuildContext context) {
    context.sRouter.to(BooksListSRoute(books: books, toBook: toBook));
  }

  void toBook(BuildContext context, Book book) {
    context.sRouter.to(
      BookDetailsSRoute(books: books, book: book, toBook: toBook, toAuthor: toAuthor),
    );
  }

  void toAuthors(BuildContext context) {
    context.sRouter.to(
      AuthorsListSRoute(authors: authors, toAuthor: toAuthor, toBooks: toBooks),
    );
  }

  void toAuthor(BuildContext context, Author author) {
    context.sRouter.to(
      AuthorDetailsSRoute(
          authors: authors, author: author, toBooks: toBooks, toAuthor: toAuthor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Books App',
      home: SRouter(
        initialRoute: BooksListSRoute(books: books, toBook: toBook),
        translatorsBuilder: (_) => [
          SPathTranslator<BooksListSRoute, SPushable>(
            path: '/',
            route: BooksListSRoute(books: books, toBook: toBook),
          ),
          SPathTranslator<BookDetailsSRoute, SPushable>.parse(
            path: '/book/:id',
            matchToRoute: (match) => BookDetailsSRoute(
              books: books,
              book: books[int.parse(match.pathParams['id']!)],
              toBook: toBook,
              toAuthor: toAuthor,
            ),
            routeToWebEntry: (route) =>
                WebEntry(path: '/book/${route.books.indexOf(route.book)}'),
          ),
          SPathTranslator<AuthorsListSRoute, SPushable>(
            path: '/authors',
            route: AuthorsListSRoute(authors: authors, toAuthor: toAuthor, toBooks: toBooks),
          ),
          SPathTranslator<AuthorDetailsSRoute, SPushable>.parse(
            path: '/author/:id',
            matchToRoute: (match) => AuthorDetailsSRoute(
              authors: authors,
              author: authors[int.parse(match.pathParams['id']!)],
              toAuthor: toAuthor,
              toBooks: toBooks,
            ),
            routeToWebEntry: (route) =>
                WebEntry(path: '/author/${authors.indexOf(route.author)}'),
          ),
          SRedirectorTranslator(path: '*', route: BooksListSRoute(books: books, toBook: toBook)),
        ],
      ),
    );
  }
}

class BooksListSRoute extends SRoute<SPushable> {
  final List<Book> books;
  final void Function(BuildContext context, Book book) toBook;

  BooksListSRoute({required this.books, required this.toBook});

  @override
  Widget build(BuildContext context) => BooksListScreen(books: books, toBook: toBook);
}

class BookDetailsSRoute extends SRoute<SPushable> {
  final List<Book> books;
  final Book book;
  final void Function(BuildContext context, Author author) toAuthor;
  final void Function(BuildContext context, Book book) toBook;

  const BookDetailsSRoute({
    required this.books,
    required this.book,
    required this.toBook,
    required this.toAuthor,
  });

  @override
  Widget build(BuildContext context) {
    return BookDetailsScreen(books: books, book: book, toAuthor: toAuthor);
  }

  @override
  SRouteInterface<SPushable> buildSRouteBellow(BuildContext context) {
    return BooksListSRoute(books: books, toBook: toBook);
  }
}

class AuthorsListSRoute extends SRoute<SPushable> {
  final List<Author> authors;
  final void Function(BuildContext context, Author author) toAuthor;
  final void Function(BuildContext context) toBooks;

  const AuthorsListSRoute({
    required this.authors,
    required this.toAuthor,
    required this.toBooks,
  });

  @override
  Widget build(BuildContext context) {
    return AuthorsListScreen(authors: authors, toAuthor: toAuthor, toBooks: toBooks);
  }
}

class AuthorDetailsSRoute extends SRoute<SPushable> {
  final List<Author> authors;
  final Author author;
  final void Function(BuildContext context, Author author) toAuthor;
  final void Function(BuildContext context) toBooks;

  const AuthorDetailsSRoute({
    required this.authors,
    required this.author,
    required this.toAuthor,
    required this.toBooks,
  });

  @override
  Widget build(BuildContext context) => AuthorDetailsScreen(author: author);

  @override
  SRouteInterface<SPushable> buildSRouteBellow(BuildContext _) {
    return AuthorsListSRoute(authors: authors, toAuthor: toAuthor, toBooks: toBooks);
  }
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;
  final void Function(BuildContext context, Book book) toBook;

  BooksListScreen({required this.books, required this.toBook});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          for (var book in books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author.name),
              onTap: () => toBook(context, book),
            )
        ],
      ),
    );
  }
}

class AuthorsListScreen extends StatelessWidget {
  final List<Author> authors;
  final void Function(BuildContext context, Author author) toAuthor;
  final void Function(BuildContext context) toBooks;

  AuthorsListScreen({
    required this.authors,
    required this.toAuthor,
    required this.toBooks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          ElevatedButton(
            onPressed: () => toBooks(context),
            child: Text('Go to Books Screen'),
          ),
          for (var author in authors)
            ListTile(
              title: Text(author.name),
              onTap: () => toAuthor(context, author),
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;
  final List<Book> books;
  final void Function(BuildContext context, Author author) toAuthor;

  BookDetailsScreen({required this.books, required this.book, required this.toAuthor});

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
            ElevatedButton(
              onPressed: () => toAuthor(context, book.author),
              child: Text(book.author.name),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthorDetailsScreen extends StatelessWidget {
  final Author author;

  AuthorDetailsScreen({required this.author});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(author.name, style: Theme.of(context).textTheme.headline6),
          ],
        ),
      ),
    );
  }
}
