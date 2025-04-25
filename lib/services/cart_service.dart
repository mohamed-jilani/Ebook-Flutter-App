import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';

class CartService {
  final String baseUrl = "http://192.168.1.17:3000"; // ou ton IP si besoin

  // Méthode pour ajouter un livre au panier
  Future<void> _addToCart(String bookId, String userId) async {
    final String apiUrl = baseUrl + '/cart'; // URL pour ajouter un livre au panier

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId, // Utilise ici l'ID de l'utilisateur
          'items': [
            {'bookId': bookId, 'quantity': 1}, // Ajouter un livre avec une quantité de 1
          ],
        }),
      );

      if (response.statusCode == 200) {
        // Si ajout réussi, appeler _fetchCart pour récupérer le panier mis à jour
        print("Livre ajouté au panier.");
      } else {
        // Gérer l'erreur si l'ajout échoue
        print("Erreur d'ajout au panier: ${response.body}");
      }
    } catch (e) {
      print("Erreur lors de la connexion: $e");
    }
  }

  // Méthode pour récupérer les éléments du panier
  Future<List<CartItem>> _fetchCart(String userId) async {
    final String apiUrl = baseUrl + '/cart/$userId'; // Récupérer les éléments du panier pour l'utilisateur

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Convertir la réponse JSON en liste de CartItem
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => CartItem.fromJson(item)).toList();
      } else {
        print("Erreur lors de la récupération du panier: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Erreur lors de la connexion: $e");
      return [];
    }
  }

  // Méthode pour modifier la quantité d'un livre dans le panier
  Future<void> _updateCartItem(String userId, String bookId, int newQuantity) async {
    final String apiUrl = baseUrl + '/cart/$userId/item/$bookId'; // URL pour modifier un item dans le panier

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'quantity': newQuantity, // Nouvelle quantité
        }),
      );

      if (response.statusCode == 200) {
        print("Quantité modifiée avec succès.");
      } else {
        print("Erreur lors de la modification de la quantité: ${response.body}");
      }
    } catch (e) {
      print("Erreur lors de la connexion: $e");
    }
  }

  // Méthode pour supprimer un livre du panier
  Future<void> _removeFromCart(String userId, String bookId) async {
    final String apiUrl = baseUrl + '/cart/$userId/item/$bookId'; // URL pour supprimer un livre du panier

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
      );

      if (response.statusCode == 200) {
        print("Livre supprimé du panier.");
      } else {
        print("Erreur lors de la suppression du livre: ${response.body}");
      }
    } catch (e) {
      print("Erreur lors de la connexion: $e");
    }
  }
}
