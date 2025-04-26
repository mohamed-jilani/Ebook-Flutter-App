import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'BooksCRUD/book_list_crud_screen.dart';
import 'BooksCRUD/create_book_screen.dart';
import 'book_list_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final bool isAdmin = user?.role == 'admin';

    final List<Widget> screens = [
      const BookListScreen(),
      const OrdersScreen(),
      if (isAdmin) const CreateBookScreen(),
      if (isAdmin) const BookListCRUDScreen(),
      const ProfileScreen(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Livres'),
      const BottomNavigationBarItem(
        icon: Icon(Icons.receipt_long),
        label: 'Commandes',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Créer'),
      if (isAdmin)
        const BottomNavigationBarItem(icon: Icon(Icons.list), label: 'CRUD'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
    ];

    void onItemTapped(int index) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      // Si l'utilisateur essaye d'accéder au profil sans être connecté
      if ((navItems[index].label == 'Profil' ||
              navItems[index].label == 'Commandes') &&
          user == null) {
        Navigator.pushNamed(context, '/login');
        return;
      }

      setState(() => _selectedIndex = index);
    }

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 21, 51, 77),
        unselectedItemColor: const Color.fromARGB(
          255,
          4,
          10,
          15,
        ).withOpacity(0.5),
        items: navItems,
      ),
    );
  }
}
