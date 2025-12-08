import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Expense> _expenses = [];
  bool loading = false;

  List<Expense> get expenses => _expenses;

  Future<void> fetchExpenses() async {
    loading = true;
    notifyListeners();

    try {
      final res = await _api.get('/expenses');
      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        if (responseData['success'] == true) {
          final data = responseData['data'] as List;
          _expenses = data.map((e) => Expense.fromJson(e)).toList();
        }
      }
    } catch (e) {
      // Handle error
    }

    loading = false;
    notifyListeners();
  }

  Future<bool> createExpense(Map<String, dynamic> expenseData) async {
    try {
      final res = await _api.post('/expenses', expenseData);
      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final newExpense = Expense.fromJson(data);
          _expenses.add(newExpense);
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      // Handle error
    }
    return false;
  }

  Future<Expense?> getExpense(int id) async {
    try {
      final res = await _api.get('/expenses/$id');
      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        if (responseData['success'] == true) {
          return Expense.fromJson(responseData['data']);
        }
      }
    } catch (e) {
      // Handle error
    }
    return null;
  }

  Future<bool> updateExpense(int id, Map<String, dynamic> expenseData) async {
    try {
      final res = await _api.put('/expenses/$id', expenseData);
      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final updatedExpense = Expense.fromJson(data);
          final index = _expenses.indexWhere((e) => e.id == id);
          if (index >= 0) {
            _expenses[index] = updatedExpense;
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

  Future<bool> deleteExpense(int id) async {
    try {
      final res = await _api.delete('/expenses/$id');
      if (res.statusCode == 200) {
        final responseData = jsonDecode(res.body);
        if (responseData['success'] == true) {
          _expenses.removeWhere((e) => e.id == id);
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
