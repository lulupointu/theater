import 'package:flutter/widgets.dart';
import 'package:srouter/srouter.dart';

import 'advanced_books_srouter.dart';

class HomePageStack extends PageStack {
  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}

class BooksPageStack extends PageStack {
  final List<Book> books;
  final String? searchedGenre;
  final String? searchedName;
  final String title;

  BooksPageStack({
    required List<Book> books,
    this.searchedGenre = null,
    this.searchedName = null,
  })  : books = searchedGenre != null
            ? books.where((book) => book.genres.contains(searchedGenre)).toList()
            : searchedName != null
                ? books.where((book) => book.title.startsWith(searchedName)).toList()
                : books,
        title = searchedGenre != null
            ? "Books with genre '$searchedGenre'"
            : searchedName != null
                ? "Books with name '$searchedName'"
                : 'All Books';

  @override
  Widget build(BuildContext context) {
    return BooksScreen(books: books, title: title);
  }

  @override
  PageStackBase? get pageStackBellow {
    return HomePageStack();
  }
}

class BookDetailsPageStack extends PageStack {
  final List<Book> books;
  final Book book;
  final String title;

  BookDetailsPageStack({required this.books, required this.book}) : title = book.title;

  @override
  Widget build(BuildContext context) {
    return BookDetailsScreen(book: book, title: title);
  }

  @override
  PageStackBase? get pageStackBellow {
    return BooksPageStack(books: books);
  }
}

class BookBuyPageStack extends PageStack {
  final List<Book> books;
  final Book book;
  final String title;

  BookBuyPageStack({required this.books, required this.book}) : title = 'Buy ${book.title}';

  @override
  Widget build(BuildContext context) {
    return BookBuyScreen(book: book, title: title);
  }

  @override
  PageStackBase? get pageStackBellow {
    return BookDetailsPageStack(books: books, book: book);
  }
}

class BookGenresPageStack extends PageStack {
  final List<Book> books;
  final Book book;
  final String title;

  BookGenresPageStack({required this.books, required this.book})
      : title = '${book.title}\'s Genres';

  @override
  Widget build(BuildContext context) {
    return BookGenresScreen(book: book, title: title);
  }

  @override
  PageStackBase? get pageStackBellow {
    return BookDetailsPageStack(books: books, book: book);
  }
}
