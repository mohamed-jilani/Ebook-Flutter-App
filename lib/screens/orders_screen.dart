import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final String apiUrl = 'http://192.168.1.17:3000/orders/user/${user.id}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _orders = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Erreur lors du chargement des commandes.";
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
      appBar: AppBar(title: const Text("Mes commandes")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
              : ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ExpansionTile(
                      title: Text("Commande #${order['_id']}"),
                      subtitle: Text(
                        "Total: ${order['totalPrice'].toStringAsFixed(2)}€ - Status: ${order['status']}",
                      ),
                      children: List<Widget>.from(
                        order['items'].map<Widget>((item) {
                          final book = item['bookId'];
                          return ListTile(
                            leading: Image.network(
                              book['coverUrl'],
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(book['title']),
                            subtitle: Text("Auteur: ${book['author']}"),
                            trailing: Text("x${item['quantity']}"),
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
