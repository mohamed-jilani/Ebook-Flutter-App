import 'package:ebookstore_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/book_card.dart'; // Assure-toi que le chemin est correct
import '../screens/book_detail_screen.dart'; // Import de la page de détail du livre
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import '../screens/cart_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

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
    const String apiUrl =
        'http://192.168.1.17:3000/books'; // Mets ton IP locale correcte

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _books = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Erreur lors du chargement des livres.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Impossible de se connecter à l’API.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des livres"),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              return badges.Badge(
                position: badges.BadgePosition.topEnd(top: 5, end: 5),
                badgeContent: Text(
                  cartProvider.cartCount.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),

      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
              : ListView.builder(
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return GestureDetector(
                    onTap: () {
                      // Lorsqu'un livre est tapé, naviguer vers la page de détails du livre
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BookDetailScreen(
                                bookId: book['_id'],
                              ), // Passer l'ID du livre
                        ),
                      );
                    },
                    child: BookCard(
                      book: book,
                    ), // Utilisation du widget BookCard stylisé
                  );
                },
              ),
    );
  }
}
