import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _orderCount = 0;
  double _totalSpent = 0.0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserStats();
  }

  Future<void> _fetchUserStats() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final String apiUrl = 'http://192.168.1.17:3000/orders/user/${user.id}';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode >= 200) {
        final List<dynamic> orders = jsonDecode(response.body);
        double total = 0.0;
        for (var order in orders) {
          total += (order['totalPrice'] ?? 0.0);
        }

        setState(() {
          _orderCount = orders.length;
          _totalSpent = total;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur lors du chargement des statistiques.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Impossible de se connecter à l’API.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text("Mon Profil")),
      body:
          user == null
              ? const Center(child: Text("Utilisateur non connecté"))
              : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 100,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Nom : ${user.name}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Email : ${user.email}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Rôle : ${user.role}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Divider(height: 30),
                    Text(
                      "Nombre de commandes : $_orderCount",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      "Total dépensé : ${_totalSpent.toStringAsFixed(2)} €",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          ).logout();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text("Se déconnecter"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
