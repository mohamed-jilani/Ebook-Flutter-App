class Book {
  final String id;
  final String title;
  final String author;
  final double price;
  final String? description;
  final String? categoryId;
  final String? category; // Added category field
  final String? imageUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    this.description,
    this.categoryId,
    this.category,
    required this.imageUrl,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'],
      title: json['title'],
      author: json['author'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      categoryId: json['categoryId'],
      category: json['category'].toString(),
      imageUrl: json['coverUrl'],
    );
  }
}
