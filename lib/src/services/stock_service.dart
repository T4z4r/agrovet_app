import 'api_service.dart';
import '../models/stock_transaction.dart';

class StockService {
  final ApiService _api = ApiService();

  // Get all stock transactions
  Future<ApiResponse<List<StockTransaction>>> getStockTransactions() async {
    final response = await _api.getList<StockTransaction>(
      '/api/stock',
      fromJsonT: (data) => StockTransaction.fromJson(data),
    );
    return response;
  }

  // Get specific stock transaction
  Future<ApiResponse<StockTransaction>> getStockTransaction(int id) async {
    final response = await _api.get<StockTransaction>(
      '/api/stock/$id',
      fromJsonT: (data) => StockTransaction.fromJson(data),
    );
    return response;
  }

  // Create stock transaction
  Future<ApiResponse<StockTransaction>> createStockTransaction({
    required int productId,
    required String type, // stock_in, stock_out, damage, return
    required int quantity,
    int? supplierId,
    required String date,
    String? remarks,
  }) async {
    final response = await _api.post<StockTransaction>(
      '/api/stock',
      {
        'product_id': productId,
        'type': type,
        'quantity': quantity,
        if (supplierId != null) 'supplier_id': supplierId,
        'date': date,
        if (remarks != null) 'remarks': remarks,
      },
      fromJsonT: (data) => StockTransaction.fromJson(data),
    );
    return response;
  }

  // Delete stock transaction
  Future<ApiResponse<void>> deleteStockTransaction(int id) async {
    final response = await _api.delete<void>(
      '/api/stock/$id',
      fromJsonT: (_) => null,
    );
    return response;
  }
}