import 'package:flutter/material.dart';

enum BookCategory {
  novel('Роман'),
  mystic('Мистика'),
  classic('Классика'),
  drama('Драма'),
  poem('Поэма'),
  epic('Роман-эпопея');

  final String label;
  const BookCategory(this.label);
}

class Book {
  final int id;
  final String title;
  final String author;
  final int year;
  final List<BookCategory> categories;
  final String? description;
  final Color coverColor;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.year,
    required this.categories,
    this.description,
    required this.coverColor,
  });
}