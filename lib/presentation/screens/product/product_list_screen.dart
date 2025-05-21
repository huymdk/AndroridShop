import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/product_service.dart';
import '../../../data/models/product_model.dart';
import '../home/home_screen.dart'; // Để tái sử dụng ProductGridItem
// import 'product_detail_screen.dart';

class ProductListScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName; // Tên danh mục để hiển thị trên AppBar
  // static const routeName = '/product-list';

  const ProductListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: StreamBuilder<List<Product>>(
        stream: productService.getProductsByCategory(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải sản phẩm: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có sản phẩm nào trong danh mục "${categoryName}".'));
          }

          final products = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (ctx, index) {
              final product = products[index];
              // Tái sử dụng ProductGridItem từ HomeScreen
              return ProductGridItem(product: product);
            },
          );
        },
      ),
    );
  }
}