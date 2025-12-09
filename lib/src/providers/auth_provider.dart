import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  bool _isAuthenticated = false;
  User? user;

  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _loadFromStorage();
  }

  Future<void> _saveUser(User userData) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('user', jsonEncode(userData.toJson()));
  }

  Future<User?> _loadUser() async {
    final sp = await SharedPreferences.getInstance();
    final userJson = sp.getString('user');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> _clearUser() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('user');
  }

  Future<void> _loadFromStorage() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('token');
    if (token != null) {
      _isAuthenticated = true;
      user = await _loadUser();
      try {
        final res = await _service.me();
        if (res['success'] == true && res.containsKey('data')) {
          user = User.fromJson(res['data']);
          await _saveUser(user!);
        }
      } catch (_) {
        // Keep the cached user if API fails
      }
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _service.login(email, password);
    if (res['success'] == true && res.containsKey('data')) {
      await ApiService.saveToken(res['data']['token']);
      _isAuthenticated = true;
      user = User.fromJson(res['data']['user']);
      await _saveUser(user!);
      notifyListeners();
    }
    return res;
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    final res = await _service.register(name, email, password, role);
    if (res['success'] == true && res.containsKey('data')) {
      await ApiService.saveToken(res['data']['token']);
      _isAuthenticated = true;
      user = User.fromJson(res['data']['user']);
      await _saveUser(user!);
      notifyListeners();
    }
    return res;
  }

  Future<void> logout() async {
    await _service.logout();
    _isAuthenticated = false;
    user = null;
    await _clearUser();
    notifyListeners();
  }
}
