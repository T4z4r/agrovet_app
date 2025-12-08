import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  bool _isOnline = false;

  ConnectivityService() {
    _initConnectivity();
    _subscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  bool get isOnline => _isOnline;
  ConnectivityResult get connectivityResult => _connectivityResult;

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('Failed to get connectivity: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Take the first result or default to none
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    _connectivityResult = result;
    _isOnline = result != ConnectivityResult.none;
    notifyListeners();
  }

  Future<bool> checkInternetConnection() async {
    try {
      // Simple internet connectivity check by trying to reach a reliable host
      // This is a basic implementation - you might want to use a more robust solution
      final results = await _connectivity.checkConnectivity();
      final result =
          results.isNotEmpty ? results.first : ConnectivityResult.none;
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
