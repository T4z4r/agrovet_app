import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  Map<String, dynamic>? dailyReport;
  Map<String, dynamic>? profitReport;
  Map<String, dynamic>? dashboardData;

  Future<void> fetchDailyReport(String date) async {
    final res = await _api.get('/reports/daily/$date');
    if (res.statusCode == 200) {
      final responseData = jsonDecode(res.body);
      if (responseData['success'] == true) {
        dailyReport = responseData['data'];
        notifyListeners();
      }
    }
  }

  Future<void> fetchProfitReport(String startDate, String endDate) async {
    final res = await _api.get('/reports/profit/$startDate/$endDate');
    if (res.statusCode == 200) {
      final responseData = jsonDecode(res.body);
      if (responseData['success'] == true) {
        profitReport = responseData['data'];
        notifyListeners();
      }
    }
  }

  Future<void> fetchDashboardData() async {
    final res = await _api.get('/reports/dashboard');
    if (res.statusCode == 200) {
      final responseData = jsonDecode(res.body);
      if (responseData['success'] == true) {
        dashboardData = responseData['data'];
        notifyListeners();
      }
    }
  }
}
