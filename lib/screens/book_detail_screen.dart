import 'package:ebookstore_app/providers/auth_provider.dart';
import 'package:ebookstore_app/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:provider/provider.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isLoading = true;
  bool _isError = false;
  dynamic _bookDetails;
  dynamic _userDetails;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _fetchBookDetails();
  }

  Future<void> _fetchBookDetails() async {
    final String apiUrl = 'http://192.168.1.17:3000/books/${widget.bookId}';
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          _userDetails = user;
          _bookDetails = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }


  void _addToCart(BuildContext context) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final String apiUrl = 'http://192.168.1.17:3000/cart/add';
    try {
      final String requestBody = jsonEncode({
        'userId': user.id,
        'items': [
          {'bookId': widget.bookId, 'quantity': 1},
        ],
      });

      developer.log('log me 1', name: 'request body', error: requestBody);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode >= 200 || response.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Livre ajouté au panier ✅")),
        );
      } else {
        throw Exception('Erreur: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l’ajout au panier")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Détails du livre")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _isError
              ? const Center(child: Text("Erreur de chargement des détails"))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User: ${_userDetails.id ?? 'Inconnu'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      _bookDetails['title'] ?? 'Titre non disponible',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Auteur: ${_bookDetails['author'] ?? 'Inconnu'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _bookDetails['price'] != null
                          ? '${_bookDetails['price']}€'
                          : 'Prix non disponible',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _bookDetails['description'] ??
                          'Pas de description disponible.',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _addToCart(context),
                        child: const Text("Ajouter au panier"),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
