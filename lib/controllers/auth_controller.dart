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

      // Basic validation
      if (!GetUtils.isEmail(username)) {
        errorMessage.value = 'Please enter a valid email address';
        return false;
      }

      if (password.length < 8) {
        errorMessage.value = 'Password must be at least 8 characters long';
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': username,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        Get.offAllNamed('/dashboard');
        return true;
      } else {
        // Handle different error cases
        switch (response.statusCode) {
          case 401:
            errorMessage.value = 'Invalid email or password';
            break;
          case 422:
            if (data['errors'] != null) {
              final errors = data['errors'] as Map<String, dynamic>;
              if (errors.containsKey('email')) {
                errorMessage.value = errors['email'][0];
              } else if (errors.containsKey('password')) {
                errorMessage.value = errors['password'][0];
              } else {
                errorMessage.value =
                    'Validation error. Please check your input.';
              }
            } else {
              errorMessage.value = data['message'] ?? 'Validation failed';
            }
            break;
          case 429:
            errorMessage.value =
                'Too many login attempts. Please try again later.';
            break;
          default:
            errorMessage.value =
                data['message'] ?? 'An unexpected error occurred';
        }
        return false;
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        errorMessage.value =
            'Unable to connect to server. Please check your internet connection.';
      } else {
        errorMessage.value = 'An unexpected error occurred. Please try again.';
      }
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

      // Client-side validation
      if (username.isEmpty || username.length < 3) {
        errorMessage.value = 'Username must be at least 3 characters long';
        return false;
      }

      if (!GetUtils.isEmail(email)) {
        errorMessage.value = 'Please enter a valid email address';
        return false;
      }

      if (password.length < 8) {
        errorMessage.value = 'Password must be at least 8 characters long';
        return false;
      }

      if (password != passwordConfirmation) {
        errorMessage.value = 'Passwords do not match';
        return false;
      }

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

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Registration successful! Please login with your credentials.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        // Handle different error cases
        switch (response.statusCode) {
          case 422:
            if (data['errors'] != null) {
              final errors = data['errors'] as Map<String, dynamic>;
              if (errors.containsKey('email')) {
                errorMessage.value = 'Email address is already in use';
              } else if (errors.containsKey('name')) {
                errorMessage.value = 'Username is already taken';
              } else if (errors.containsKey('password')) {
                errorMessage.value = errors['password'][0];
              } else {
                errorMessage.value =
                    'Validation error. Please check your input.';
              }
            } else {
              errorMessage.value = data['message'] ?? 'Registration failed';
            }
            break;
          default:
            errorMessage.value =
                data['message'] ?? 'Registration failed. Please try again.';
        }
        return false;
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        errorMessage.value =
            'Unable to connect to server. Please check your internet connection.';
      } else {
        errorMessage.value = 'An unexpected error occurred. Please try again.';
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> logout() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        await _clearLocalData();
        return true;
      }

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        await _clearLocalData();

        if (response.statusCode == 200) {
          Get.snackbar(
            'Success',
            'You have been successfully logged out',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.TOP,
          );
        }
      } catch (e) {
        print('Logout request failed: $e');
      }

      await _clearLocalData();
      return true;
    } catch (e) {
      print('Logout error: $e');
      errorMessage.value = 'Error during logout. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAllNamed('/login');
    } catch (e) {
      print('Error clearing local data: $e');
      errorMessage.value = 'Error clearing local data';
    }
  }
}
