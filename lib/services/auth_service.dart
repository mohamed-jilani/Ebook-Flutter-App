import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  final String baseUrl = 'http://192.168.1.17:3000';

  Future<User?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode >= 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['user']);
    } else {
      print('Erreur de connexion: ${response.body}');
      return null;
    }
  }
}
