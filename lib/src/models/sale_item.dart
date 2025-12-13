class SaleItem {
  final int productId;
  int quantity;
  final int price; // Changed from double to int as per API spec

  SaleItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json['product_id'],
      quantity: json['quantity'],
      price: (json['price'] ?? 0).round(),
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
        'price': price,
      };
}
