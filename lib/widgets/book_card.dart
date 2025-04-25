import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final dynamic book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Image du livre (si disponible)
            book['imageUrl'] != null
                ? Image.network(
                    book['imageUrl'],
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : const SizedBox(width: 80, height: 120),
            
            const SizedBox(width: 16),
            // Détails du livre
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Auteur: ${book['author']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prix: ${book['price']}€',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
