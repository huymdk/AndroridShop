import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../services/product_service.dart';
import '../../../data/models/product_model.dart';
// Import màn hình thêm/sửa sản phẩm
import 'admin_add_edit_product_screen.dart'; // <<< BỎ COMMENT VÀ ĐẢM BẢO ĐƯỜNG DẪN ĐÚNG

class AdminProductListScreen extends StatelessWidget {
  const AdminProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Sản Phẩm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Thêm sản phẩm mới',
            onPressed: () {
              // Điều hướng đến màn hình thêm sản phẩm, truyền product: null
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminAddEditProductScreen(product: null)),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: productService.getProducts(), // Lấy tất cả sản phẩm
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải danh sách sản phẩm: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có sản phẩm nào. Hãy thêm mới!'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (ctx, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: SizedBox(
                    width: 60,
                    height: 60,
                    child: ClipRRect( // Thêm ClipRRect để bo góc ảnh
                      borderRadius: BorderRadius.circular(4.0),
                      child: (product.imageUrls.isNotEmpty && product.imageUrls.first.isNotEmpty)
                          ? CachedNetworkImage(
                        imageUrl: product.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
                        errorWidget: (context, url, error) => const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                      )
                          : Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey)),
                    ),
                  ),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ - SL: ${product.stockQuantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                        tooltip: 'Sửa sản phẩm',
                        onPressed: () {
                          // Điều hướng đến màn hình sửa sản phẩm, truyền product hiện tại
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AdminAddEditProductScreen(product: product)),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                        tooltip: 'Xóa sản phẩm',
                        onPressed: () async {
                          // Lưu lại context và scaffoldMessenger trước khi gọi showDialog
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          final currentContext = context; // Lưu context để dùng trong showDialog
                          final currentTheme = Theme.of(context); // Lưu theme

                          final confirmDelete = await showDialog<bool>(
                            context: currentContext, // Sử dụng context đã lưu
                            builder: (dialogCtx) => AlertDialog(
                              title: const Text('Xác nhận xóa'),
                              content: Text('Bạn có chắc muốn xóa sản phẩm "${product.name}"? Hành động này không thể hoàn tác.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(dialogCtx).pop(false), child: const Text('Hủy')),
                                TextButton(
                                  onPressed: () => Navigator.of(dialogCtx).pop(true),
                                  child: Text('Xóa', style: TextStyle(color: currentTheme.colorScheme.error)),
                                ),
                              ],
                            ),
                          );

                          if (confirmDelete == true) {
                            try {
                              await productService.deleteProduct(product.id);
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('Đã xóa sản phẩm: ${product.name}'), backgroundColor: Colors.green),
                              );
                            } catch (e) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text('Lỗi khi xóa sản phẩm: $e'), backgroundColor: currentTheme.colorScheme.error),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Khi nhấn vào ListTile, cũng có thể điều hướng đến màn hình sửa
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminAddEditProductScreen(product: product)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}