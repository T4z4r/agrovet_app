import 'package:flutter/material.dart';
import '../models/sale_item.dart';

class CartProvider extends ChangeNotifier {
  final List<SaleItem> items = [];

  void addItem(SaleItem item) {
    final idx = items.indexWhere((i) => i.productId == item.productId);
    if (idx >= 0) {
      items[idx].quantity += item.quantity;
    } else {
      items.add(item);
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    items.removeWhere((i) => i.productId == productId);
    notifyListeners();
  }

  void clear() {
    items.clear();
    notifyListeners();
  }

  double total() => items.fold(0, (s, i) => s + (i.price * i.quantity));
}
