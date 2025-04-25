import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _fetchBookDetails();
  }

  // Fonction pour récupérer les détails du livre depuis l'API
  Future<void> _fetchBookDetails() async {
    final String apiUrl = 'http://192.168.1.17:3000/books/${widget.bookId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          _bookDetails = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
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
                      _bookDetails['title'] ??
                          'Titre non disponible', // Fournir un texte de remplacement si le titre est nul
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Auteur: ${_bookDetails['author']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    // Exemple similaire pour l'auteur et la description
                    Text(
                      _bookDetails['author'] ?? 'Auteur non disponible',
                      style: const TextStyle(fontSize: 18),
                    ),

                    Text(
                      _bookDetails['price'] != null
                          ? '${_bookDetails['price']}€'
                          : 'Prix non disponible',
                      style: const TextStyle(fontSize: 18),
                    ),

                    Text(
                      _bookDetails['description'] ??
                          'Description non disponible.',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _bookDetails['description'] ??
                          'Pas de description disponible.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
    );
  }
}
