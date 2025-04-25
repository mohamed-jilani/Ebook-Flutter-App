import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  int _cartCount = 0;

  int get cartCount => _cartCount;

  void setCartCount(int count) {
    _cartCount = count;
    notifyListeners();
  }

  void increment() {
    _cartCount++;
    notifyListeners();
  }
  
}
