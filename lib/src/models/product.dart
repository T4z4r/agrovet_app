class Product {
  final int id;
  final String name;
  final String unit;
  int stock;
  final double costPrice;
  final double sellingPrice;

  Product(
      {required this.id,
      required this.name,
      required this.unit,
      required this.stock,
      required this.costPrice,
      required this.sellingPrice});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      stock: (json['stock'] ?? 0) is int
          ? json['stock']
          : int.parse(json['stock'].toString()),
      costPrice: (json['cost_price'] ?? 0).toDouble(),
      sellingPrice: (json['selling_price'] ?? 0).toDouble(),
    );
  }
}
