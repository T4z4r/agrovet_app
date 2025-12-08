import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'http://agrovet.sudsudgroup.com/api';

  Future<String?> _getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('token');
  }

  Future<http.Response> post(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _headers(auth: auth);
    return http.post(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> get(String path, {bool auth = true}) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _headers(auth: auth);
    return http.get(url, headers: headers);
  }

  Future<http.Response> put(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _headers(auth: auth);
    return http.put(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> delete(String path, {bool auth = true}) async {
    final url = Uri.parse('$baseUrl$path');
    final headers = await _headers(auth: auth);
    return http.delete(url, headers: headers);
  }

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

  // helper to save token
  static Future<void> saveToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('token', token);
  }

  static Future<void> clearToken() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('token');
  }
}
