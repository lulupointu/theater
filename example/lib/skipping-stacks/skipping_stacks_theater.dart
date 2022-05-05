// Copyright 2021, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:theater/theater.dart';

void main() {
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
    context.theater.to(BooksListPageStack(books: books, toBook: toBook));
  }

  void toBook(BuildContext context, Book book) {
    context.theater.to(
      BookDetailsPageStack(books: books, book: book, toBook: toBook, toAuthor: toAuthor),
    );
  }

  void toAuthors(BuildContext context) {
    context.theater.to(
      AuthorsListPageStack(authors: authors, toAuthor: toAuthor, toBooks: toBooks),
    );
  }

  void toAuthor(BuildContext context, Author author) {
    context.theater.to(
      AuthorDetailsPageStack(
          authors: authors, author: author, toBooks: toBooks, toAuthor: toAuthor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: Theater.build(
        initialPageStack: BooksListPageStack(books: books, toBook: toBook),
        translatorsBuilder: (_) => [
          PathTranslator<BooksListPageStack>(
            path: '/',
            pageStack: BooksListPageStack(books: books, toBook: toBook),
          ),
          PathTranslator<BookDetailsPageStack>.parse(
            path: '/book/:id',
            matchToPageStack: (match) => BookDetailsPageStack(
              books: books,
              book: books[int.parse(match.pathParams['id']!)],
              toBook: toBook,
              toAuthor: toAuthor,
            ),
            pageStackToWebEntry: (route) =>
                WebEntry(path: '/book/${route.books.indexOf(route.book)}'),
          ),
          PathTranslator<AuthorsListPageStack>(
            path: '/authors',
            pageStack:
                AuthorsListPageStack(authors: authors, toAuthor: toAuthor, toBooks: toBooks),
          ),
          PathTranslator<AuthorDetailsPageStack>.parse(
            path: '/author/:id',
            matchToPageStack: (match) => AuthorDetailsPageStack(
              authors: authors,
              author: authors[int.parse(match.pathParams['id']!)],
              toAuthor: toAuthor,
              toBooks: toBooks,
            ),
            pageStackToWebEntry: (route) =>
                WebEntry(path: '/author/${authors.indexOf(route.author)}'),
          ),
          RedirectorTranslator(
            path: '*',
            pageStack: BooksListPageStack(books: books, toBook: toBook),
          ),
        ],
      ),
    );
  }
}

class BooksListPageStack extends PageStack {
  final List<Book> books;
  final void Function(BuildContext context, Book book) toBook;

  BooksListPageStack({required this.books, required this.toBook});

  @override
  Widget build(BuildContext context) => BooksListScreen(books: books, toBook: toBook);
}

class BookDetailsPageStack extends PageStack {
  final List<Book> books;
  final Book book;
  final void Function(BuildContext context, Author author) toAuthor;
  final void Function(BuildContext context, Book book) toBook;

  const BookDetailsPageStack({
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
  PageStackBase get pageStackBellow {
    return BooksListPageStack(books: books, toBook: toBook);
  }
}

class AuthorsListPageStack extends PageStack {
  final List<Author> authors;
  final void Function(BuildContext context, Author author) toAuthor;
  final void Function(BuildContext context) toBooks;

  const AuthorsListPageStack({
    required this.authors,
    required this.toAuthor,
    required this.toBooks,
  });

  @override
  Widget build(BuildContext context) {
    return AuthorsListScreen(authors: authors, toAuthor: toAuthor, toBooks: toBooks);
  }
}

class AuthorDetailsPageStack extends PageStack {
  final List<Author> authors;
  final Author author;
  final void Function(BuildContext context, Author author) toAuthor;
  final void Function(BuildContext context) toBooks;

  const AuthorDetailsPageStack({
    required this.authors,
    required this.author,
    required this.toAuthor,
    required this.toBooks,
  });

  @override
  Widget build(BuildContext context) => AuthorDetailsScreen(author: author);

  @override
  PageStackBase createPageStackBellow(BuildContext _) {
    return AuthorsListPageStack(authors: authors, toAuthor: toAuthor, toBooks: toBooks);
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
