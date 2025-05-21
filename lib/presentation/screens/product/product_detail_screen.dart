import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Nếu muốn slider ảnh có chỉ báo
import '../../../services/product_service.dart';
import '../../../data/models/product_model.dart';
import '../../providers_or_blocs/cart_provider.dart'; // Để thêm vào giỏ hàng
import '../cart/cart_screen.dart'; // Để điều hướng đến giỏ hàng

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  // static const routeName = '/product-detail'; // Nếu dùng named routes

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _imagePageController = PageController();
  int _selectedQuantity = 1; // Số lượng mặc định khi thêm vào giỏ

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      _selectedQuantity++;
    });
  }

  void _decrementQuantity() {
    if (_selectedQuantity > 1) {
      setState(() {
        _selectedQuantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Product?>( // Hiển thị tên sản phẩm trên AppBar
          future: productService.getProductById(widget.productId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Đang tải...");
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return const Text("Chi Tiết Sản Phẩm");
            }
            return Text(snapshot.data!.name, style: TextStyle(fontSize: 18));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const CartScreen()));
            },
          ),
        ],
      ),
      body: FutureBuilder<Product?>(
        future: productService.getProductById(widget.productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải chi tiết sản phẩm: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Không tìm thấy sản phẩm.'));
          }

          final product = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Slider hình ảnh sản phẩm
                if (product.imageUrls.isNotEmpty)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PageView.builder(
                          controller: _imagePageController,
                          itemCount: product.imageUrls.length,
                          itemBuilder: (context, index) {
                            return Hero( // Sử dụng Hero với tag tương tự như ở ProductGridItem
                              tag: 'product_image_${product.id}_$index', // Thêm index để đảm bảo unique nếu nhiều ảnh
                              // Hoặc chỉ dùng tag 'product_image_${product.id}' nếu ProductGridItem chỉ hiển thị ảnh đầu
                              child: CachedNetworkImage(
                                imageUrl: product.imageUrls[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: Colors.grey[200], child: const Center(child: CircularProgressIndicator())),
                                errorWidget: (context, url, error) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image_outlined, size: 60)),
                              ),
                            );
                          },
                        ),
                        // if (product.imageUrls.length > 1) // Chỉ báo trang (dots)
                        //   Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: SmoothPageIndicator(
                        //       controller: _imagePageController,
                        //       count: product.imageUrls.length,
                        //       effect: ExpandingDotsEffect(
                        //         dotHeight: 8,
                        //         dotWidth: 8,
                        //         activeDotColor: theme.colorScheme.primary,
                        //         paintStyle: PaintingStyle.fill,
                        //       ),
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                if (product.imageUrls.isEmpty)
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    color: Colors.grey[200],
                    child: Center(child: Icon(Icons.image_not_supported_outlined, size: 100, color: Colors.grey[400])),
                  ),

                // 2. Thông tin sản phẩm
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row( // Ví dụ hiển thị số lượng tồn kho và đã bán (nếu có)
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Text('Còn lại: ${product.stockQuantity}', style: TextStyle(color: Colors.grey[700])),
                          const SizedBox(width: 16),
                          Icon(Icons.star_border_outlined, size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Text('4.5 (100+ đánh giá)', style: TextStyle(color: Colors.grey[700])), // Dummy
                        ],
                      ),
                      const Divider(height: 32),
                      Text(
                        "Mô tả sản phẩm",
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      // TODO: Thêm phần chọn size, màu sắc nếu có

                      // 3. Chọn số lượng
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Số lượng:", style: theme.textTheme.titleMedium),
                          const SizedBox(width: 16),
                          _buildQuantityButton(
                            context,
                            icon: Icons.remove,
                            onPressed: _decrementQuantity,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              '$_selectedQuantity',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          _buildQuantityButton(
                            context,
                            icon: Icons.add,
                            onPressed: _incrementQuantity,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 70), // Khoảng trống cho nút bottom
              ],
            ),
          );
        },
      ),
      // 4. Nút "Thêm vào giỏ hàng" ở dưới cùng
      bottomNavigationBar: FutureBuilder<Product?>(
          future: productService.getProductById(widget.productId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const SizedBox.shrink(); // Không hiển thị gì nếu chưa có data sản phẩm
            }
            final product = snapshot.data!;
            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart_outlined),
                label: const Text('Thêm vào Giỏ Hàng'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: product.stockQuantity == 0 ? null : () { // Vô hiệu hóa nếu hết hàng
                  cartProvider.addItem(product, quantity: _selectedQuantity);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} (SL: $_selectedQuantity) đã được thêm vào giỏ!'),
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                        label: 'XEM GIỎ',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => const CartScreen()), // Điều hướng đến CartScreen
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }
      ),
    );
  }

  // Widget helper cho nút +/- số lượng
  Widget _buildQuantityButton(BuildContext context, {required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}