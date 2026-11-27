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

  factory Book.fromJson(Map<String, dynamic> json) {
    final hexColor = (json['coverColor'] ?? '2E7D6F')
        .toString()
        .replaceAll('#', '');

    final rawList = (json['categories'] as List?) ??
        (json['category'] != null ? [json['category']] : []);
    final parsedCategories = rawList
        .map(
          (item) => BookCategory.values.firstWhere(
            (e) => e.name == item.toString(),
            orElse: () => BookCategory.novel,
          ),
        )
        .toList();

    return Book(
      id: int.parse(json['id'].toString()),
      title: (json['title'] ?? '').toString(),
      author: (json['author'] ?? '').toString(),
      year: int.tryParse(json['year'].toString()) ?? 2026,
      categories: parsedCategories.isEmpty
          ? [BookCategory.novel]
          : parsedCategories,
      description: json['description']?.toString(),
      coverColor: Color(int.tryParse('FF$hexColor', radix: 16) ?? 0xFF2E7D6F),
    );
  }

  Map<String, dynamic> toJson() {
    final hexColor = coverColor
        .toARGB32()
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2)
        .toUpperCase();

    return {
      'title': title,
      'author': author,
      'year': year,
      'categories': categories.map((e) => e.name).toList(),
      'description': description ?? '',
      'coverColor': hexColor,
    };
  }
}