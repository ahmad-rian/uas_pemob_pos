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
              elevation: 0,
              backgroundColor: Colors.white,
              title: Text('POS System',
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w600)),
              iconTheme: IconThemeData(color: Colors.black87),
              leading: IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            )
          : null,
      drawer: MediaQuery.of(context).size.width < 1100
          ? _buildSidebar(context, true)
          : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[50]!,
              Colors.grey[100]!,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Row(
          children: [
            if (MediaQuery.of(context).size.width >= 1100)
              _buildSidebar(context, false),
            Expanded(
              child: Obx(() => _buildContent()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool isDrawer) {
    return Container(
      width: isDrawer ? MediaQuery.of(context).size.width * 0.85 : 280,
      constraints: BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[100]!,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue[400]!, Colors.blue[600]!],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.person, size: 40, color: Colors.blue[600]),
                  ),
                ),
                SizedBox(height: 16),
                Obx(() => Text(
                      controller.userName.value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildNavItem(0, 'Dashboard', Icons.dashboard_outlined),
                    _buildNavItem(1, 'Kasir', Icons.point_of_sale_outlined),
                    _buildNavItem(2, 'Produk', Icons.inventory_2_outlined),
                  ],
                ),
              ),
            ),
          ),

          // Logout Section
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[100]!),
              ),
            ),
            child: Obx(() => ElevatedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          final AuthController authController =
                              Get.find<AuthController>();
                          await authController.logout();
                        },
                  icon: Icon(Icons.logout_rounded, size: 20),
                  label: Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )),
          ),
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
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Icon(
              icon,
              color: isSelected ? Colors.blue[600] : Colors.grey[700],
              size: 24,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.blue[600] : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () {
              controller.changeIndex(index);
              if (MediaQuery.of(Get.context!).size.width < 1100) {
                Get.back();
              }
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            minLeadingWidth: 0,
            dense: true,
          ),
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
