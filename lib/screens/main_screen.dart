import 'package:ebookstore_app/screens/BooksCRUD/book_list_crud_screen.dart';
import 'package:flutter/material.dart';
import 'book_list_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'BooksCRUD/create_book_screen.dart';

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
    const BookListCRUDScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    'Livres',
    'Commandes',
    'Créer un livre',
    'Liste des livres',
    'Profil',
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 21, 51, 77),
        unselectedItemColor: const Color.fromARGB(
          255,
          4,
          10,
          15,
        ).withOpacity(0.5),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Livres'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'CRUD'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Créer'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
