import 'dart:convert';
import 'api_service.dart';

class AuthService {
  final ApiService api = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await api.post('/login', {'email': email, 'password': password},
        auth: false);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    final res = await api.post(
        '/register',
        {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'role': role,
        },
        auth: false);
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<void> logout() async {
    final res = await api.post('/logout', {}, auth: true);
    final responseData = jsonDecode(res.body) as Map<String, dynamic>;
    if (responseData['success'] == true) {
      await ApiService.clearToken();
    } else {
      throw Exception(responseData['message'] ?? 'Logout failed');
    }
  }

  Future<Map<String, dynamic>> me() async {
    final res = await api.get('/me');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
