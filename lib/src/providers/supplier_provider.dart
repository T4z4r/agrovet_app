import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../services/api_service.dart';

class SupplierProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Supplier> _suppliers = [];
  bool loading = false;

  List<Supplier> get suppliers => _suppliers;

  Future<void> fetchSuppliers() async {
    loading = true;
    notifyListeners();

    try {
      final res = await _api.get('/suppliers');
      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        if (responseData['success'] == true) {
          final data = responseData['data'] as List;
          _suppliers = data.map((e) => Supplier.fromJson(e)).toList();
        }
      }
    } catch (e) {
      // Handle error
    }

    loading = false;
    notifyListeners();
  }

  Future<bool> createSupplier(Map<String, dynamic> supplierData) async {
    try {
      final res = await _api.post('/suppliers', supplierData);
      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final newSupplier = Supplier.fromJson(data);
          _suppliers.add(newSupplier);
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<Supplier?> getSupplier(int id) async {
    try {
      final res = await _api.get('/suppliers/$id');
      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        if (responseData['success'] == true) {
          return Supplier.fromJson(responseData['data']);
        }
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  Future<bool> updateSupplier(int id, Map<String, dynamic> supplierData) async {
    try {
      final res = await _api.put('/suppliers/$id', supplierData);
      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final updatedSupplier = Supplier.fromJson(data);
          final index = _suppliers.indexWhere((s) => s.id == id);
          if (index >= 0) {
            _suppliers[index] = updatedSupplier;
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

  Future<bool> deleteSupplier(int id) async {
    try {
      final res = await _api.delete('/suppliers/$id');
      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        if (responseData['success'] == true) {
          _suppliers.removeWhere((s) => s.id == id);
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }
}
