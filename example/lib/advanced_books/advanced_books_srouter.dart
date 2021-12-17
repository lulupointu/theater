import 'package:flutter/material.dart';
import 'package:srouter/srouter.dart';

import 's_routes.dart';

void main() {
  initializeSRouter();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SRouter(
        initialPageStack: HomePageStack(),
        translatorsBuilder: (_) => [
          PathTranslator<HomePageStack, NonNestedStack>(
            path: '/',
            route: HomePageStack(),
            title: 'Home',
          ),
          PathTranslator<BooksPageStack, NonNestedStack>.parse(
            path: '/books',
            matchToRoute: (match) => BooksPageStack(
              books: books,
              searchedGenre: match.queryParams['genre'],
              searchedName: match.queryParams['name'],
            ),
            routeToWebEntry: (route) => WebEntry(
              pathSegments: ['books'],
              queryParams: {
                if (route.searchedGenre != null) 'genre': route.searchedGenre!,
                if (route.searchedName != null) 'name': route.searchedName!,
              },
              title: route.title,
            ),
          ),
          PathTranslator<BookDetailsPageStack, NonNestedStack>.parse(
            path: '/books/:bookId',
            matchToRoute: (match) => BookDetailsPageStack(
              books: books,
              book: books.firstWhere((element) => element.id == match.pathParams['bookId']),
            ),
            routeToWebEntry: (route) => WebEntry(
              pathSegments: ['books', route.book.id],
              title: route.title,
            ),
          ),
          PathTranslator<BookBuyPageStack, NonNestedStack>.parse(
            path: '/books/:bookId/buy',
            matchToRoute: (match) => BookBuyPageStack(
              books: books,
              book: books.firstWhere((element) => element.id == match.pathParams['bookId']),
            ),
            routeToWebEntry: (route) => WebEntry(
              pathSegments: ['books', route.book.id, 'buy'],
              title: route.title,
            ),
          ),
          PathTranslator<BookGenresPageStack, NonNestedStack>.parse(
            path: '/books/:bookId/genres',
            matchToRoute: (match) => BookGenresPageStack(
              books: books,
              book: books.firstWhere((element) => element.id == match.pathParams['bookId']),
            ),
            routeToWebEntry: (route) => WebEntry(
              pathSegments: ['books', route.book.id, 'genres'],
              title: route.title,
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
              onPressed: () => context.sRouter.to(BooksPageStack(books: books)),
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
                    onPressed: () => context.sRouter.to(
                      BooksPageStack(books: books, searchedGenre: booksQueryController.text),
                    ),
                  ),
                ),
                onSubmitted: (title) => context.sRouter.to(
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
                onTap: () => context.sRouter.to(BookDetailsPageStack(books: books, book: book)),
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
                  context.sRouter.to(BookGenresPageStack(books: books, book: book)),
              child: Text('See genres'),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => context.sRouter.to(BookBuyPageStack(books: books, book: book)),
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
                onTap: () => context.sRouter.to(
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