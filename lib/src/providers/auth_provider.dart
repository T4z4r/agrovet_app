import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  bool _isAuthenticated = false;
  Map<String, dynamic>? user;

  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('token');
    if (token != null) {
      _isAuthenticated = true;
      try {
        user = await _service.me();
      } catch (_) {
        user = null;
      }
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _service.login(email, password);
    if (res.containsKey('token')) {
      await ApiService.saveToken(res['token']);
      _isAuthenticated = true;
      user = res['user'];
      notifyListeners();
    }
    return res;
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    final res = await _service.register(name, email, password, role);
    if (res.containsKey('token')) {
      await ApiService.saveToken(res['token']);
      _isAuthenticated = true;
      user = res['user'];
      notifyListeners();
    }
    return res;
  }

  Future<void> logout() async {
    await _service.logout();
    _isAuthenticated = false;
    user = null;
    notifyListeners();
  }
}
