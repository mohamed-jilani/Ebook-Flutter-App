// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: const Color(0xFF004C99), // Bleu foncé
  colorScheme: ColorScheme.light(
    primary: const Color(0xFF004C99), // Bleu foncé
    secondary: const Color(0xFFFFD94A), // Jaune doux
    surface: Colors.white,
    background: const Color(0xFFF5F5F5),
  ),
  fontFamily: 'Poppins',
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.all(8),
  ),
);
