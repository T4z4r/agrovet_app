import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import 'package:http/http.dart' as http;

class ProductProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Product> _products = [];
  bool loading = false;

  List<Product> get products => _products;

  Future<void> fetchProducts() async {
    loading = true;
    notifyListeners();

    // Load from local DB first
    final db = DatabaseHelper();
    final localProducts = await db.getProducts();
    if (localProducts.isNotEmpty) {
      _products = localProducts.map((e) => Product.fromJson(e)).toList();
      loading = false;
      notifyListeners();
    }

    // Try to fetch from API and update local DB
    try {
      final res = await _api.get('/products');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _products = (data as List).map((e) => Product.fromJson(e)).toList();

        // Save to local DB
        for (var product in data) {
          await db.insertProduct(product);
        }
      }
    } catch (e) {
      // If API fails, keep local data
    }

    loading = false;
    notifyListeners();
  }
}
