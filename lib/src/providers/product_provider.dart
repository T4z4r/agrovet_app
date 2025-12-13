import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

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
      final res = await _api.getList<Product>(
        '/api/products',
        fromJsonT: (data) => Product.fromJson(data),
      );
      
      if (res.success && res.data != null) {
        _products = res.data!;
        
        // Save to local DB
        for (var product in res.data!) {
          await db.insertProduct(product.toJson());
        }
      }
    } catch (e) {
      // If API fails, keep local data
      print('Failed to fetch products: $e');
    }

    loading = false;
    notifyListeners();
  }

  Future<bool> createProduct(Map<String, dynamic> productData) async {
    try {
      final res = await _api.post<Product>(
        '/api/products',
        productData,
        fromJsonT: (data) => Product.fromJson(data),
      );
      
      if (res.success && res.data != null) {
        _products.add(res.data!);
        final db = DatabaseHelper();
        await db.insertProduct(productData);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Failed to create product: $e');
    }
    return false;
  }

  Future<Product?> getProduct(int id) async {
    try {
      final res = await _api.get<Product>(
        '/api/products/$id',
        fromJsonT: (data) => Product.fromJson(data),
      );
      
      if (res.success && res.data != null) {
        return res.data!;
      }
    } catch (e) {
      print('Failed to get product: $e');
    }
    return null;
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> productData) async {
    try {
      final res = await _api.put<Product>(
        '/api/products/$id',
        productData,
        fromJsonT: (data) => Product.fromJson(data),
      );
      
      if (res.success && res.data != null) {
        final index = _products.indexWhere((p) => p.id == id);
        if (index >= 0) {
          _products[index] = res.data!;
          final db = DatabaseHelper();
          await db.updateProduct(id, productData);
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      print('Failed to update product: $e');
    }
    return false;
  }

  Future<bool> deleteProduct(int id) async {
    try {
      final res = await _api.delete<void>(
        '/api/products/$id',
        fromJsonT: (_) => null,
      );
      
      if (res.success) {
        _products.removeWhere((p) => p.id == id);
        final db = DatabaseHelper();
        await db.deleteProduct(id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Failed to delete product: $e');
    }
    return false;
  }

  void clearData() {
    _products.clear();
    notifyListeners();
  }
}
