import 'api_service.dart';
import '../models/expense.dart';

class ExpenseService {
  final ApiService _api = ApiService();

  // Get all expenses
  Future<ApiResponse<List<Expense>>> getExpenses() async {
    final response = await _api.getList<Expense>(
      '/api/expenses',
      fromJsonT: (data) => Expense.fromJson(data),
    );
    return response;
  }

  // Get specific expense
  Future<ApiResponse<Expense>> getExpense(int id) async {
    final response = await _api.get<Expense>(
      '/api/expenses/$id',
      fromJsonT: (data) => Expense.fromJson(data),
    );
    return response;
  }

  // Create expense
  Future<ApiResponse<Expense>> createExpense({
    required String category,
    required int amount,
    String? description,
    required String date,
  }) async {
    final response = await _api.post<Expense>(
      '/api/expenses',
      {
        'category': category,
        'amount': amount,
        if (description != null) 'description': description,
        'date': date,
      },
      fromJsonT: (data) => Expense.fromJson(data),
    );
    return response;
  }

  // Update expense
  Future<ApiResponse<Expense>> updateExpense(
    int id, {
    String? category,
    int? amount,
    String? description,
    String? date,
  }) async {
    final response = await _api.put<Expense>(
      '/api/expenses/$id',
      {
        if (category != null) 'category': category,
        if (amount != null) 'amount': amount,
        if (description != null) 'description': description,
        if (date != null) 'date': date,
      },
      fromJsonT: (data) => Expense.fromJson(data),
    );
    return response;
  }

  // Delete expense
  Future<ApiResponse<void>> deleteExpense(int id) async {
    final response = await _api.delete<void>(
      '/api/expenses/$id',
      fromJsonT: (_) => null,
    );
    return response;
  }
}