import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'POS System Login',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
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
                      passwordController.text.isEmpty) {
                    authController.errorMessage.value =
                        'Username and password are required';
                    return;
                  }

                  final success = await authController.login(
                    usernameController.text,
                    passwordController.text,
                  );

                  if (success) {
                    Get.offAllNamed('/dashboard');
                  }
                },
                child: Obx(() => authController.isLoading.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Login')),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
              SizedBox(
                  height:
                      16), // Tambahkan jarak antara button login dan register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => Get.toNamed('/register'),
                    child: Text('Register here'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
