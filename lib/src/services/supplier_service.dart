import 'api_service.dart';
import '../models/supplier.dart';

class SupplierService {
  final ApiService _api = ApiService();

  // Get all suppliers
  Future<ApiResponse<List<Supplier>>> getSuppliers() async {
    final response = await _api.getList<Supplier>(
      '/api/suppliers',
      fromJsonT: (data) => Supplier.fromJson(data),
    );
    return response;
  }

  // Get specific supplier
  Future<ApiResponse<Supplier>> getSupplier(int id) async {
    final response = await _api.get<Supplier>(
      '/api/suppliers/$id',
      fromJsonT: (data) => Supplier.fromJson(data),
    );
    return response;
  }

  // Create supplier
  Future<ApiResponse<Supplier>> createSupplier({
    required String name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
  }) async {
    final response = await _api.post<Supplier>(
      '/api/suppliers',
      {
        'name': name,
        if (contactPerson != null) 'contact_person': contactPerson,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
      },
      fromJsonT: (data) => Supplier.fromJson(data),
    );
    return response;
  }

  // Update supplier
  Future<ApiResponse<Supplier>> updateSupplier(
    int id, {
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
  }) async {
    final response = await _api.put<Supplier>(
      '/api/suppliers/$id',
      {
        if (name != null) 'name': name,
        if (contactPerson != null) 'contact_person': contactPerson,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
      },
      fromJsonT: (data) => Supplier.fromJson(data),
    );
    return response;
  }

  // Delete supplier
  Future<ApiResponse<void>> deleteSupplier(int id) async {
    final response = await _api.delete<void>(
      '/api/suppliers/$id',
      fromJsonT: (_) => null,
    );
    return response;
  }
}