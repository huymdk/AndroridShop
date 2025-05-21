// lib/presentation/screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers_or_blocs/cart_provider.dart';
import '../../../data/models/cart_item_model.dart'; // Ba dấu chấm đầu tiên// import '../checkout/checkout_screen.dart'; // Sẽ tạo sau
import '../checkout/checkout_screen.dart'; // <<< THÊM DÒNG NÀY
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context); // Lắng nghe thay đổi từ CartProvider

    return Scaffold(
      appBar: AppBar(
        title: Text('Giỏ Hàng (${cart.totalQuantity})'), // Hiển thị tổng số lượng
        elevation: 1,
      ),
      body: cart.items.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.remove_shopping_cart_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Giỏ hàng của bạn đang trống!',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                // Lấy CartItemModel từ Map values
                final cartItem = cart.items.values.toList()[i];
                final productId = cart.items.keys.toList()[i]; // Lấy productId từ Map keys

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ảnh sản phẩm
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: cartItem.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(width: 80, height: 80, color: Colors.grey[200]),
                            errorWidget: (context, url, error) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Thông tin sản phẩm và số lượng
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cartItem.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${cartItem.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                                style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              // Bộ điều chỉnh số lượng
                              Row(
                                children: [
                                  _buildQuantityButton(
                                    context,
                                    icon: Icons.remove,
                                    onPressed: () {
                                      cart.decrementQuantity(productId);
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Text(
                                      '${cartItem.quantity}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  _buildQuantityButton(
                                    context,
                                    icon: Icons.add,
                                    onPressed: () {
                                      cart.incrementQuantity(productId);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Nút xóa item
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                          onPressed: () {
                            // Hỏi xác nhận trước khi xóa
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Xác nhận xóa'),
                                content: Text('Bạn có chắc muốn xóa ${cartItem.name} khỏi giỏ hàng?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Hủy'),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Xóa', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                    onPressed: () {
                                      cart.removeItem(productId);
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Thanh tổng tiền và nút thanh toán
          if (cart.items.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // Hoặc một màu nền khác
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1), // changes position of shadow
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng cộng:',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      Text(
                        '${cart.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Thanh Toán'),
                    onPressed: (cart.items.isEmpty)
                        ? null
                        : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => const CheckoutScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Widget helper cho nút +/- số lượng
  Widget _buildQuantityButton(BuildContext context, {required IconData icon, required VoidCallback onPressed}) {
    return Material( // Thêm Material để có hiệu ứng ripple
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}