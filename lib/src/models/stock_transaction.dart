class StockTransaction {
  final int id;
  final int productId;
  final String type;
  final int quantity;
  final int? supplierId;
  final String date;
  final String remarks;

  StockTransaction({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    this.supplierId,
    required this.date,
    required this.remarks,
  });

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id'],
      productId: json['product_id'],
      type: json['type'] ?? '',
      quantity: json['quantity'] ?? 0,
      supplierId: json['supplier_id'],
      date: json['date'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'type': type,
      'quantity': quantity,
      'supplier_id': supplierId,
      'date': date,
      'remarks': remarks,
    };
  }
}
