import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;

class ProductProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Product> _products = [];
  bool loading = false;

  List<Product> get products => _products;

  Future<void> fetchProducts() async {
    loading = true;
    notifyListeners();
    final res = await _api.get('/products');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _products = (data as List).map((e) => Product.fromJson(e)).toList();
    }
    loading = false;
    notifyListeners();
  }
}
