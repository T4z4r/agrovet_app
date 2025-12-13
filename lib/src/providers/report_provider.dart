import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  Map<String, dynamic>? dailyReport;
  Map<String, dynamic>? profitReport;
  Map<String, dynamic>? dashboardData;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchDailyReport(String date) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _api.get<Map<String, dynamic>>('/reports/daily/$date');
      
      if (res.success && res.data != null) {
        dailyReport = res.data;
      } else {
        errorMessage = res.message.isNotEmpty ? res.message : 'Failed to fetch daily report';
      }
    } catch (e) {
      errorMessage = 'Failed to fetch daily report: ${e.toString()}';
      dailyReport = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfitReport(String startDate, String endDate) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _api.get<Map<String, dynamic>>('/reports/profit/$startDate/$endDate');
      
      if (res.success && res.data != null) {
        profitReport = res.data;
      } else {
        errorMessage = res.message.isNotEmpty ? res.message : 'Failed to fetch profit report';
      }
    } catch (e) {
      errorMessage = 'Failed to fetch profit report: ${e.toString()}';
      profitReport = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDashboardData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _api.get<Map<String, dynamic>>('/reports/dashboard');
      
      if (res.success && res.data != null) {
        dashboardData = res.data;
      } else {
        errorMessage = res.message.isNotEmpty ? res.message : 'Failed to fetch dashboard data';
      }
    } catch (e) {
      errorMessage = 'Failed to fetch dashboard data: ${e.toString()}';
      dashboardData = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  void clearReports() {
    dailyReport = null;
    profitReport = null;
    dashboardData = null;
    errorMessage = null;
    notifyListeners();
  }
}
