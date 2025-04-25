import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  double _totalPrice = 0.0;
  String userId = "USER_ID";  // Remplacez cette valeur par l'ID dynamique de l'utilisateur

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  // Fonction pour récupérer les livres du panier depuis l'API
  Future<void> _fetchCart() async {
    final String apiUrl = 'http://192.168.1.17:3000/cart/$userId'; // Remplacer par l'ID de l'utilisateur

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _cartItems = data.map((item) => CartItem.fromJson(item)).toList();
          _calculateTotalPrice();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Calculer le prix total du panier
  void _calculateTotalPrice() {
    _totalPrice = _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }

  // Supprimer un livre du panier
  Future<void> _removeFromCart(String bookId) async {
    final String apiUrl = 'http://192.168.1.17:3000/cart/$userId/item/$bookId'; // URL pour supprimer un livre du panier

    try {
      final response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          _cartItems.removeWhere((item) => item.bookId == bookId);
          _calculateTotalPrice();
        });
      } else {
        // Gérer les erreurs ici
        print("Erreur lors de la suppression de l'élément: ${response.body}");
      }
    } catch (e) {
      print("Erreur de connexion: $e");
    }
  }

  // Mettre à jour la quantité d'un livre dans le panier
  Future<void> _updateQuantity(String bookId, int newQuantity) async {
    final String apiUrl = 'http://192.168.1.17:3000/cart/$userId/item/$bookId'; // URL pour mettre à jour la quantité

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'quantity': newQuantity,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          final index = _cartItems.indexWhere((item) => item.bookId == bookId);
          if (index != -1) {
            _cartItems[index].quantity = newQuantity;
            _calculateTotalPrice();
          }
        });
      } else {
        print("Erreur lors de la mise à jour de la quantité: ${response.body}");
      }
    } catch (e) {
      print("Erreur de connexion: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Panier")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? const Center(child: Text("Votre panier est vide."))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return ListTile(
                            title: Text(item.title),
                            subtitle: Text(
                              "Auteur: ${item.author}\nPrix: ${item.price}€",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    if (item.quantity > 1) {
                                      _updateQuantity(item.bookId, item.quantity - 1);
                                    }
                                  },
                                ),
                                Text('Quantité: ${item.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    _updateQuantity(item.bookId, item.quantity + 1);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _removeFromCart(item.bookId);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Total: $_totalPrice€",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Logique pour passer à la commande (ajouter commande)
                      },
                      child: const Text("Passer la commande"),
                    ),
                  ],
                ),
    );
  }
}
