import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controllers/product_controller.dart';
import 'package:pos/models/product_model.dart';

class ProductContent extends StatelessWidget {
  final ProductController controller = Get.put(ProductController());
  final formKey = GlobalKey<FormState>();

  ProductContent({Key? key}) : super(key: key);

  void _showProductDialog({Product? product}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController =
        TextEditingController(text: product?.price.toString() ?? '');
    final descriptionController =
        TextEditingController(text: product?.description ?? '');
    final stockController =
        TextEditingController(text: product?.stock.toString() ?? '');

    Get.dialog(
      AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Edit Product'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    prefixIcon: Icon(Icons.inventory),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Price is required';
                    return double.tryParse(value) == null
                        ? 'Invalid price'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: stockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    prefixIcon: Icon(Icons.inventory_2),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Stock is required';
                    return int.tryParse(value) == null ? 'Invalid stock' : null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newProduct = Product(
                  id: product?.id,
                  name: nameController.text,
                  price: double.parse(priceController.text),
                  stock: int.parse(stockController.text),
                  description: descriptionController.text,
                );

                product == null
                    ? controller.addProduct(newProduct)
                    : controller.updateProduct(newProduct);
                Get.back();
              }
            },
            child: Text(product == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductDialog(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.products.isEmpty) {
          return const Center(
            child: Text('No products available'),
          );
        }

        return ListView.builder(
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text('Price: ${product.price}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showProductDialog(product: product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => controller.deleteProduct(product.id!),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
