class CartItem {
  final int id;
  final String title;
  final double price;
  final String thumbnail;
  int quantity;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'thumbnail': thumbnail,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        title: json['title'],
        price: (json['price'] as num).toDouble(),
        thumbnail: json['thumbnail'],
        quantity: json['quantity'],
      );
}