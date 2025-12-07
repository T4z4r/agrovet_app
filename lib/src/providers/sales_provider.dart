import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../services/api_service.dart';

class SalesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Sale> _sales = [];
  bool loading = false;

  List<Sale> get sales => _sales;

  Future<void> fetchSales() async {
    loading = true;
    notifyListeners();

    try {
      final res = await _api.get('/sales');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _sales = data.map((e) => Sale.fromJson(e)).toList();
      }
    } catch (e) {
      // Handle error
    }

    loading = false;
    notifyListeners();
  }

  Future<bool> createSale(Map<String, dynamic> saleData) async {
    try {
      final res = await _api.post('/sales', saleData);
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final newSale = Sale.fromJson(data);
        _sales.add(newSale);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<Sale?> getSale(int id) async {
    try {
      final res = await _api.get('/sales/$id');
      if (res.statusCode == 200) {
        return Sale.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  Future<String?> downloadReceipt(int id) async {
    try {
      final res = await _api.get('/sales/$id/receipt');
      if (res.statusCode == 200) {
        // Assuming it returns a URL or content
        return res.body;
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }
}