import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final Map<String, dynamic>? rawResponse;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.rawResponse,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, 
    T Function(dynamic)? fromJsonT
  ) {
    T? parsedData;
    if (fromJsonT != null && json['data'] != null) {
      try {
        parsedData = fromJsonT(json['data']);
      } catch (e) {
        parsedData = null;
      }
    }
    
    return ApiResponse(
      success: json['success'] ?? false,
      data: parsedData,
      message: json['message'] ?? '',
      rawResponse: json,
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://agrovet.sudsudgroup.com/api';
  
  // API Response wrapper methods
  static Future<ApiResponse<T>> handleResponse<T>(
    http.Response response, 
    T Function(dynamic)? fromJsonT
  ) async {
    try {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Handle non-200 status codes
      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorMessage = jsonResponse['message'] ?? 
          'Request failed with status ${response.statusCode}';
        throw ApiException(errorMessage, response.statusCode);
      }
      
      return ApiResponse.fromJson(jsonResponse, fromJsonT);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to parse response: ${e.toString()}');
    }
  }

  // Token management
  static Future<String?> _getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('token', token);
  }

  static Future<void> clearToken() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('token');
  }

  // HTTP Headers
  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (auth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }

  // Generic HTTP Methods
  Future<ApiResponse<T>> get<T>(
    String path, {
    bool auth = true,
    T Function(dynamic)? fromJsonT,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _headers(auth: auth);
    
    try {
      final response = await http.get(url, headers: headers);
      return await ApiService.handleResponse(response, fromJsonT);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('GET request failed: ${e.toString()}');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
    T Function(dynamic)? fromJsonT,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _headers(auth: auth);
    
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      return await ApiService.handleResponse(response, fromJsonT);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('POST request failed: ${e.toString()}');
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
    T Function(dynamic)? fromJsonT,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _headers(auth: auth);
    
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      return await ApiService.handleResponse(response, fromJsonT);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('PUT request failed: ${e.toString()}');
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    bool auth = true,
    T Function(dynamic)? fromJsonT,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _headers(auth: auth);
    
    try {
      final response = await http.delete(url, headers: headers);
      return await ApiService.handleResponse(response, fromJsonT);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('DELETE request failed: ${e.toString()}');
    }
  }

  // Convenience methods for list responses
  Future<ApiResponse<List<T>>> getList<T>(
    String path, {
    bool auth = true,
    T Function(dynamic)? fromJsonT,
  }) async {
    return get<List<T>>(
      path,
      auth: auth,
      fromJsonT: (data) {
        if (data is List) {
          return data.map((item) => fromJsonT!(item)).toList();
        }
        return <T>[];
      },
    );
  }

  // Download file method for receipts
  Future<http.Response> downloadFile(
    String path, {
    bool auth = true,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _headers(auth: auth);
    
    return http.get(url, headers: headers);
  }
}
