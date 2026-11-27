import 'package:flutter/material.dart';
import '/domain/entities/book.dart';
import '/ui/widgets/book_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final Set<int> _likedIds = {};
  bool _showOnlyFavorites = false;

  void _toggleLike(int id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredBooks = _showOnlyFavorites
        ? books.where((book) => _likedIds.contains(book.id)).toList()
        : books;

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Каталог книг',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${books.length} книг в каталоге · В избранном: ${_likedIds.length}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showOnlyFavorites = !_showOnlyFavorites;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _showOnlyFavorites
                            ? Color(0xFFE8F4F0)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 16,
                            color: _showOnlyFavorites
                                ? Color(0xFFE53935)
                                : Colors.grey,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Только избранные',
                            style: TextStyle(
                              fontSize: 14,
                              color: _showOnlyFavorites
                                  ? Color(0xFF2E7D6F)
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredBooks.isEmpty
                  ? Center(
                      child: Text(
                        'Ничего не нашлось',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        final book = filteredBooks[index];
                        return BookCard(
                          book: book,
                          isLiked: _likedIds.contains(book.id),
                          onLikeTap: () => _toggleLike(book.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

final List<Book> books = [
  Book(
    id: 1,
    title: 'Мастер и Маргарита',
    author: 'М. Булгаков',
    year: 1940,
    categories: [BookCategory.novel, BookCategory.mystic],
    coverColor: Colors.blue,
  ),
  Book(
    id: 2,
    title: 'Преступление и наказание',
    author: 'Ф. Достоевский',
    year: 1866,
    categories: [BookCategory.classic, BookCategory.drama],
    coverColor: Colors.orange,
  ),
  Book(
    id: 3,
    title: 'Мертвые Души',
    author: 'Н. Гоголь',
    year: 1835,
    categories: [BookCategory.poem],
    coverColor: Colors.black,
  ),
  Book(
    id: 4,
    title: 'Война и мир',
    author: 'Л. Толстой',
    year: 1869,
    categories: [BookCategory.epic],
    coverColor: Colors.green,
  ),
  Book(
    id: 5,
    title: 'Герой нашего времени',
    author: 'М. Лермонтов',
    year: 1840,
    categories: [BookCategory.novel],
    coverColor: Colors.purple,
  ),
  Book(
    id: 6,
    title: 'Отцы и дети',
    author: 'И. Тургенев',
    year: 1862,
    categories: [BookCategory.novel],
    coverColor: Colors.red,
  ),
  Book(
    id: 7,
    title: 'Идиот',
    author: 'Ф. Достоевский',
    year: 1869,
    categories: [BookCategory.novel],
    coverColor: Colors.teal,
  ),
  Book(
    id: 8,
    title: 'Тихий Дон',
    author: 'М. Шолохов',
    year: 1940,
    categories: [BookCategory.epic],
    coverColor: Colors.brown,
  ),
];




