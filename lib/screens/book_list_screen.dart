import 'package:ebookstore_app/providers/auth_provider.dart';
import 'package:ebookstore_app/providers/cart_provider.dart';
import 'package:ebookstore_app/screens/book_detail_screen.dart';
import 'package:ebookstore_app/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookListScreen extends StatefulWidget {
  const BookListScreen({Key? key}) : super(key: key);

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  List<dynamic> _books = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.17:3000/books'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _books = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Erreur de chargement');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _cartScreenInterface(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    // Si l'utilisateur essaye d'accéder au profil sans être connecté
    if (user == null) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Librairie'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: badges.Badge(
              badgeContent: Consumer<CartProvider>(
                builder:
                    (context, cart, _) => Text(
                      cart.cartCount.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
              ),
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () => _cartScreenInterface(context),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (_books.isEmpty) {
      return const Center(child: Text('Aucun livre trouvé.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        return BookCard(book: book);
      },
    );
  }
}

class BookCard extends StatelessWidget {
  final dynamic book;
  const BookCard({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToDetail(context),
        child: Row(
          children: [
            // Cover
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: book['coverUrl'] ?? 'https://via.placeholder.com/100',
                width: 100,
                height: 140,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      width: 100,
                      height: 140,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      width: 100,
                      height: 140,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.error)),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['title'] ?? 'Titre inconnu',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book['author'] ?? 'Auteur inconnu',
                      style: TextStyle(color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(book['price'] ?? 0).toDouble().toStringAsFixed(2)} €',
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _addToCart(context),
                      icon: const Icon(Icons.add_shopping_cart, size: 18),
                      label: const Text('Ajouter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        minimumSize: const Size(100, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(bookId: book['_id']),
      ),
    );
  }

  void _addToCart(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart(book['_id']);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${book['title']} ajouté au panier'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
