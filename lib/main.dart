import 'package:ebookstore_app/providers/cart_provider.dart';
import 'package:ebookstore_app/screens/cart_screen.dart';
import 'package:ebookstore_app/screens/BooksCRUD/create_book_screen.dart';
import 'package:ebookstore_app/screens/login_screen.dart';
import 'package:ebookstore_app/screens/main_screen.dart';
import 'package:ebookstore_app/screens/orders_screen.dart';
import 'package:ebookstore_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/book_list_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ebookstore_app',
      theme: ThemeData(primarySwatch: Colors.blue),
      //home: const BookListScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainScreen(),
        '/cart': (context) => const CartScreen(),
        '/Orders': (context) => const OrdersScreen(),
        '/Profile': (context) => const ProfileScreen(),
        '/CreateBook': (context) => CreateBookScreen(),
      },
      initialRoute: '/login',
    );
  }
}
