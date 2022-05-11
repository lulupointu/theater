import 'package:flutter/material.dart';
import 'package:theater/theater.dart';

import 'page_stacks.dart';


void main() {
  Theater.ensureInitialized();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Theater(
        initialPageStack: HomePageStack(),
        translatorsBuilder: (_) => [
          PathTranslator<HomePageStack>(
            path: '/',
            pageStack: HomePageStack(),
            title: 'Home',
          ),
          PathTranslator<BooksPageStack>.parse(
            path: '/books',
            matchToPageStack: (match) => BooksPageStack(
              books: books,
              searchedGenre: match.queryParams['genre'],
              searchedName: match.queryParams['name'],
            ),
            pageStackToWebEntry: (pagestack) => WebEntry(
              pathSegments: ['books'],
              queryParams: {
                if (pagestack.searchedGenre != null) 'genre': pagestack.searchedGenre!,
                if (pagestack.searchedName != null) 'name': pagestack.searchedName!,
              },
              title: pagestack.title,
            ),
          ),
          PathTranslator<BookDetailsPageStack>.parse(
            path: '/books/:bookId',
            matchToPageStack: (match) => BookDetailsPageStack(
              books: books,
              book: books.firstWhere((element) => element.id == match.pathParams['bookId']),
            ),
            pageStackToWebEntry: (pagestack) => WebEntry(
              pathSegments: ['books', pagestack.book.id],
              title: pagestack.title,
            ),
          ),
          PathTranslator<BookBuyPageStack>.parse(
            path: '/books/:bookId/buy',
            matchToPageStack: (match) => BookBuyPageStack(
              books: books,
              book: books.firstWhere((element) => element.id == match.pathParams['bookId']),
            ),
            pageStackToWebEntry: (pagestack) => WebEntry(
              pathSegments: ['books', pagestack.book.id, 'buy'],
              title: pagestack.title,
            ),
          ),
          PathTranslator<BookGenresPageStack>.parse(
            path: '/books/:bookId/genres',
            matchToPageStack: (match) => BookGenresPageStack(
              books: books,
              book: books.firstWhere((element) => element.id == match.pathParams['bookId']),
            ),
            pageStackToWebEntry: (pagestack) => WebEntry(
              pathSegments: ['books', pagestack.book.id, 'genres'],
              title: pagestack.title,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final booksQueryController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.to(BooksPageStack(books: books)),
              child: Text('See all books'),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: 250,
              child: TextField(
                controller: booksQueryController,
                decoration: InputDecoration(
                  hintText: 'Search book by title...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => context.to(
                      BooksPageStack(books: books, searchedGenre: booksQueryController.text),
                    ),
                  ),
                ),
                onSubmitted: (title) => context.to(
                  BooksPageStack(books: books, searchedName: title),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BooksScreen extends StatelessWidget {
  BooksScreen({required this.books, required this.title});

  final List<Book> books;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        children: books
            .map(
              (book) => ListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
                onTap: () => context.to(BookDetailsPageStack(books: books, book: book)),
              ),
            )
            .toList(),
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  BookDetailsScreen({required this.book, required this.title});

  final Book book;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Author: ${book.author}'),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () =>
                  context.to(BookGenresPageStack(books: books, book: book)),
              child: Text('See genres'),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => context.to(BookBuyPageStack(books: books, book: book)),
              child: Text('Buy'),
            ),
          ],
        ),
      ),
    );
  }
}

class BookBuyScreen extends StatelessWidget {
  BookBuyScreen({required this.book, required this.title});

  final Book book;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          '${book.author}: ${book.title}\n\nBuying in progress...',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class BookGenresScreen extends StatelessWidget {
  BookGenresScreen({required this.book, required this.title});

  final Book book;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: ListView(
          children: List<Widget>.from(
            book.genres.map(
              (genre) => ListTile(
                onTap: () => context.to(
                  BooksPageStack(books: books, searchedGenre: genre),
                ),
                title: Text(genre),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final List<String> genres;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genres,
  });
}

const List<Book> books = [
  Book(
    id: '1',
    title: 'Stranger in a Strange Land',
    author: 'Robert A. Heinlein',
    genres: ['Science fiction'],
  ),
  Book(
    id: '2',
    title: 'Foundation',
    author: 'Isaac Asimov',
    genres: ['Science fiction', 'Political drama'],
  ),
  Book(
    id: '3',
    title: 'Fahrenheit 451',
    author: 'Ray Bradbury',
    genres: ['Dystopian'],
  ),
];