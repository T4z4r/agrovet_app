class SaleItem {
  final int productId;
  int quantity;
  final double price;

  SaleItem(
      {required this.productId, required this.quantity, required this.price});

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
        'price': price,
      };
}
