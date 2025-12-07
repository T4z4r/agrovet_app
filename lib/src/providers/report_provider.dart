import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  Map<String, dynamic>? dailyReport;

  Future<void> fetchDailyReport(String date) async {
    final res = await _api.get('/reports/daily/$date');
    if (res.statusCode == 200) {
      dailyReport = jsonDecode(res.body);
      notifyListeners();
    }
  }
}
