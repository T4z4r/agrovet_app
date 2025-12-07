import 'sale_item.dart';

class Sale {
  final int id;
  final int sellerId;
  final String saleDate;
  final List<SaleItem> items;

  Sale({
    required this.id,
    required this.sellerId,
    required this.saleDate,
    required this.items,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      sellerId: json['seller_id'],
      saleDate: json['sale_date'] ?? '',
      items:
          (json['items'] as List?)?.map((e) => SaleItem.fromJson(e)).toList() ??
              [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'sale_date': saleDate,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
