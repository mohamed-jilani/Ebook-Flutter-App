class CartItem {
  final String id;
  final String bookId;
  final String title;
  final String author;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.bookId,
    required this.title,
    required this.author,
    required this.price,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final book = json['bookId'];
    return CartItem(
      id: json['_id'],
      bookId: book['_id'],
      title: book['title'],
      author: book['author'],
      price: (book['price'] as num).toDouble(),
      quantity: json['quantity'],
    );
  }
}
