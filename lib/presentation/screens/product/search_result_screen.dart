import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/product_service.dart';
import '../../../data/models/product_model.dart';
import '../home/home_screen.dart'; // Để tái sử dụng ProductGridItem

class SearchResultScreen extends StatelessWidget {
  final String searchQuery;
  // static const routeName = '/search-results'; // Nếu dùng named routes

  const SearchResultScreen({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả cho: "$searchQuery"'),
        elevation: 1,
      ),
      body: StreamBuilder<List<Product>>(
        stream: productService.searchProducts(searchQuery), // Gọi hàm tìm kiếm
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Lỗi tìm kiếm sản phẩm: ${snapshot.error}");
            return Center(child: Text('Đã xảy ra lỗi khi tìm kiếm: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Không tìm thấy sản phẩm nào cho "$searchQuery"',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          final products = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65, // Điều chỉnh cho phù hợp
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (ctx, index) {
              final product = products[index];
              // Tái sử dụng ProductGridItem từ HomeScreen (nếu nó đã được tách ra hoặc bạn copy qua)
              // Hoặc bạn có thể định nghĩa lại widget item ở đây
              return ProductGridItem(product: product);
            },
          );
        },
      ),
    );
  }
}