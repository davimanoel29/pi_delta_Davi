class CartItem {
  final int id;
  final int userId;
  final DateTime date;
 // final int quantity;
  //final double price;

  CartItem({
    required this.id,
    required this.userId,
    required this.date,
   // required this.quantity,
    //required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      userId: json['UserId'],
      date: json['Date'],
      //quantity: json['quantity'],
     // price: json['price'].toDouble(),
    );
  }
}