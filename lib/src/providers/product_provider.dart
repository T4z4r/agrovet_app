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

  Future<bool> createProduct(Map<String, dynamic> productData) async {
    try {
      final res = await _api.post('/products', productData);
      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        if (responseData['success'] == true) {
          final productJson = responseData['data'];
          final newProduct = Product.fromJson(productJson);
          _products.add(newProduct);
          final db = DatabaseHelper();
          await db.insertProduct(productJson);
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<Product?> getProduct(int id) async {
    try {
      final res = await _api.get('/products/$id');
      if (res.statusCode == 200) {
        return Product.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> productData) async {
    try {
      final res = await _api.put('/products/$id', productData);
      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        if (responseData['success'] == true) {
          final productJson = responseData['data'];
          final updatedProduct = Product.fromJson(productJson);
          final index = _products.indexWhere((p) => p.id == id);
          if (index >= 0) {
            _products[index] = updatedProduct;
            final db = DatabaseHelper();
            await db.updateProduct(id, productJson);
            notifyListeners();
          }
          return true;
        }
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final res = await _api.delete('/products/$id');
      if (res.statusCode == 200) {
        _products.removeWhere((p) => p.id == id);
        final db = DatabaseHelper();
        await db.deleteProduct(id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  void clearData() {
    _products.clear();
    notifyListeners();
  }
}
