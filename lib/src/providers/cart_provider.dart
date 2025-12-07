import 'package:flutter/material.dart';
import '../models/sale_item.dart';
import '../services/database_helper.dart';

class CartProvider extends ChangeNotifier {
  final List<SaleItem> items = [];
  final DatabaseHelper _db = DatabaseHelper();
  bool _loaded = false;

  bool get loaded => _loaded;

  Future<void> loadCart() async {
    if (_loaded) return;
    final cartData = await _db.getCartItems();
    items.clear();
    for (var data in cartData) {
      items.add(SaleItem(
        productId: data['product_id'],
        quantity: data['quantity'],
        price: data['price'],
      ));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> addItem(SaleItem item) async {
    final idx = items.indexWhere((i) => i.productId == item.productId);
    if (idx >= 0) {
      items[idx].quantity += item.quantity;
      // Update quantity in DB
      final cartData = await _db.getCartItems();
      final dbItem = cartData
          .firstWhere((element) => element['product_id'] == item.productId);
      await _db.updateCartItem(dbItem['id'], {
        'product_id': item.productId,
        'quantity': items[idx].quantity,
        'price': item.price,
      });
    } else {
      items.add(item);
      await _db.insertCartItem({
        'product_id': item.productId,
        'quantity': item.quantity,
        'price': item.price,
      });
    }
    notifyListeners();
  }

  Future<void> removeItem(int productId) async {
    items.removeWhere((i) => i.productId == productId);
    await _db.deleteCartItemByProductId(productId);
    notifyListeners();
  }

  Future<void> clear() async {
    items.clear();
    await _db.clearCart();
    notifyListeners();
  }

  double total() => items.fold(0, (s, i) => s + (i.price * i.quantity));
}
