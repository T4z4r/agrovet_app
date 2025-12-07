import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/stock_transaction.dart';
import '../services/api_service.dart';

class StockProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<StockTransaction> _transactions = [];
  bool loading = false;

  List<StockTransaction> get transactions => _transactions;

  Future<void> fetchTransactions() async {
    loading = true;
    notifyListeners();

    try {
      final res = await _api.get('/stock');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _transactions = data.map((e) => StockTransaction.fromJson(e)).toList();
      }
    } catch (e) {
      // Handle error
    }

    loading = false;
    notifyListeners();
  }

  Future<bool> createTransaction(Map<String, dynamic> transactionData) async {
    try {
      final res = await _api.post('/stock', transactionData);
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final newTransaction = StockTransaction.fromJson(data);
        _transactions.add(newTransaction);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<StockTransaction?> getTransaction(int id) async {
    try {
      final res = await _api.get('/stock/$id');
      if (res.statusCode == 200) {
        return StockTransaction.fromJson(jsonDecode(res.body));
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      final res = await _api.delete('/stock/$id');
      if (res.statusCode == 200) {
        _transactions.removeWhere((t) => t.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }
}
