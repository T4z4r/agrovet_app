class Product {
  final int id;
  final String name;
  final String unit;
  final String? category;
  int stock;
  final int costPrice; // Changed from double to int as per API spec
  final int sellingPrice; // Changed from double to int as per API spec
  final String createdAt;
  final String updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.unit,
    this.category,
    required this.stock,
    required this.costPrice,
    required this.sellingPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      category: json['category'],
      stock: (json['stock'] ?? 0) is int
          ? json['stock']
          : int.parse(json['stock'].toString()),
      costPrice: (json['cost_price'] ?? 0).round(),
      sellingPrice: (json['selling_price'] ?? 0).round(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'category': category,
      'stock': stock,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
