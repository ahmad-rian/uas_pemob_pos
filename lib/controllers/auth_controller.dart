import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final String baseUrl = 'http://localhost:8000/api';

  Future<bool> login(String username, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Save token to shared preferences (you can replace this with secure storage if needed)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        // Navigate to dashboard (you can replace this with your navigation logic)
        Get.offAllNamed('/dashboard');

        return true;
      } else {
        final data = json.decode(response.body);
        errorMessage.value = data['message'] ?? 'Invalid credentials';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Connection error';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': username,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final data = json.decode(response.body);
        errorMessage.value = data['message'] ?? 'Registration failed';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Connection error';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        errorMessage.value = 'No token found';
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await prefs.clear();
        Get.offAllNamed('/login');
        return true;
      } else {
        errorMessage.value = 'Logout failed';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Logout failed. Please try again.';
      Get.snackbar(
        'Error',
        'Logout failed. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
}
