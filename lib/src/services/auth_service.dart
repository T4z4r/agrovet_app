import 'dart:convert';
import 'package:http/http.dart' as http;
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
    await api.post('/logout', {}, auth: true);
    await ApiService.clearToken();
  }

  Future<Map<String, dynamic>> me() async {
    final res = await api.get('/me');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
