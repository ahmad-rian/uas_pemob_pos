class TransactionItem {
  final int productId;
  final String name;
  final double price;
  final int quantity;

  TransactionItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'subtotal': total,
    };
  }

  TransactionItem copyWith({
    int? productId,
    String? name,
    double? price,
    int? quantity,
  }) {
    return TransactionItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      productId: json['product_id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'],
    );
  }
}
