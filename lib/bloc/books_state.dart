import '/domain/entities/book.dart';

sealed class BooksState {}

class BooksLoadInProgress extends BooksState {}

class BooksLoadSuccess extends BooksState {
  final List<Book> books;
  BooksLoadSuccess(this.books);
}

class BooksLoadFailure extends BooksState {
  final String message;
  BooksLoadFailure(this.message);
}