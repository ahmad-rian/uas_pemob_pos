class Product {
  final int? id;
  final String name;
  final double price;
  final String? description;
  final int stock;

  Product({
    this.id,
    required this.name,
    required this.price,
    this.description,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'],
      price: json['price'] is String
          ? double.parse(json['price'])
          : json['price'].toDouble(),
      description: json['description'],
      stock: json['stock'] is String ? int.parse(json['stock']) : json['stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      'description': description,
      'stock': stock,
    };
  }
}
