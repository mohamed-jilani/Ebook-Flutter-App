import 'package:flutter/material.dart';
import 'book_list_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'create_book_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const BookListScreen(),
    const OrdersScreen(),
    const CreateBookScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    'Livres',
    'Commandes',
    'Créer un livre',
    'Profil',
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Livres'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Créer'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
