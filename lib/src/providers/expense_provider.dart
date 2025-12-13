import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _service = ExpenseService();
  List<Expense> _expenses = [];
  bool loading = false;

  List<Expense> get expenses => _expenses;

  Future<void> fetchExpenses() async {
    loading = true;
    notifyListeners();

    try {
      final res = await _service.getExpenses();
      if (res.success && res.data != null) {
        _expenses = res.data!;
      }
    } catch (e) {
      print('Failed to fetch expenses: $e');
    }

    loading = false;
    notifyListeners();
  }

  Future<bool> createExpense(Map<String, dynamic> expenseData) async {
    try {
      final res = await _service.createExpense(
        category: expenseData['category'],
        amount: expenseData['amount'],
        description: expenseData['description'],
        date: expenseData['date'],
      );

      if (res.success && res.data != null) {
        _expenses.add(res.data!);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Failed to create expense: $e');
    }
    return false;
  }

  Future<Expense?> getExpense(int id) async {
    try {
      final res = await _service.getExpense(id);
      if (res.success && res.data != null) {
        return res.data!;
      }
    } catch (e) {
      print('Failed to get expense: $e');
    }
    return null;
  }

  Future<bool> updateExpense(int id, Map<String, dynamic> expenseData) async {
    try {
      final res = await _service.updateExpense(
        id,
        category: expenseData['category'],
        amount: expenseData['amount'],
        description: expenseData['description'],
        date: expenseData['date'],
      );

      if (res.success && res.data != null) {
        final index = _expenses.indexWhere((e) => e.id == id);
        if (index >= 0) {
          _expenses[index] = res.data!;
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      print('Failed to update expense: $e');
    }
    return false;
  }

  Future<bool> deleteExpense(int id) async {
    try {
      final res = await _service.deleteExpense(id);
      if (res.success) {
        _expenses.removeWhere((e) => e.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Failed to delete expense: $e');
    }
    return false;
  }

  void clearData() {
    _expenses.clear();
    notifyListeners();
  }
}
