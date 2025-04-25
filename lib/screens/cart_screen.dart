import 'package:ebookstore_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/cart_item.dart';
import '../services/cart_service.dart';
import 'dart:developer' as developer;

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  double _totalPrice = 0.0;
  dynamic _userDetails;
  String userId =
      "USER_ID"; // Remplacez cette valeur par l'ID dynamique de l'utilisateur

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  // Fonction pour récupérer les livres du panier depuis l'API
  Future<void> _fetchCart() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final String apiUrl =
        'http://192.168.1.17:3000/cart/${user.id}/items'; // Remplacer par l'ID de l'utilisateur

    developer.log('log me 1', name: apiUrl);
    developer.log('log me 2', name: user.id);

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode >= 200) {
        final List<dynamic> data = jsonDecode(response.body);
        developer.log('log me 3', name: data.toString());
        setState(() {
          _userDetails = user;
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
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final String apiUrl =
        'http://192.168.1.17:3000/cart/${user.id}/item/$bookId'; // URL pour supprimer un livre du panier

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
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final String apiUrl =
        'http://192.168.1.17:3000/cart/${user.id}/item/$bookId'; // URL pour mettre à jour la quantité

    developer.log('log me 1', name: apiUrl);

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quantity': newQuantity}),
      );
      developer.log('log me 1', name: response.toString());

      if (response.statusCode >= 200) {
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

  Future<void> _placeOrder() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final String apiUrl = 'http://192.168.1.17:3000/orders/place';

    final Map<String, dynamic> orderData = {'userId': user.id};

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // ✅ Succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Commande passée avec succès!")),
        );

        setState(() {
          _cartItems = [];
          _totalPrice = 0.0;
        });
      } else {
        // ❌ Erreur API
        print("Erreur lors de la commande: ${response.body}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Échec de la commande")));
      }
    } catch (e) {
      // ❌ Erreur réseau
      print("Erreur de connexion: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erreur réseau")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Panier")),
      body:
          _isLoading
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
                                    _updateQuantity(
                                      item.bookId,
                                      item.quantity - 1,
                                    );
                                  }
                                },
                              ),
                              Text('Quantité: ${item.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  _updateQuantity(
                                    item.bookId,
                                    item.quantity + 1,
                                  );
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
                      "Total: ${_totalPrice.toStringAsFixed(2)}DT",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _placeOrder,
                    child: const Text("Passer la commande"),
                  ),
                ],
              ),
    );
  }
}
