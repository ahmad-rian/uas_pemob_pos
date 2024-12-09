import 'package:pos/models/transactionitem_model.dart';

class Transaction {
  final int id;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final List<TransactionItem>? items;

  Transaction({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.items,
  });

  int get itemsCount {
    if (items == null || items!.isEmpty) return 0;
    return items!.fold(0, (sum, item) => sum + (item.quantity ?? 0));
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      totalAmount: json['total_amount'] is String
          ? double.tryParse(json['total_amount'].toString()) ?? 0.0
          : (json['total_amount'] as num).toDouble(),
      status: json['status'] ?? 'completed',
      createdAt: DateTime.parse(json['created_at'] as String),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => TransactionItem.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total_amount': totalAmount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      if (items != null) 'items': items!.map((item) => item.toJson()).toList(),
    };
  }
}
