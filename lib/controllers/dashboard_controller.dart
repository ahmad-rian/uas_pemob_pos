import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:pos/models/dashboard_data_model.dart';

class DashboardController extends GetxController {
  final isLoading = false.obs;
  final userName = 'User'.obs;
  final userEmail = ''.obs;
  final dashboardData = Rx<DashboardData>(DashboardData.empty());
  final selectedIndex = 0.obs;
  final baseUrl = 'http://localhost:8000/api';

  // Observable statistics
  final monthlyRevenue = 0.0.obs;
  final weeklyRevenue = 0.0.obs;
  final salesGrowth = 0.0.obs;
  final bestSellingProducts = <Map<String, dynamic>>[].obs;
  final totalCustomers = 0.obs;
  Timer? _refreshTimer;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    fetchDashboardData();
    _startAutoRefresh();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.offAllNamed('/login');
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        userName.value = userData['name'] ?? 'User';
        userEmail.value = userData['email'] ?? '';
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error loading user data: $e');
      Get.snackbar(
        'Error',
        'Failed to load user data',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.offAllNamed('/login');
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          final data = jsonResponse['data'];

          // Ensure all required fields exist with default values if missing
          final sanitizedData = {
            'today_sales': data['today_sales'] ?? 0.0,
            'today_transactions': data['today_transactions'] ?? 0,
            'total_products_sold': data['total_products_sold'] ?? 0,
            'recent_transactions': data['recent_transactions'] ?? [],
            'monthly_revenue': data['monthly_revenue'] ?? 0.0,
            'weekly_revenue': data['weekly_revenue'] ?? 0.0,
            'sales_growth': data['sales_growth'] ?? 0.0,
            'total_customers': data['total_customers'] ?? 0,
            'best_selling_products': data['best_selling_products'] ?? [],
            'sales_chart_data': data['sales_chart_data'] ?? [],
          };

          dashboardData.value = DashboardData.fromJson(sanitizedData);

          // Update individual observable variables
          monthlyRevenue.value =
              (sanitizedData['monthly_revenue'] as num).toDouble();
          weeklyRevenue.value =
              (sanitizedData['weekly_revenue'] as num).toDouble();
          salesGrowth.value = (sanitizedData['sales_growth'] as num).toDouble();
          totalCustomers.value = sanitizedData['total_customers'] as int;
          bestSellingProducts.value = List<Map<String, dynamic>>.from(
              sanitizedData['best_selling_products']);
        } else {
          throw Exception('Invalid response format');
        }
      } else if (response.statusCode == 401) {
        await prefs.clear();
        Get.offAllNamed('/login');
      } else {
        throw Exception(
            'Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
      Get.snackbar(
        'Error',
        'Failed to load dashboard data. Please try again later.',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  double calculateGrowthPercentage(double current, double previous) {
    if (previous == 0) return 0;
    return ((current - previous) / previous) * 100;
  }

  String getGrowthIndicator(double value) {
    if (value > 0) return '↑';
    if (value < 0) return '↓';
    return '−';
  }

  Color getGrowthColor(double value) {
    if (value > 0) return Colors.green;
    if (value < 0) return Colors.red;
    return Colors.grey;
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      fetchDashboardData();
    });
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }
}
