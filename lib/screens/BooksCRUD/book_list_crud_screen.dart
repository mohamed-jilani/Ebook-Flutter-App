import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart'; // Importer pour le cache des images

import '../../models/book.dart';
import 'edit_book_crud_screen.dart'; // Ensure this file exists and contains the EditBookScreen class

class BookListCRUDScreen extends StatefulWidget {
  const BookListCRUDScreen({super.key});

  @override
  State<BookListCRUDScreen> createState() => _BookListCRUDScreenState();
}

class _BookListCRUDScreenState extends State<BookListCRUDScreen> {
  List<Book> _books = [];

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.17:3000/books'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _books = data.map((json) => Book.fromJson(json)).toList();
      });
    }
  }

  Future<void> deleteBook(String id) async {
    final response = await http.delete(
      Uri.parse('http://192.168.1.17:3000/books/$id'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _books.removeWhere((book) => book.id == id);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Livre supprimé')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur de suppression')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liste des Livres')),
      body:
          _books.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          8.0,
                        ), // Arrondir les coins
                        child: Material(
                          elevation: 4.0, // Ombre autour de l'image
                          borderRadius: BorderRadius.circular(8.0),
                          child: AspectRatio(
                            aspectRatio: 2 / 3,
                            child: CachedNetworkImage(
                              imageUrl:
                                  book.imageUrl ??
                                  'https://res.cloudinary.com/dpkomjjhj/image/upload/v1745603218/default_cover_prfhnu.png',
                              width: 60,
                              height: 120,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) =>
                                      CircularProgressIndicator(), // Indicateur pendant le chargement
                              errorWidget:
                                  (context, url, error) => Icon(
                                    Icons.error,
                                    size: 40,
                                  ), // Icône d'erreur si l'image ne se charge pas
                            ),
                          ),
                        ),
                      ),
                      title: Text(book.title),
                      subtitle: Text('${book.description}\n${book.price}€'),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditBookScreen(book: book),
                              ),
                            );
                          } else if (value == 'delete') {
                            deleteBook(book.id);
                          }
                        },
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Modifier'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Supprimer'),
                              ),
                            ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
