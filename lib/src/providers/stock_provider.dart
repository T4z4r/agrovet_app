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
      final res = await _api.getList<StockTransaction>(
        '/api/stock',
        fromJsonT: (data) => StockTransaction.fromJson(data),
      );
      
      if (res.success && res.data != null) {
        _transactions = res.data!;
      }
    } catch (e) {
      print('Failed to fetch stock transactions: $e');
    }

    loading = false;
    notifyListeners();
  }

  Future<bool> createTransaction(Map<String, dynamic> transactionData) async {
    try {
      final res = await _api.post<StockTransaction>(
        '/api/stock',
        transactionData,
        fromJsonT: (data) => StockTransaction.fromJson(data),
      );
      
      if (res.success && res.data != null) {
        _transactions.add(res.data!);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Failed to create stock transaction: $e');
    }
    return false;
  }

  Future<StockTransaction?> getTransaction(int id) async {
    try {
      final res = await _api.get<StockTransaction>(
        '/api/stock/$id',
        fromJsonT: (data) => StockTransaction.fromJson(data),
      );
      
      if (res.success && res.data != null) {
        return res.data!;
      }
    } catch (e) {
      print('Failed to get stock transaction: $e');
    }
    return null;
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      final res = await _api.delete<void>(
        '/api/stock/$id',
        fromJsonT: (_) => null,
      );
      
      if (res.success) {
        _transactions.removeWhere((t) => t.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Failed to delete stock transaction: $e');
    }
    return false;
  }
}
