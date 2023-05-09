class CartItem {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }
}