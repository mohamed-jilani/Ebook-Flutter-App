import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  final String baseUrl = "http://192.168.1.17:3000"; // ou ton IP si besoin

  Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/books'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((bookJson) => Book.fromJson(bookJson)).toList();
    } else {
      throw Exception("Erreur lors du chargement des livres");
    }
  }
}
