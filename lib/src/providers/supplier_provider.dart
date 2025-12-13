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
      final res = await _api.getList<Supplier>(
        '/suppliers',
        fromJsonT: (data) => Supplier.fromJson(data),
      );

      if (res.success && res.data != null) {
        _suppliers = res.data!;
      }
    } catch (e) {
      // Handle error
    }

    loading = false;
    notifyListeners();
  }

  Future<bool> createSupplier(Map<String, dynamic> supplierData) async {
    try {
      final res = await _api.post<Supplier>(
        '/suppliers',
        supplierData,
        fromJsonT: (data) => Supplier.fromJson(data),
      );

      if (res.success && res.data != null) {
        _suppliers.add(res.data!);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<Supplier?> getSupplier(int id) async {
    try {
      final res = await _api.get<Supplier>(
        '/suppliers/$id',
        fromJsonT: (data) => Supplier.fromJson(data),
      );

      if (res.success && res.data != null) {
        return res.data!;
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  Future<bool> updateSupplier(int id, Map<String, dynamic> supplierData) async {
    try {
      final res = await _api.put<Supplier>(
        '/suppliers/$id',
        supplierData,
        fromJsonT: (data) => Supplier.fromJson(data),
      );

      if (res.success && res.data != null) {
        final index = _suppliers.indexWhere((s) => s.id == id);
        if (index >= 0) {
          _suppliers[index] = res.data!;
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<bool> deleteSupplier(int id) async {
    try {
      final res = await _api.delete<void>('/suppliers/$id');

      if (res.success) {
        _suppliers.removeWhere((s) => s.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }
}
