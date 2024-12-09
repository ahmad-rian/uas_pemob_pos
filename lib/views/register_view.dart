import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controllers/auth_controller.dart';

class RegisterView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordConfirmController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                SizedBox(height: 24),
                Obx(() => authController.errorMessage.value.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          authController.errorMessage.value,
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : SizedBox()),
                ElevatedButton(
                  onPressed: () async {
                    if (usernameController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        passwordController.text.isEmpty ||
                        passwordConfirmController.text.isEmpty) {
                      authController.errorMessage.value =
                          'All fields are required';
                      return;
                    }

                    if (passwordController.text !=
                        passwordConfirmController.text) {
                      authController.errorMessage.value =
                          'Passwords do not match';
                      return;
                    }

                    final success = await authController.register(
                      username: usernameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      passwordConfirmation: passwordConfirmController.text,
                    );

                    if (success) {
                      Get.snackbar(
                        'Success',
                        'Registration successful! Please login.',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                      Get.offNamed('/login');
                    }
                  },
                  child: Obx(() => authController.isLoading.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Register')),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.toNamed('/login'),
                  child: Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
