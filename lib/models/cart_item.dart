class CartItem {
  final String bookId;
  final String title;
  final String author;
  final double price;
  int quantity;

  CartItem({
    required this.bookId,
    required this.title,
    required this.author,
    required this.price,
    this.quantity = 1,
  });

  // Convertir l'objet CartItem en Map pour l'API
  Map<String, dynamic> toJson() {
    return {'bookId': bookId, 'quantity': quantity};
  }

  // Créer un CartItem à partir d'un Map (réponse de l'API)
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      bookId: json['bookId'],
      title: json['title'],
      author: json['author'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }
}
