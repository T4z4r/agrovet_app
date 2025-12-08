import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class SalesProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final DatabaseHelper _db = DatabaseHelper();
  List<Sale> _sales = [];
  bool loading = false;

  List<Sale> get sales => _sales;

  Future<void> fetchSales() async {
    loading = true;
    notifyListeners();

    // Load from local DB first
    final localSales = await _db.getSales();
    if (localSales.isNotEmpty) {
      _sales = await _convertDbSalesToSales(localSales);
      loading = false;
      notifyListeners();
    }

    // Try to fetch from API and update local DB
    try {
      final res = await _api.get('/sales');
      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        if (responseData['success'] == true) {
          final data = responseData['data'] as List;
          _sales = data.map((e) => Sale.fromJson(e)).toList();

          // Save to local DB
          for (var sale in data) {
            await _db.insertSale(sale);
          }
        }
      }
    } catch (e) {
      // If API fails, keep local data
    }

    loading = false;
    notifyListeners();
  }

  Future<List<Sale>> _convertDbSalesToSales(
      List<Map<String, dynamic>> dbSales) async {
    List<Sale> sales = [];
    for (var dbSale in dbSales) {
      final saleWithItems = await _db.getSaleWithItems(dbSale['id']);
      if (saleWithItems != null) {
        sales.add(Sale.fromJson(saleWithItems));
      }
    }
    return sales;
  }

  Future<bool> createSale(Map<String, dynamic> saleData) async {
    try {
      final res = await _api.post('/sales', saleData);
      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final newSale = Sale.fromJson(data);
          _sales.add(newSale);
          await _db.insertSale(data);
          notifyListeners();
          return true;
        } else if (res.statusCode == 422) {
          // Handle insufficient stock error
          throw Exception(responseData['message'] ?? 'Insufficient stock');
        }
      }
    } catch (e) {
      // If offline, save locally for later sync
      try {
        await _db.insertPendingSale(saleData);
        final newSale = Sale.fromJson({
          ...saleData,
          'id': DateTime.now().millisecondsSinceEpoch,
        });
        _sales.add(newSale);
        notifyListeners();
        return true;
      } catch (dbError) {
        // Handle database error
      }
    }
    return false;
  }

  Future<void> syncPendingSales() async {
    final pendingSales = await _db.getPendingSales();
    for (var sale in pendingSales) {
      try {
        final saleData = {
          'seller_id': sale['seller_id'],
          'sale_date': sale['sale_date'],
          'items': await _getSaleItems(sale['id']),
        };

        final res = await _api.post('/sales', saleData);
        if (res.statusCode == 201) {
          await _db.markSaleAsSynced(sale['id']);
        }
      } catch (e) {
        // Keep as pending if sync fails
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getSaleItems(int saleId) async {
    final saleWithItems = await _db.getSaleWithItems(saleId);
    return saleWithItems?['items'] ?? [];
  }

  Future<Sale?> getSale(int id) async {
    try {
      final res = await _api.get('/sales/$id');
      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        if (responseData['success'] == true) {
          return Sale.fromJson(responseData['data']);
        }
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

  void clearData() {
    _sales.clear();
    notifyListeners();
  }
}
