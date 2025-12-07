class SaleItem {
  final int productId;
  int quantity;
  final double price;

  SaleItem(
      {required this.productId, required this.quantity, required this.price});

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json['product_id'],
      quantity: json['quantity'],
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
        'price': price,
      };
}
