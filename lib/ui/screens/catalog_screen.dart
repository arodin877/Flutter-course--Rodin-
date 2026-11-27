import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/bloc/books_bloc.dart';
import 'package:flutter_application_1/bloc/books_event.dart';
import 'package:flutter_application_1/bloc/books_state.dart';
import 'package:flutter_application_1/domain/entities/book.dart';
import 'package:flutter_application_1/ui/widgets/book_card.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final Set<String> _likedIds = {};
  bool _showOnlyFavorites = false;

  bool _showForm = false;
  bool _isSubmitting = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  BookCategory _selectedCategory = BookCategory.novel;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _addBook() async {
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final newBook = Book(
        id: '',
        title: title,
        author: author.isNotEmpty ? author : 'Неизвестный автор',
        year: 2026,
        categories: [_selectedCategory],
        description: '',
        coverColor: const Color(0xFF2E7D6F),
      );

      await FirebaseFirestore.instance
          .collection('books')
          .add(newBook.toJson());

      _titleController.clear();
      _authorController.clear();
      if (mounted) {
        setState(() {
          _selectedCategory = BookCategory.novel;
          _showForm = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось добавить книгу: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _toggleLike(String id) {
    setState(() {
      if (_likedIds.contains(id)) {
        _likedIds.remove(id);
      } else {
        _likedIds.add(id);
      }
    });
  }

  Widget _buildAddForm() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              hintText: 'Название книги...',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _authorController,
                  enabled: !_isSubmitting,
                  decoration: InputDecoration(
                    hintText: 'Автор...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<BookCategory>(
                  value: _selectedCategory,
                  isExpanded: true,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: BookCategory.values.map((category) {
                    return DropdownMenuItem<BookCategory>(
                      value: category,
                      child: Text(
                        category.label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _addBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D6F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                : const Text('Добавить книгу'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, BooksState state) {
    if (state is BooksLoadInProgress) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D6F)),
      );
    }

    if (state is BooksLoadFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<BooksBloc>().add(BooksLoadRequested());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D6F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Обновить'),
              ),
            ],
          ),
        ),
      );
    }

    final allBooks = (state as BooksLoadSuccess).books;
    final filteredBooks = _showOnlyFavorites
        ? allBooks.where((book) => _likedIds.contains(book.id)).toList()
        : allBooks;

    if (filteredBooks.isEmpty) {
      return const Center(
        child: Text(
          'Ничего не нашлось',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: BlocBuilder<BooksBloc, BooksState>(
          builder: (context, state) {
            final totalCount =
                state is BooksLoadSuccess ? state.books.length : 0;

            return Column(
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
                        children: [
                          const Expanded(
                            child: Text(
                              'Каталог книг',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _showForm = !_showForm;
                              });
                            },
                            icon: Icon(
                              _showForm ? Icons.close : Icons.add,
                              color: const Color(0xFF2E7D6F),
                            ),
                            tooltip: 'Добавить книгу',
                          ),
                          IconButton(
                            onPressed: () => FirebaseAuth.instance.signOut(),
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.grey,
                            ),
                            tooltip: 'Выйти',
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalCount книг в каталоге · В избранном: ${_likedIds.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (_showForm) _buildAddForm(),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showOnlyFavorites = !_showOnlyFavorites;
                          });
                        },
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
                    ],
                  ),
                ),
                Expanded(
                  child: _buildBody(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}