import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardController extends GetxController {
  final baseUrl = 'http://localhost:8000/api';
  final isLoading = false.obs;

  // User Profile
  final userName = 'User Name'.obs;
  final userEmail = 'user@email.com'.obs;
  final selectedIndex = 0.obs;

  // Dashboard Stats
  final todaySales = 0.0.obs;
  final todayTransactions = 0.obs;
  final totalProducts = 0.obs;
  final salesChartData = <FlSpot>[].obs;
  final recentTransactions = [].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    fetchDashboardData();
  }

  // Load user profile data from shared preferences
  Future<void> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('user_name') ?? 'User Name';
    userEmail.value = prefs.getString('user_email') ?? 'user@email.com';
  }

  // Change the selected index for the bottom navigation or tabs
  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  // Fetch the dashboard data from the API
  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.snackbar(
          'Error',
          'Token is missing. Please log in again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Parse dashboard data
        todaySales.value = data['today_sales'] != null
            ? double.parse(data['today_sales'].toString())
            : 0.0;
        todayTransactions.value = data['today_transactions'] ?? 0;
        totalProducts.value = data['total_products'] ?? 0;
        recentTransactions.value = List.from(data['recent_transactions'] ?? []);

        // Parse sales chart data
        final List<FlSpot> spots = [];
        for (var item in data['sales_chart'] ?? []) {
          spots.add(FlSpot(
            spots.length.toDouble(),
            double.parse(item['total'].toString()),
          ));
        }
        salesChartData.value = spots;
      } else {
        Get.snackbar(
          'Error',
          'Failed to load dashboard data: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while fetching dashboard data. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
