import 'package:flutter/widgets.dart';
import 'package:srouter/srouter.dart';

import 'advanced_books_srouter.dart';

class HomeSRoute extends SRoute<NotSNested> {
  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}

class BooksSRoute extends SRoute<NotSNested> {
  final List<Book> books;
  final String? searchedGenre;
  final String? searchedName;
  final String title;

  BooksSRoute({
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
  SRouteBase<NotSNested>? createSRouteBellow(BuildContext context) {
    return HomeSRoute();
  }
}

class BookDetailsSRoute extends SRoute<NotSNested> {
  final List<Book> books;
  final Book book;
  final String title;

  BookDetailsSRoute({required this.books, required this.book}) : title = book.title;

  @override
  Widget build(BuildContext context) {
    return BookDetailsScreen(book: book, title: title);
  }

  @override
  SRouteBase<NotSNested>? createSRouteBellow(BuildContext context) {
    return BooksSRoute(books: books);
  }
}

class BookBuySRoute extends SRoute<NotSNested> {
  final List<Book> books;
  final Book book;
  final String title;

  BookBuySRoute({required this.books, required this.book}) : title = 'Buy ${book.title}';

  @override
  Widget build(BuildContext context) {
    return BookBuyScreen(book: book, title: title);
  }

  @override
  SRouteBase<NotSNested>? createSRouteBellow(BuildContext context) {
    return BookDetailsSRoute(books: books, book: book);
  }
}

class BookGenresSRoute extends SRoute<NotSNested> {
  final List<Book> books;
  final Book book;
  final String title;

  BookGenresSRoute({required this.books, required this.book})
      : title = '${book.title}\'s Genres';

  @override
  Widget build(BuildContext context) {
    return BookGenresScreen(book: book, title: title);
  }

  @override
  SRouteBase<NotSNested>? createSRouteBellow(BuildContext context) {
    return BookDetailsSRoute(books: books, book: book);
  }
}
