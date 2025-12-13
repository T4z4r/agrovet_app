import 'dart:convert';
import 'api_service.dart';
import '../models/user.dart';

// Auth response data structure
class AuthResponseData {
  final User user;
  final String token;

  AuthResponseData({required this.user, required this.token});

  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    return AuthResponseData(
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }
}

class AuthService {
  final ApiService _api = ApiService();

  // Login user
  Future<ApiResponse<AuthResponseData>> login(String email, String password) async {
    final response = await _api.post<AuthResponseData>(
      '/api/login',
      {
        'email': email,
        'password': password,
      },
      auth: false,
      fromJsonT: (data) => AuthResponseData.fromJson(data),
    );
    return response;
  }

  // Register user
  Future<ApiResponse<AuthResponseData>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _api.post<AuthResponseData>(
      '/api/register',
      {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
      },
      auth: false,
      fromJsonT: (data) => AuthResponseData.fromJson(data),
    );
    return response;
  }

  // Get current user
  Future<ApiResponse<User>> me() async {
    final response = await _api.get<User>(
      '/api/me',
      fromJsonT: (data) => User.fromJson(data),
    );
    return response;
  }

  // Logout user
  Future<ApiResponse<void>> logout() async {
    final response = await _api.post<void>(
      '/api/logout',
      {},
      fromJsonT: (_) => null,
    );
    
    if (response.success) {
      await ApiService.clearToken();
    }
    
    return response;
  }
}
