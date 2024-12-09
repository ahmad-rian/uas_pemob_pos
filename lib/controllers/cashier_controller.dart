import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pos/models/product_model.dart';
import 'package:pos/models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CashierController extends GetxController {
  final cartItems = <TransactionItem>[].obs;
  final totalAmount = 0.0.obs;
  final isLoading = false.obs;
  final products = <Product>[].obs;
  final selectedProduct = Rxn<Product>();
  final searchQuery = ''.obs;
  final baseUrl = 'http://localhost:8000/api';

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Authentication token not found');

      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null) {
          final List<dynamic> data = responseData['data'];
          products.value = data.map((json) => Product.fromJson(json)).toList();
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void addToCart(Product product) {
    try {
      if (product.stock <= 0) {
        Get.snackbar(
          'Error',
          'Product is out of stock',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final existingItem = cartItems.firstWhereOrNull(
        (item) => item.productId == product.id,
      );

      if (existingItem != null) {
        if (existingItem.quantity >= product.stock) {
          Get.snackbar(
            'Error',
            'Cannot add more items. Stock limit reached.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        updateQuantity(
          cartItems.indexOf(existingItem),
          existingItem.quantity + 1,
        );
      } else {
        cartItems.add(
          TransactionItem(
            productId: product.id!,
            name: product.name,
            price: product.price,
            quantity: 1,
          ),
        );
      }
      _calculateTotal();

      Get.snackbar(
        'Success',
        'Added ${product.name} to cart',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add product to cart',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void removeFromCart(int index) {
    final item = cartItems[index];
    cartItems.removeAt(index);
    _calculateTotal();

    Get.snackbar(
      'Item Removed',
      '${item.name} removed from cart',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  void updateQuantity(int index, int quantity) {
    final product = products.firstWhere(
      (p) => p.id == cartItems[index].productId,
    );

    if (quantity <= 0) {
      removeFromCart(index);
      return;
    }

    if (quantity > product.stock) {
      Get.snackbar(
        'Error',
        'Quantity exceeds available stock',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    cartItems[index] = cartItems[index].copyWith(quantity: quantity);
    _calculateTotal();
  }

  void _calculateTotal() {
    totalAmount.value = cartItems.fold(
      0.0,
      (sum, item) => sum + item.total,
    );
  }

  Future<bool> processTransaction() async {
    try {
      if (cartItems.isEmpty) {
        Get.snackbar(
          'Error',
          'Cart is empty',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      isLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Authentication token not found');

      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'items': cartItems
              .map((item) => {
                    'product_id': item.productId,
                    'quantity': item.quantity,
                    'price': item.price
                  })
              .toList(),
          'total_amount': totalAmount.value,
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 201) {
        // Transaksi berhasil
        Get.back(); // Tutup bottom sheet cart

        Get.snackbar(
          'Success',
          'Transaction completed successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        clearTransaction();
        await fetchProducts(); // Refresh produk untuk update stok
        return true;
      } else {
        // Tangani error dari server
        Get.snackbar(
          'Error',
          responseBody['message'] ?? 'Transaction failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.error, color: Colors.white),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearTransaction() {
    cartItems.clear();

    totalAmount.value = 0.0;

    Get.snackbar(
      'Cart Cleared',
      'All items have been removed from the cart',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
