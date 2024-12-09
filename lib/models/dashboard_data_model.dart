import 'package:pos/models/transaction_model.dart';

class DashboardData {
  final double todaySales;
  final int todayTransactions;
  final int totalProducts;
  final List<Transaction> recentTransactions;
  final double monthlyRevenue;
  final double weeklyRevenue;
  final double salesGrowth;
  final int totalCustomers;
  final List<Map<String, dynamic>> bestSellingProducts;
  final List<Map<String, dynamic>> salesChartData;

  DashboardData({
    required this.todaySales,
    required this.todayTransactions,
    required this.totalProducts,
    required this.recentTransactions,
    required this.monthlyRevenue,
    required this.weeklyRevenue,
    required this.salesGrowth,
    required this.totalCustomers,
    required this.bestSellingProducts,
    required this.salesChartData,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      todaySales: (json['today_sales'] ?? 0).toDouble(),
      todayTransactions: json['today_transactions'] ?? 0,
      totalProducts: json['total_products_sold'] ?? 0,
      recentTransactions: (json['recent_transactions'] as List<dynamic>?)
              ?.map((t) => Transaction.fromJson(t))
              .toList() ??
          [],
      monthlyRevenue: (json['monthly_revenue'] ?? 0).toDouble(),
      weeklyRevenue: (json['weekly_revenue'] ?? 0).toDouble(),
      salesGrowth: (json['sales_growth'] ?? 0).toDouble(),
      totalCustomers: json['total_customers'] ?? 0,
      bestSellingProducts: json['best_selling_products'] != null
          ? List<Map<String, dynamic>>.from(json['best_selling_products'])
          : [],
      salesChartData: json['sales_chart_data'] != null
          ? List<Map<String, dynamic>>.from(json['sales_chart_data'])
          : [],
    );
  }

  factory DashboardData.empty() {
    return DashboardData(
      todaySales: 0.0,
      todayTransactions: 0,
      totalProducts: 0,
      recentTransactions: [],
      monthlyRevenue: 0.0,
      weeklyRevenue: 0.0,
      salesGrowth: 0.0,
      totalCustomers: 0,
      bestSellingProducts: [],
      salesChartData: [],
    );
  }
}
