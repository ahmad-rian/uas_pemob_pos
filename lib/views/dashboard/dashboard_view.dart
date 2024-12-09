import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controllers/auth_controller.dart';
import 'package:pos/controllers/dashboard_controller.dart';
import 'package:pos/views/dashboard/dashboard_content.dart';
import 'package:pos/views/cashier/cashier_content.dart';
import 'package:pos/views/product/product_content.dart';

class DashboardView extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: MediaQuery.of(context).size.width < 1100
          ? AppBar(
              title: Text('POS System'),
              leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            )
          : null,
      drawer: MediaQuery.of(context).size.width < 1100
          ? _buildSidebar(context, true)
          : null,
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width >= 1100)
            _buildSidebar(context, false),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: Obx(() => _buildContent()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool isDrawer) {
    return Container(
      width: isDrawer ? MediaQuery.of(context).size.width * 0.85 : 280,
      constraints: BoxConstraints(maxWidth: 280),
      color: Colors.white,
      child: Column(
        children: [
          // Profile Section
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(
                bottom: BorderSide(
                  color: Colors.blue.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                SizedBox(height: 16),
                Obx(() => Text(
                      controller.userName.value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    )),
                SizedBox(height: 4),
                Obx(() => Text(
                      controller.userEmail.value,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            ),
          ),
          // Navigation Items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildNavItem(0, 'Dashboard', Icons.dashboard),
                  _buildNavItem(1, 'Kasir', Icons.point_of_sale),
                  _buildNavItem(2, 'Produk', Icons.inventory),
                ],
              ),
            ),
          ),
          // Divider before logout
          Divider(height: 1),
          // Logout Button
          Container(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () async {
                final AuthController authController =
                    Get.find<AuthController>();
                final success = await authController.logout();
                if (success) {
                  Get.offAllNamed('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          // Additional padding at bottom for better visual
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey[700],
            size: 22,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey[800],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onTap: () {
            controller.changeIndex(index);
            // Close drawer if it's open on mobile
            if (MediaQuery.of(Get.context!).size.width < 1100) {
              Get.back();
            }
          },
        ),
      );
    });
  }

  Widget _buildContent() {
    switch (controller.selectedIndex.value) {
      case 0:
        return DashboardContent();
      case 1:
        return CashierContent();
      case 2:
        return ProductContent();
      default:
        return DashboardContent();
    }
  }
}
