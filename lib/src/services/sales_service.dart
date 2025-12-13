import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/sale.dart';

class SalesService {
  final ApiService _api = ApiService();

  // Get all sales
  Future<ApiResponse<List<Sale>>> getSales() async {
    final response = await _api.getList<Sale>(
      '/api/sales',
      fromJsonT: (data) => Sale.fromJson(data),
    );
    return response;
  }

  // Get specific sale
  Future<ApiResponse<Sale>> getSale(int id) async {
    final response = await _api.get<Sale>(
      '/api/sales/$id',
      fromJsonT: (data) => Sale.fromJson(data),
    );
    return response;
  }

  // Create sale
  Future<ApiResponse<Sale>> createSale({
    required int sellerId,
    required String saleDate,
    required List<Map<String, dynamic>>
        items, // Each item: {product_id, quantity, price}
  }) async {
    final response = await _api.post<Sale>(
      '/api/sales',
      {
        'seller_id': sellerId,
        'sale_date': saleDate,
        'items': items,
      },
      fromJsonT: (data) => Sale.fromJson(data),
    );
    return response;
  }

  // Download receipt PDF
  Future<http.Response> downloadReceipt(int saleId) async {
    return await _api.downloadFile('/api/sales/$saleId/receipt');
  }
}
