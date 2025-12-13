import 'api_service.dart';

class DashboardData {
  final int totalProducts;
  final int totalSales;
  final int totalExpenses;
  final int todaySales;
  final int stockValue;

  DashboardData({
    required this.totalProducts,
    required this.totalSales,
    required this.totalExpenses,
    required this.todaySales,
    required this.stockValue,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalProducts: json['total_products'] ?? 0,
      totalSales: json['total_sales'] ?? 0,
      totalExpenses: json['total_expenses'] ?? 0,
      todaySales: json['today_sales'] ?? 0,
      stockValue: json['stock_value'] ?? 0,
    );
  }
}

class DailyReport {
  final List<dynamic> sales;
  final int totalSales;
  final List<dynamic> expenses;
  final int totalExpenses;

  DailyReport({
    required this.sales,
    required this.totalSales,
    required this.expenses,
    required this.totalExpenses,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      sales: json['sales'] ?? [],
      totalSales: json['total_sales'] ?? 0,
      expenses: json['expenses'] ?? [],
      totalExpenses: json['total_expenses'] ?? 0,
    );
  }
}

class ProfitReport {
  final int revenue;
  final int cost;
  final int profit;

  ProfitReport({
    required this.revenue,
    required this.cost,
    required this.profit,
  });

  factory ProfitReport.fromJson(Map<String, dynamic> json) {
    return ProfitReport(
      revenue: json['revenue'] ?? 0,
      cost: json['cost'] ?? 0,
      profit: json['profit'] ?? 0,
    );
  }
}

class ReportsService {
  final ApiService _api = ApiService();

  // Get dashboard data
  Future<ApiResponse<DashboardData>> getDashboardData() async {
    final response = await _api.get<DashboardData>(
      '/api/reports/dashboard',
      fromJsonT: (data) => DashboardData.fromJson(data),
    );
    return response;
  }

  // Get daily report
  Future<ApiResponse<DailyReport>> getDailyReport(String date) async {
    final response = await _api.get<DailyReport>(
      '/api/reports/daily/$date',
      fromJsonT: (data) => DailyReport.fromJson(data),
    );
    return response;
  }

  // Get profit report
  Future<ApiResponse<ProfitReport>> getProfitReport(String start, String end) async {
    final response = await _api.get<ProfitReport>(
      '/api/reports/profit/$start/$end',
      fromJsonT: (data) => ProfitReport.fromJson(data),
    );
    return response;
  }
}