import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

typedef JsonMap = Map<String, dynamic>;

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
  final String id;
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

  factory Book.fromFirestore(DocumentSnapshot<JsonMap> doc) {
    final data = doc.data() ?? {};

    final rawCategories = data['categories'] as List<dynamic>? ?? [];
    final parsedCategories = rawCategories.map((e) {
      try {
        return BookCategory.values.byName(e.toString());
      } catch (_) {
        return BookCategory.novel;
      }
    }).toList();

    var hexColor = (data['coverColor']?.toString() ?? '')
        .replaceAll('#', '')
        .trim();
    if (hexColor.length != 6) {
      hexColor = '2E7D6F';
    }

    return Book(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      author: data['author']?.toString() ?? 'Неизвестный автор',
      year: data['year'] is int
          ? data['year'] as int
          : int.tryParse(data['year']?.toString() ?? '') ?? 2026,
      categories: parsedCategories,
      description: data['description']?.toString() ?? '',
      coverColor: Color(int.tryParse('FF$hexColor', radix: 16) ?? 0xFF2E7D6F),
    );
  }

  JsonMap toJson() {
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
      'categories': categories.map((c) => c.name).toList(),
      'description': description ?? '',
      'coverColor': hexColor,
    };
  }
}