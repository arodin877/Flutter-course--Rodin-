import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/book.dart';
import '../widgets/book_card.dart';

const String baseUrl = 'https://6b059059db01cf463608b81e.mockapi.io';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final Set<int> _likedIds = {};
  final TextEditingController _titleController = TextEditingController();

  List<Book> _books = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _showOnlyFavorites = false;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/books'));
      if (response.statusCode != 200) {
        throw Exception('Ошибка загрузки: статус ${response.statusCode}');
      }
      final list = jsonDecode(response.body) as List;
      final loadedBooks = list
          .map((e) => Book.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _books = loadedBooks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Не удалось загрузить каталог: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addBook() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final newBook = Book(
      id: 0, // не отправляется в toJson(), сервер присвоит свой id
      title: title,
      author: 'Неизвестный автор',
      year: 2026,
      categories: [BookCategory.novel],
      description: '',
      coverColor: const Color(0xFF2E7D6F),
    );

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/books'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(newBook.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Ошибка создания: статус ${response.statusCode}');
      }

      final created = Book.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );

      setState(() {
        _books.insert(0, created);
        _titleController.clear();
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось добавить книгу: $e')),
      );
    }
  }

  void _toggleLike(int id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  Widget _buildAddForm() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Название новой книги',
                isDense: true,
                border: OutlineInputBorder(),
                fillColor: Colors.white,
                filled: true,
              ),
              onSubmitted: (_) => _addBook(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _addBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D6F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Отправить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBooks = _showOnlyFavorites
        ? _books.where((book) => _likedIds.contains(book.id)).toList()
        : _books;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Каталог книг',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showForm = !_showForm;
                          });
                        },
                        icon: Icon(_showForm ? Icons.close : Icons.add),
                        tooltip: _showForm ? 'Скрыть форму' : 'Добавить книгу',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_books.length} книг · В избранном: ${_likedIds.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showOnlyFavorites = !_showOnlyFavorites;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _showOnlyFavorites
                            ? const Color(0xFFE8F4F0)
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
                                ? const Color(0xFFE53935)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Только избранные',
                            style: TextStyle(
                              fontSize: 14,
                              color: _showOnlyFavorites
                                  ? const Color(0xFF2E7D6F)
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showForm) _buildAddForm(),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: _fetchBooks,
                                  child: const Text('Обновить'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : filteredBooks.isEmpty
                          ? const Center(
                              child: Text(
                                'Ничего не нашлось',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
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